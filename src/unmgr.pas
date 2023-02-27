unit unmgr;

interface

uses
  Winapi.Windows, System.Classes, Winapi.Messages, System.SysUtils, Winapi.IpHlpApi, Winapi.IpRtrMib, Winapi.IpTypes, System.Win.Registry, Winapi.Winsock2, Winapi.PsAPI;

const
  BuffLen    = 1024;
  IP_HDRINCL = 1;
  IOC_IN     = $80000000;
  IOC_VENDOR = $18000000;
  SIO_RCVALL = Cardinal(IOC_IN or IOC_VENDOR or 1);
  WM_SNIFFER = WM_USER + 1024;

type
  TTCPTableClass = (                    { }
    TCP_TABLE_BASIC_LISTENER,           { }
    TCP_TABLE_BASIC_CONNECTIONS,        { }
    TCP_TABLE_BASIC_ALL,                { }
    TCP_TABLE_OWNER_PID_LISTENER,       { }
    TCP_TABLE_OWNER_PID_CONNECTIONS,    { }
    TCP_TABLE_OWNER_PID_ALL,            { }
    TCP_TABLE_OWNER_MODULE_LISTENER,    { }
    TCP_TABLE_OWNER_MODULE_CONNECTIONS, { }
    TCP_TABLE_OWNER_MODULE_ALL          { }
    );

  TUDPTableClass = (       { }
    UDP_TABLE_BASIC,       { }
    UDP_TABLE_OWNER_PID,   { }
    UDP_TABLE_OWNER_MODULE { }
    );

  { TCP }
  MIB_TCPROW_OWNER_PID = record
    dwState: DWORD;
    dwLocalAddr: DWORD;
    dwLocalPort: DWORD;
    dwRemoteAddr: DWORD;
    dwRemotePort: DWORD;
    dwOwningPid: DWORD;
  end;

  PMIB_TCP_ROW = ^MIB_TCPROW_OWNER_PID;

  MIB_TCPTABLE_OWNER_PID = record
    dwNumEntries: DWORD;
    table: array [0 .. ANY_SIZE - 1] of MIB_TCPROW_OWNER_PID;
  end;

  PMIB_TCPTABLE_OWNER_PID = ^MIB_TCPTABLE_OWNER_PID;

  { UDP }
  _MIB_UDPROW_OWNER_PID = packed record
    dwLocalAddr: DWORD;
    dwLocalPort: DWORD;
    dwOwningPid: DWORD;
  end;

  TMibUdpRowOwnerPID = _MIB_UDPROW_OWNER_PID;
  PMibUdpRowOwnerPID = ^_MIB_UDPROW_OWNER_PID;

  _MIB_UDPTABLE_OWNER_PID = packed record
    dwNumEntries: DWORD;
    table: Array [0 .. ANY_SIZE - 1] of TMibUdpRowOwnerPID;
  end;

  TMibUdpTableOwnerPID    = _MIB_UDPTABLE_OWNER_PID;
  PMibUdpTableOwnerPID    = ^TMibUdpTableOwnerPID;
  PMIB_UDPTABLE_OWNER_PID = ^TMibUdpTableOwnerPID;

  PSTRU_TCP_HEADER = ^STRU_TCP_HEADER;

  STRU_TCP_HEADER = packed record  { TCP数据包头 }
    SrcPort: Word;                 { 源端口 }
    DstPort: Word;                 { 目的端口 }
    SeqNO: Cardinal;               { 序号 }
    AckNO: Cardinal;               { 确认号 }
    Offset4_Reserved6_Flag6: Word; { 头部长度+保留+标志 }
    Window: Word;                  { 窗口大小 }
    Checksum: Word;                { 校验和 }
    UrgentPointer: Word;           { 紧急指针 }
  end;

  PSTRU_UDP_HEADER = ^STRU_UDP_HEADER;

  STRU_UDP_HEADER = packed record { UDP数据包头 }
    SrcPort: Word;                { 源端口 }
    DstPort: Word;                { 目的端口 }
    len: Word;                    { 总长度 }
    Checksum: Word;               { 校验和 }
  end;

  PSTRU_ICMP_HEADER = ^STRU_ICMP_HEADER;

  STRU_ICMP_HEADER = packed record { ICMP数据包头 }
    i_type: Byte;
    i_code: Byte; { type sub code }
    i_cksum: Word;
    i_id: Word;
    i_seq: Word;
    timestamp: Cardinal;
  end;

  PIPHeader = ^TIPHeader;

  TIPHeader = packed record { IP数据包头 20字节 }
    iph_verlen: Byte;       { 版本+报头长 }
    iph_tos: Byte;          { 服务类型 }
    iph_length: Word;       { 总长度 }
    iph_id: Word;           { 标识 }
    iph_offset: Word;       { 标志+片偏移 }
    iph_ttl: Byte;          { 生存周期 }
    iph_protocol: Byte;     { 协议类型 }
    iph_xsum: Word;         { 头部校验和 }
    iph_src: longword;      { 源IP地址 }
    iph_dest: longword;     { 目的IP地址 }
  end;

  PSnifferProcess = ^TSnifferProcess;

  TSnifferProcess = packed record
    iPackSize: Integer;         { 数据包大小 }
    sProtocolType: ShortString; { 协议类型 }
    bAcceptOrSend: Boolean;     { 是接收数据还是发生数据 }
    SrcIP: Cardinal;            { 源IP }
    SrcPort: Cardinal;          { 源Port }
    DstIP: Cardinal;            { 目标IP }
    DstPort: Cardinal;          { 目标Port }
    PID: DWORD;                 { 进程ID }
    ProcessPath: ShortString;   { 进程路径 }
  end;

  PMyIP = ^TMyIP;

  MyIP = record
    dwLocalAddr: DWORD;
    dwLocalPort: DWORD;
    dwProcessID: DWORD;
  end;

  TMyIP = MyIP;

  PLSPItem = ^TLSPItem;

  TLSPItem = packed record
    sCaption: array [0 .. 255] of WideChar;
    iChainLen: Integer;
    iChainID: Integer;
    iCatalogEntryID: Integer;
    gGUID: TGUID;
    sFileName: array [0 .. 255] of WideChar;
  end;

type
  TSnifferThread = class(TThread)
  private
    FParentFormHandle: Integer;
    FIndex           : Integer;
    FSocket          : TSocket;
    FIPHead          : PIPHeader;
    FLocalIP         : Cardinal;
    FStopSniffer     : Boolean;
    procedure AnalyseData(const TotalSize: Integer; Buf: PIPHeader; const ParentFormhWnd: Integer);
    function GetProtocolStr(const ptc: Byte): string;
    function GetProtocolType(Buf: PIPHeader): Integer;
    { 是接收还是发生数据 }
    function CheckDataAcceptOrSend(Buf: PIPHeader; const LocalIP: Cardinal): Boolean;
    { 获取IP 和 Port }
    procedure GetIPOrPort(Buf: PIPHeader; const bAcceptOrSend: Boolean; var SrcIP, SrcPort, DstIP, DstPort: Cardinal);
    { 获取进程ID，通过源IP和源Port }
    function GetProcessIDFromIPAndPort(const SrcIP, SrcPort: Cardinal): DWORD;
    { 获取进程名称 }
    function GetProcessNameFromProcessID(const PID: Cardinal): string;
    { 获取所有的TCP连接 }
    function GetTCPConnections(ls: TList): Boolean;
    { 获取所有的TCP连接 }
    function GetUDPConnections(ls: TList): Boolean;
  public
    constructor Create(s: TSocket; const lIP: Cardinal; const ParentFormHandle: Integer); overload;
    destructor Destroy; override;
    procedure StopSniffer;
  protected
    procedure Execute; override;
  end;

  TNetworkManager = class(TObject)
  private
    FParentFormHandle: Integer;
    { 网卡信息 }
    FAdapterBufLen: Cardinal;
    FPAdaptersInfo: PIP_ADAPTER_INFO;
    { 网络流量 }
    FMITBufLen: Cardinal;
    FPMIT     : PMIB_IFTABLE;
    { 进程流量 }
    FSnifferThread: TSnifferThread;
    { }
    FPProtocol: PWsaProtocolInfoW;
    FLSPList  : TList;
    { Int64转换为字节数组 }
    function ToBytes(const AValue: Int64): TBytes;
    { 绑定监听IP、端口 }
    function SetHost(var host: TSockAddrIn): Boolean;
  public
    constructor Create(hWnd: Cardinal);
    destructor Destroy; override;
    { 长整形数转换为IP字符串 }
    function LongwordToIP(SCR: longword): string;
    { 64位整数转换为 Mac 地址 }
    function GetMacString(IP: Int64): String;
    { 将字节组转换为字符串 }
    function GetDescrString(TTT: array of Byte): String;
    { 获取所有网卡信息 }
    function GetNetworkApaptersInfo(ls: TList): Boolean;
    { 获取网卡流量 }
    function GetNetworkTraffic(ls: TList): Boolean;
    { 获取网络适配器状态 }
    function GetAdapterInterfaceStatus(Index: Integer): String;
    { 获取进程流量 }
    function GetProcessTraffic: Boolean;
    { 获取本机所有的LSP }
    function GetAllLSP(ls: TList): Boolean;
  end;

implementation

{ 函数声明 }
function GetExtendedUdpTable(pTcpTable: Pointer; dwSize: PDWORD; bOrder: Boolean; ulAf: Cardinal; TableClass: TUDPTableClass; Reserved: Cardinal): DWORD; stdcall; external 'iphlpapi.dll' name 'GetExtendedUdpTable';
function GetExtendedTcpTable(pTcpTable: Pointer; dwSize: PDWORD; bOrder: Boolean; ulAf: Cardinal; TableClass: TTCPTableClass; Reserved: Cardinal): DWORD; stdcall; external 'iphlpapi.dll' name 'GetExtendedTcpTable';
function WSCEnumProtocols(lpiProtocols: PINT; lpProtocolBuffer: LPWSAPROTOCOL_INFOW; var lpdwBufferLength: DWORD; var lpErrno: Integer): Integer; stdcall; external 'ws2_32.dll';
function WSCDeinstallProvider(const lpProviderId: TGUID; var lpErrno: Integer): Integer; stdcall; external 'ws2_32.dll';
function WSCWriteProviderOrder(lpwdCatalogEntryId: LPDWORD; dwNumberOfEntries: DWORD): Integer; stdcall; external 'ws2_32.dll';
function WSCInstallProvider(const lpProviderId: TGUID; lpszProviderDllPath: PWCHAR; lpProtocolInfoList: LPWSAPROTOCOL_INFOW; dwNumberOfEntries: DWORD; var lpErrno: Integer): Integer; stdcall; external 'ws2_32.dll';
function WSCGetProviderPath(const lpProviderId: TGUID; lpszProviderDllPath: PWCHAR; var lpProviderDllPathLen, lpErrno: Integer): Integer; stdcall; external 'ws2_32.dll';
function mbind(s: TSocket; var addr: TSockAddrIn; namelen: Integer): Integer; stdcall; external 'wsock32.dll' name 'bind';

{ TNetworkManager }

{ 提升权限 }
function EnableDebugPrivilege(PrivName: string; CanDebug: Boolean): Boolean;
var
  TP    : Winapi.Windows.TOKEN_PRIVILEGES;
  Dummy : Cardinal;
  hToken: THandle;
begin
  OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES, hToken);
  TP.PrivilegeCount := 1;
  LookupPrivilegeValue(nil, PChar(PrivName), TP.Privileges[0].Luid);
  if CanDebug then
    TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
  else
    TP.Privileges[0].Attributes := 0;
  Result                        := AdjustTokenPrivileges(hToken, False, TP, SizeOf(TP), nil, Dummy);
  hToken                        := 0;
end;

constructor TNetworkManager.Create(hWnd: Cardinal);
var
  wsd : TWsaData;
  iRet: Integer;
begin
  { Socket 初始化 }
  iRet := WSAStartup($202, wsd);
  if iRet <> 0 then
    Exit;

  EnableDebugPrivilege('SeDebugPrivilege', True);

  FParentFormHandle := hWnd;

  { 网卡信息，分配一个默认的缓冲区大小 }
  FAdapterBufLen := SizeOf(IP_ADAPTER_INFO);
  FPAdaptersInfo := AllocMem(FAdapterBufLen);

  { 网络流量，分配一个默认的缓冲区大小 }
  FMITBufLen := SizeOf(TMibIftable);
  FPMIT      := AllocMem(FMITBufLen);
  { 网络流量线程 }
  FSnifferThread := nil;

  FPProtocol := AllocMem(SizeOf(TWsaProtocolInfoW));
  FLSPList   := TList.Create;
end;

destructor TNetworkManager.Destroy;
var
  III: Integer;
begin
  if FSnifferThread <> nil then
  begin
    FSnifferThread.StopSniffer;
    FSnifferThread.Terminate;
    FSnifferThread := nil;
  end;

  { 销毁分配的内存 }
  FreeMem(FPAdaptersInfo);
  FreeMem(FPMIT);
  FreeMem(FPProtocol);

  if FLSPList.Count > 0 then
  begin
    for III := 0 to FLSPList.Count - 1 do
    begin
      FreeMem(FLSPList.Items[III]);
    end;
  end;
  FLSPList.Free;

  { Socket 释放 }
  WSACleanup();

  inherited Destroy;
end;

{ 长整形数转换为IP字符串 }
function TNetworkManager.LongwordToIP(SCR: longword): string;
type
  PIP = ^TIP;

  { IP地址 }
  TIP = packed record
    IP1: Byte;
    IP2: Byte;
    IP3: Byte;
    IP4: Byte;
  end;

var
  IP: PIP;
begin
  IP     := @SCR;
  Result := IntToStr(IP.IP1) + '.' + IntToStr(IP.IP2) + '.' + IntToStr(IP.IP3) + '.' + IntToStr(IP.IP4);
end;

{ Int64转换为字节数组 }
function TNetworkManager.ToBytes(const AValue: Int64): TBytes;
begin
  SetLength(Result, SizeOf(Int64));
  PInt64(@Result[0])^ := AValue;
end;

{ 获取网络适配器状态 }
function TNetworkManager.GetAdapterInterfaceStatus(Index: Integer): String;
const
  MIB_IF_OPER_STATUS_NON_OPERATIONAL = 0;
  MIB_IF_OPER_STATUS_UNREACHABLE     = 1;
  MIB_IF_OPER_STATUS_DISCONNECTED    = 2;
  MIB_IF_OPER_STATUS_CONNECTING      = 3;
  MIB_IF_OPER_STATUS_CONNECTED       = 4;
  MIB_IF_OPER_STATUS_OPERATIONAL     = 5;
begin
  Result := '';
  if Index = MIB_IF_OPER_STATUS_NON_OPERATIONAL then
    Result := '网络适配器被禁止'
  else if Index = MIB_IF_OPER_STATUS_UNREACHABLE then
    Result := '没有连接'
  else if Index = MIB_IF_OPER_STATUS_DISCONNECTED then
    Result := '局域网：电缆未连接；广域网：无载波信号'
  else if Index = MIB_IF_OPER_STATUS_CONNECTING then
    Result := '广域网适配器连接中'
  else if Index = MIB_IF_OPER_STATUS_CONNECTED then
    Result := '广域网适配器连接上远程对等点'
  else if Index = MIB_IF_OPER_STATUS_OPERATIONAL then
    Result := '局域网适配器默认状态';
end;

{ 将字节组转换为字符串 }
function TNetworkManager.GetDescrString(TTT: array of Byte): String;
var
  tmpArrayByte: array of Byte;
  Count       : Integer;
begin
  Result := '';
  Count  := Length(TTT);
  SetLength(tmpArrayByte, Count + 1);
  Move(TTT[0], tmpArrayByte[0], Count);
  tmpArrayByte[Count] := $0;
  Result              := string(PAnsiChar(@tmpArrayByte[0]));
end;

{ 64位整数转换为 Mac 地址 }
function TNetworkManager.GetMacString(IP: Int64): String;
var
  Str: TBytes;
begin
  Str    := ToBytes(IP);
  Result := InttoHex(Str[0], 2) + '-' + InttoHex(Str[1], 2) + '-' + InttoHex(Str[2], 2) + '-' + InttoHex(Str[3], 2) + '-' + InttoHex(Str[4], 2) + '-' + InttoHex(Str[5], 2);
end;

{ 获取所有网卡信息 }
function TNetworkManager.GetNetworkApaptersInfo(ls: TList): Boolean;
var
  III           : Integer;
  lstAdapterInfo: PIP_ADAPTER_INFO;
label AAA;
begin
  Result := False;

  { 第一次调用 GetAdaptersInfo ，以便获取实际的缓冲区大小 }
  III := GetAdaptersInfo(FPAdaptersInfo, FAdapterBufLen);
  if III = ERROR_SUCCESS then
    goto AAA;

  if III <> ERROR_BUFFER_OVERFLOW then
  begin
    Exit;
  end;

  { 分配实际的缓冲区大小 }
  FPAdaptersInfo := ReallocMemory(FPAdaptersInfo, FAdapterBufLen);

  { 第二次调用，获取网卡信息 }
  III := GetAdaptersInfo(FPAdaptersInfo, FAdapterBufLen);
  if III <> ERROR_SUCCESS then
  begin
    Exit;
  end;

AAA:
  { 保存每一个网卡信息到列表中 }
  lstAdapterInfo := FPAdaptersInfo;
  repeat
    ls.Add(lstAdapterInfo);
    lstAdapterInfo := lstAdapterInfo.Next;
  until lstAdapterInfo = nil;

  Result := True;
end;

{ 获取网卡流量 }
function TNetworkManager.GetNetworkTraffic(ls: TList): Boolean;
var
  III: Integer;
begin
  Result := False;

  { 第一次调用 GetIfTable ，以便获取实际的缓冲区大小 }
  FMITBufLen := 0;
  III        := GetIfTable(nil, FMITBufLen, False);
  if III <> ERROR_INSUFFICIENT_BUFFER then
  begin
    Exit;
  end;

  { 分配实际的缓冲区大小 }
  FPMIT := ReallocMemory(FPMIT, FMITBufLen);

  { 第二次调用，获取网卡流量信息 }
  III := GetIfTable(FPMIT, FMITBufLen, True);
  if III <> NO_ERROR then
  begin
    Exit;
  end;

  { 保存每一个网卡信息到列表中 }
  ls.Clear;
  for III := 0 to FPMIT^.dwNumEntries - 1 do
  begin
    ls.Add(@FPMIT.table[III]);
  end;

  Result := True;
end;

{ 绑定本地主机 }
function TNetworkManager.SetHost(var host: TSockAddrIn): Boolean;
var
  HostEnt: PHostEnt;
  Buffer : array [0 .. 63] of AnsiChar;
  addr   : PAnsiChar;
  IP     : string;
begin
  Result := False;
  GetHostName(Buffer, SizeOf(Buffer));
  HostEnt := GetHostByName(Buffer);

  if HostEnt = nil then
    Exit;

  addr                 := HostEnt^.h_addr_list^;
  IP                   := Format('%d.%d.%d.%d', [Byte(addr[0]), Byte(addr[1]), Byte(addr[2]), Byte(addr[3])]);
  host.sin_family      := AF_INET;
  host.sin_port        := htons(7000);
  host.sin_addr.S_addr := Inet_addr(PAnsiChar(AnsiString(IP)));
  Result               := True;
end;

{ 获取进程流量 }
function TNetworkManager.GetProcessTraffic: Boolean;
var
  MySocket  : Cardinal;
  iErrorCode: Integer;
  host      : TSockAddrIn;
  bopt      : Integer;
  dwValue   : Cardinal;
  LocalIP   : Cardinal;
begin
  Result := False;

  { 创建连接 }
  MySocket := socket(AF_INET, SOCK_RAW, IPPROTO_IP);
  if MySocket = INVALID_SOCKET then
    Exit;

  { 配置选项 }
  bopt       := 1;
  iErrorCode := setsockopt(MySocket, IPPROTO_IP, IP_HDRINCL, @bopt, SizeOf(bopt));
  if iErrorCode = SOCKET_ERROR then
    Exit;

  { 设置IP地址 }
  FillChar(host, SizeOf(host), #0);
  if not SetHost(host) then
    Exit;

  { 绑定 }
  if mbind(MySocket, host, SizeOf(host)) = SOCKET_ERROR then
    Exit;

  { 设置混合模式 }
  dwValue := 1;
  if ioctlsocket(MySocket, Integer(SIO_RCVALL), dwValue) <> 0 then
    Exit;

  { 开始抓取数据 }
  LocalIP        := host.sin_addr.S_addr;
  FSnifferThread := TSnifferThread.Create(MySocket, LocalIP, FParentFormHandle);

  Result := True;
end;

{ 获取 LSP 文件名 }
function GetLSPFileName(const ChainID: Cardinal): String;
type
  PRWPI = ^TRWPI;

  TRWPI = packed record
    sFileName: array [0 .. MAX_PATH - 1] of AnsiChar;
    wpi: TWsaProtocolInfoW;
  end;
var
  III, Count: Integer;
  sKey      : String;
  Buffer    : TRWPI;
begin
  Result := '';
  with TRegistry.Create do
  begin
    try
      try
        { 获取总数 }
        RootKey := HKEY_LOCAL_MACHINE;
        OpenKey('SYSTEM\CurrentControlSet\Services\WinSock2\Parameters\Protocol_Catalog9', False);
        Count := ReadInteger('Num_Catalog_Entries');
        CloseKey;

        for III := 0 to Count - 1 do
        begin
          sKey := 'SYSTEM\CurrentControlSet\Services\WinSock2\Parameters\Protocol_Catalog9\Catalog_Entries\' + Format('%0.12d', [III + 1]);
          if OpenKey(sKey, False) then
          begin
            ZeroMemory(@Buffer, SizeOf(Buffer));
            ReadBinaryData('PackedCatalogItem', Buffer, SizeOf(Buffer));
            if Buffer.wpi.dwCatalogEntryId = ChainID then
            begin
              Result := String(Buffer.sFileName);
              Break;
            end;
            CloseKey;
          end;
        end;
      except
        Result := '';
      end;
    finally
      Free;
    end;
  end;
end;

{ 获取本机所有的 LSP 信息 }
function TNetworkManager.GetAllLSP(ls: TList): Boolean;
var
  iRet      : Integer;
  dwSize    : Cardinal;
  dwError   : Integer;
  III       : Integer;
  tmpLspItem: PLSPItem;
begin
  Result := False;
  dwSize := 0;

  iRet := WSCEnumProtocols(nil, FPProtocol, dwSize, dwError);
  if iRet = SOCKET_ERROR then
  begin
    iRet := WSAGetLastError;
    if iRet <> ERROR_SUCCESS then
    begin
      Exit;
    end;

    FPProtocol := ReallocMemory(FPProtocol, dwSize);
    iRet       := WSCEnumProtocols(nil, FPProtocol, dwSize, dwError);
    if iRet = SOCKET_ERROR then
    begin
      Exit;
    end;

    Result  := True;
    for III := 0 to iRet - 1 do
    begin
      tmpLspItem := AllocMem(SizeOf(TLSPItem));
      Move(FPProtocol^.szProtocol, tmpLspItem.sCaption, 255);
      tmpLspItem^.iChainLen       := FPProtocol^.ProtocolChain.ChainLen;
      tmpLspItem^.iChainID        := FPProtocol^.ProtocolChain.ChainEntries[0];
      tmpLspItem^.iCatalogEntryID := FPProtocol^.dwCatalogEntryId;
      tmpLspItem^.gGUID           := FPProtocol^.ProviderId;
      StrPCopy(tmpLspItem^.sFileName, GetLSPFileName(tmpLspItem^.iCatalogEntryID));
      FLSPList.Add(tmpLspItem);
      Inc(FPProtocol);
    end;
    ls.Assign(FLSPList, laCopy);
    Dec(FPProtocol, iRet);
  end;
end;

{ TSnifferThread }

constructor TSnifferThread.Create(s: TSocket; const lIP: Cardinal; const ParentFormHandle: Integer);
begin
  FSocket           := s;
  FreeOnTerminate   := True;
  FIndex            := 0;
  FLocalIP          := lIP;
  FStopSniffer      := False;
  FParentFormHandle := ParentFormHandle;
  inherited Create(False);
end;

destructor TSnifferThread.Destroy;
begin
  inherited Destroy;
end;

procedure TSnifferThread.StopSniffer;
begin
  FStopSniffer := True;
end;

function TSnifferThread.GetProtocolStr(const ptc: Byte): string;
begin
  case ptc of
    IPPROTO_IP:
      Result := 'IP';
    IPPROTO_ICMP:
      Result := 'ICMP';
    IPPROTO_IGMP:
      Result := 'IGMP';
    IPPROTO_GGP:
      Result := 'GGP';
    IPPROTO_TCP:
      Result := 'TCP';
    IPPROTO_PUP:
      Result := 'PUP';
    IPPROTO_UDP:
      Result := 'UDP';
    IPPROTO_IDP:
      Result := 'IDP';
    IPPROTO_ND:
      Result := 'NP';
    IPPROTO_RAW:
      Result := 'RAW';
  else
    Result := '未知协议';
  end;
end;

{ 获取协议类型 }
function TSnifferThread.GetProtocolType(Buf: PIPHeader): Integer;
begin
  Result := Buf^.iph_protocol;
end;

{ 获取所有的TCP连接 }
function TSnifferThread.GetTCPConnections(ls: TList): Boolean;
var
  pTcpTable: PMIB_TCPTABLE_OWNER_PID;
  dwSize   : DWORD;
  Res      : DWORD;
  III      : Integer;
  PIP      : PMyIP;
begin
  Result    := False;
  pTcpTable := nil;
  dwSize    := 0;
  Res       := GetExtendedTcpTable(pTcpTable, @dwSize, False, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0);
  if Res <> ERROR_INSUFFICIENT_BUFFER Then
    Exit;

  GetMem(pTcpTable, dwSize);
  try
    ZeroMemory(pTcpTable, dwSize);
    Res := GetExtendedTcpTable(pTcpTable, @dwSize, False, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0);
    if Res = NO_ERROR then
    begin
      Result  := True;
      for III := 0 to pTcpTable.dwNumEntries - 1 do
      begin
        New(PIP);
        PIP^.dwLocalAddr := pTcpTable^.table[III].dwLocalAddr;
        PIP^.dwLocalPort := pTcpTable^.table[III].dwLocalPort;
        PIP^.dwProcessID := pTcpTable^.table[III].dwOwningPid;
        ls.Add(PIP);
      end;
    end;
  finally
    If (pTcpTable <> Nil) Then
      FreeMem(pTcpTable);
  end;
end;

{ 获取所有的UDP连接 }
function TSnifferThread.GetUDPConnections(ls: TList): Boolean;
var
  pUdpTable: PMIB_UDPTABLE_OWNER_PID;
  dwSize   : DWORD;
  Res      : DWORD;
  III      : Integer;
  PIP      : PMyIP;
begin
  Result    := False;
  pUdpTable := nil;
  dwSize    := 0;
  Res       := GetExtendedUdpTable(pUdpTable, @dwSize, False, AF_INET, UDP_TABLE_OWNER_PID, 0);
  if Res <> ERROR_INSUFFICIENT_BUFFER Then
    Exit;

  GetMem(pUdpTable, dwSize);
  try
    ZeroMemory(pUdpTable, dwSize);
    Res := GetExtendedUdpTable(pUdpTable, @dwSize, False, AF_INET, UDP_TABLE_OWNER_PID, 0);
    if Res = NO_ERROR then
    begin
      Result  := True;
      for III := 0 to pUdpTable.dwNumEntries - 1 do
      begin
        New(PIP);
        PIP^.dwLocalAddr := pUdpTable^.table[III].dwLocalAddr;
        PIP^.dwLocalPort := pUdpTable^.table[III].dwLocalPort;
        PIP^.dwProcessID := pUdpTable^.table[III].dwOwningPid;
        ls.Add(PIP);
      end;
    end;
  finally
    If (pUdpTable <> Nil) Then
      FreeMem(pUdpTable);
  end;
end;

{ 是接收还是发生数据 }
function TSnifferThread.CheckDataAcceptOrSend(Buf: PIPHeader; const LocalIP: Cardinal): Boolean;
var
  SrcIP : Cardinal;
  DestIP: Cardinal;
begin
  Result := False;

  if Buf^.iph_protocol = IPPROTO_TCP then
  begin
    SrcIP := Buf^.iph_src;
    if FLocalIP <> SrcIP then
    begin
      Result := True;
    end;
  end;

  if Buf^.iph_protocol = IPPROTO_UDP then
  begin
    SrcIP  := Buf^.iph_src;
    DestIP := Buf^.iph_dest;
    if (FLocalIP = DestIP) or (SrcIP = $FFFFFFFF) then
    begin
      Result := True;
    end;
  end;
end;

{ 获取IP 和 Port }
procedure TSnifferThread.GetIPOrPort(Buf: PIPHeader; const bAcceptOrSend: Boolean; var SrcIP, SrcPort, DstIP, DstPort: Cardinal);
var
  TCP: PSTRU_TCP_HEADER;
  UDP: PSTRU_UDP_HEADER;
begin
  if Buf^.iph_protocol = IPPROTO_UDP then
  begin
    UDP := PSTRU_UDP_HEADER(Pointer(Cardinal(Buf) + 4 * (Byte(Buf^.iph_verlen Shl 4) shr 4 and $F)));
    if bAcceptOrSend = False then
    begin
      SrcIP   := Buf^.iph_src;
      DstIP   := Buf^.iph_dest;
      SrcPort := UDP^.SrcPort;
      DstPort := UDP^.DstPort;
    end
    else
    begin
      SrcIP   := Buf^.iph_dest;
      DstIP   := Buf^.iph_src;
      SrcPort := UDP^.DstPort;
      DstPort := UDP^.SrcPort;
    end;
  end;

  if Buf^.iph_protocol = IPPROTO_TCP then
  begin
    TCP := PSTRU_TCP_HEADER(Pointer(Cardinal(Buf) + 4 * (Byte(Buf^.iph_verlen Shl 4) shr 4 and $F)));
    if bAcceptOrSend = False then
    begin
      SrcIP   := Buf^.iph_src;
      DstIP   := Buf^.iph_dest;
      SrcPort := TCP^.SrcPort;
      DstPort := TCP^.DstPort;
    end
    else
    begin
      SrcIP   := Buf^.iph_dest;
      DstIP   := Buf^.iph_src;
      SrcPort := TCP^.DstPort;
      DstPort := TCP^.SrcPort;
    end;
  end;

end;

{ 获取进程ID，通过源 IP 和源 Port }
function TSnifferThread.GetProcessIDFromIPAndPort(const SrcIP, SrcPort: Cardinal): DWORD;
var
  ls              : TList;
  III, Count      : Integer;
  iSrcIP, iSrcPort: Cardinal;
begin
  Result := 0;

  ls := TList.Create;
  try
    GetTCPConnections(ls);
    GetUDPConnections(ls);
    if ls.Count <= 0 then
      Exit;

    Count   := ls.Count;
    for III := 0 to Count - 1 do
    Begin
      iSrcIP   := PMyIP(ls.Items[III])^.dwLocalAddr;
      iSrcPort := PMyIP(ls.Items[III])^.dwLocalPort;
      if (iSrcIP = SrcIP) and (iSrcPort = SrcPort) then
      begin
        Result := PMyIP(ls.Items[III])^.dwProcessID;
        Break;
      end;
    End;
  finally
    if ls.Count > 0 then
    begin
      for III := 0 to ls.Count - 1 do
      begin
        FreeMem(ls.Items[III]);
      end;
    end;
    ls.Free;
  end;

end;

{ 获取进程名称 }
function TSnifferThread.GetProcessNameFromProcessID(const PID: Cardinal): string;
var
  Buffer  : array [0 .. 255] of Char;
  hProcess: Cardinal;
begin
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, PID);
  if hProcess <> 0 then
  begin
    if GetModuleFileNameEx(hProcess, 0, Buffer, Length(Buffer)) = 0 then
      Result := ''
    else
      Result := Buffer;
  end;
  CloseHandle(hProcess);
end;

{ 分析网络数据包 }
procedure TSnifferThread.AnalyseData(const TotalSize: Integer; Buf: PIPHeader; const ParentFormhWnd: Integer);
var
  III        : Integer;
  PackSize   : Integer;
  Psp        : TSnifferProcess;
  bAOrS      : Boolean;
  SrcIP      : Cardinal;
  SrcPort    : Cardinal;
  DstIP      : Cardinal;
  DstPort    : Cardinal;
  PID        : Integer;
  ProcessPath: ShortString;
begin
  { 数据包大小 }
  if Buf^.iph_protocol = IPPROTO_UDP then
    PackSize := TotalSize - SizeOf(TIPHeader) - SizeOf(STRU_UDP_HEADER)
  else if Buf^.iph_protocol = IPPROTO_TCP then
    PackSize := TotalSize - SizeOf(TIPHeader) - SizeOf(STRU_TCP_HEADER)
  else if Buf^.iph_protocol = IPPROTO_ICMP then
    PackSize := TotalSize - SizeOf(TIPHeader) - SizeOf(STRU_ICMP_HEADER)
  else
    PackSize := TotalSize - SizeOf(TIPHeader) - SizeOf(STRU_ICMP_HEADER);

  if PackSize <= 0 then
    Exit;

  { 协议类型 }
  III := GetProtocolType(Buf);

  { 是接收还是发生数据 }
  bAOrS := CheckDataAcceptOrSend(Buf, FLocalIP);

  { 获取 源和目的 IP、Port }
  GetIPOrPort(Buf, bAOrS, SrcIP, SrcPort, DstIP, DstPort);

  { 获取进程ID }
  PID         := GetProcessIDFromIPAndPort(SrcIP, SrcPort);
  ProcessPath := ShortString(GetProcessNameFromProcessID(PID));

  Psp.iPackSize     := PackSize;
  Psp.sProtocolType := ShortString(Format('%0.2d  < %s >', [III, GetProtocolStr(III)]));
  Psp.bAcceptOrSend := bAOrS;
  Psp.SrcIP         := SrcIP;
  Psp.SrcPort       := ntohs(SrcPort);
  Psp.DstIP         := DstIP;
  Psp.DstPort       := ntohs(DstPort);
  Psp.PID           := PID;
  Psp.ProcessPath   := ProcessPath;

  PostMessage(FParentFormHandle, WM_SNIFFER, LongInt(@Psp), 0);
end;

procedure TSnifferThread.Execute;
var
  RCVBuff: array [0 .. BuffLen - 1] of AnsiChar;
  nSize  : Integer;
begin
  inherited;

  while True do
  begin
    if FStopSniffer then
      Break;

    Sleep(1);
    nSize := recv(FSocket, RCVBuff, BuffLen, 0);
    if nSize = SOCKET_ERROR then
      Continue;

    if nSize > SizeOf(TIPHeader) then
    begin
      FIPHead := @RCVBuff[0];
      AnalyseData(nSize, FIPHead, FParentFormHandle); { 分析网络数据包 }
    end;
  end;
end;

end.
