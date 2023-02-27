unit HookUtils;
{$WARNINGS OFF}
{$HINTS OFF}

{
  wr960204��ϡ��.2012.2

  ��ҳ  http://www.raysoftware.cn

  ͨ��Hook��.
  ֧��X86��X64.                     Get
  ʹ���˿�Դ��BeaEngine���������.BeaEngine�ĺô��ǿ�����BCB�����OMF��ʽ��Obj,
  �����ӽ�Delphi��DCU��Ŀ���ļ���.����Ҫ�����DLL.
  BeaEngin����
  http://www.beaengine.org/

  ����:
  1.����Hook�����СС��5���ֽڵĺ���.
  2.����Hookǰ����ֽ�������תָ��ĺ���.
  ϣ��ʹ�õ��������Լ�Ҳ����һ���Ļ���������֪ʶ.
  Hook����ǰ��ȷ���ú��������������������.


  ���⹳COM������һ������,�������������ʱ����סĳ��COM����,
  ��������Ҫ����COM���󴴽�ǰ�Լ��ȴ���һ���ö���,Hookס,Ȼ���ͷ����Լ��Ķ���.
  ������������Ѿ����¹�����,�����ǹ������COM���󴴽�ǰ��.
}
interface

{ �º�������
  64λ�л���һ�����ʧ��,����VirtualAlloc�����ڱ�Hook������ַ����2Gb��Χ�ڷ��䵽�ڴ�.
  �����������΢����΢.���������ܷ���.
}
function HookProc(Func, NewFunc: Pointer; out originalFunc: Pointer): Boolean; overload;
function HookProcInModule(DLLName, FuncName: PChar; NewFunc: Pointer; out originalFunc: Pointer): Boolean; overload;

// deprecated ����������,����ֵ�󷵻�,��ʱ�޷�Hook������ʹ�õ����������ڴ���߳�״̬�ĺ���
function HookProc(Func, NewFunc: Pointer): Pointer; overload;

// deprecated ����������,����ֵ�󷵻�,��ʱ�޷�Hook������ʹ�õ����������ڴ���߳�״̬�ĺ���
function HookProcInModule(DLLName, FuncName: PChar; NewFunc: Pointer): Pointer; overload;
{ ����COM�����з����ĵ�ַ;AMethodIndex�Ƿ���������.
  AMethodIndex�ǽӿڰ������ӿڵķ���������.
  ����:
  IA = Interface
  procedure A();//��ΪIA�Ǵ�IUnKnow������,IUnKnow�Լ���3������,����AMethodIndex=3
  end;
  IB = Interface(IA)
  procedure B(); //��ΪIB�Ǵ�IA������,����AMethodIndex=4
  end;
}
function CalcInterfaceMethodAddr(var AInterface; AMethodIndex: Integer): Pointer;

// ��COM���󷽷��Ĺ���
function HookInterface(var AInterface; AMethodIndex: Integer; NewFunc: Pointer; out originalFunc: Pointer): Boolean;

// �������
function UnHook(OldFunc: Pointer): Boolean;

implementation

uses
  BeaEngineDelphi, Windows, TLHelp32;

const
  PageSize = 4096;
{$IFDEF CPUX64}
{$DEFINE USELONGJMP}
{$ENDIF}
  { .$DEFINE USEINT3 }// �ڻ���ָ���в���INT3,�ϵ�ָ��.�������.

type
  THandles  = array of THandle;
  ULONG_PTR = NativeUInt;
  POldProc  = ^TOldProc;

  PJMPCode = ^TJMPCode;

  TJMPCode = packed record
{$IFDEF USELONGJMP}
    JMP: Word;
    JmpOffset: Int32;
{$ELSE}
    JMP: byte;
{$ENDIF}
    Addr: UIntPtr;
  end;

  TOldProc = packed record
{$IFDEF USEINT3}
    Int3OrNop: byte;
{$ENDIF}
    BackCode: array [0 .. $20 - 1] of byte;
    JmpRealFunc: TJMPCode;
    JmpHookFunc: TJMPCode;

    BackUpCodeSize: Integer;
    OldFuncAddr: Pointer;
  end;

  PNewProc = ^TNewProc;

  TNewProc = packed record
    JMP: byte;
    Addr: Integer;
  end;

  // ������Ҫ���ǵĻ���ָ���С.������BeaEngin���������.����ָ����м��п�
function CalcHookCodeSize(Func: Pointer): Integer;
var
  ldiasm: TDISASM;
  len   : longint;
begin
  Result := 0;
  ZeroMemory(@ldiasm, SizeOf(ldiasm));
  ldiasm.EIP   := UIntPtr(Func);
  ldiasm.Archi := {$IFDEF CPUX64}64{$ELSE}32{$ENDIF};
  while Result < SizeOf(TNewProc) do
  begin
    len := Disasm(ldiasm);
    Inc(ldiasm.EIP, len);
    Inc(Result, len);
  end;
end;

const
  THREAD_ALL_ACCESS = STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or $3FF;

function OpenThread(dwDesiredAccess: DWORD; bInheritHandle: BOOL; dwThreadId: DWORD): THandle; stdcall; external kernel32;

function SuspendOneThread(dwThreadId: NativeUInt; ACode: Pointer; ASize: Integer): THandle;
var
  hThread       : THandle;
  dwSuspendCount: DWORD;
  ctx           : TContext;
  IPReg         : Pointer;
  tryTimes      : Integer;
begin
  Result  := INVALID_HANDLE_VALUE;
  hThread := OpenThread(THREAD_ALL_ACCESS, FALSE, dwThreadId);
  if (hThread <> 0) and (hThread <> INVALID_HANDLE_VALUE) then
  begin
    dwSuspendCount := SuspendThread(hThread);
    // SuspendThread���ص��Ǳ���������ü���,-1�Ļ���ʧ��.
    if dwSuspendCount <> DWORD(-1) then
    begin
      while (GetThreadContext(hThread, ctx)) do
      begin
        tryTimes := 0;
        IPReg    := Pointer({$IFDEF CPUX64}ctx.Rip{$ELSE}ctx.EIP{$ENDIF});
        if (NativeInt(IPReg) >= NativeInt(ACode)) and (NativeInt(IPReg) <= (NativeInt(ACode) + ASize)) then
        begin
          ResumeThread(hThread);
          Sleep(100);
          SuspendThread(hThread);
          Inc(tryTimes);
          if tryTimes > 5 then
          begin
            Break;
          end;
        end
        else
        begin
          Result := hThread;
          Break;
        end;
      end;
    end;
  end;
end;

function SuspendOtherThread(ACode: Pointer; ASize: Integer): THandles;
var
  hSnap            : THandle;
  te               : THREADENTRY32;
  nThreadsInProcess: DWORD;
  hThread          : THandle;
begin
  Exit;

  hSnap     := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, GetCurrentProcessId());
  te.dwSize := SizeOf(te);

  nThreadsInProcess := 0;
  if (Thread32First(hSnap, te)) then
  begin
    while True do
    begin
      if (te.th32OwnerProcessID = GetCurrentProcessId()) then
      begin
        if (te.th32ThreadID <> GetCurrentThreadId()) then
        begin
          hThread := SuspendOneThread(te.th32ThreadID, ACode, ASize);
          if hThread <> INVALID_HANDLE_VALUE then
          begin
            Inc(nThreadsInProcess);
            SetLength(Result, nThreadsInProcess);
            Result[nThreadsInProcess - 1] := hThread;
          end;
        end
      end;
      te.dwSize := SizeOf(te);
      if not Thread32Next(hSnap, te) then
        Break;
    end;
    // until not Thread32Next(hSnap, te);
  end;

  CloseHandle(hSnap);
end;

procedure ResumOtherThread(threads: THandles);
var
  i: Integer;
begin
  Exit;
  for i := Low(threads) to High(threads) do
  begin
    ResumeThread(threads[i]);
    CloseHandle(threads[i]);
  end;
end;

{
  ������ָ��ָ��APtr������2Gb���ڷ����ڴ�.32λ�϶���������.
  64λJMP������Ե�.��������32λ����.���Ա��뱣֤�µĺ����ھɺ���������2GB��.
  ����û����ת��������ת����.
}
function TryAllocMem(APtr: Pointer; ASize: Cardinal): Pointer;
const
  KB: Int64 = 1024;
  MB: Int64 = 1024 * 1024;
  GB: Int64 = 1024 * 1024 * 1024;
var
  mbi     : TMemoryBasicInformation;
  Min, Max: Int64;
  pbAlloc : Pointer;
  sSysInfo: TSystemInfo;
begin

  GetSystemInfo(sSysInfo);
  Min := NativeUInt(APtr) - 2 * GB;
  if Min <= 0 then
    Min := 1;
  Max   := NativeUInt(APtr) + 2 * GB;

  Result  := nil;
  pbAlloc := Pointer(Min);
  while NativeUInt(pbAlloc) < Max do
  begin
    if (VirtualQuery(pbAlloc, mbi, SizeOf(mbi)) = 0) then
      Break;
    if ((mbi.State or MEM_FREE) = MEM_FREE) and (mbi.RegionSize >= ASize) and (mbi.RegionSize >= sSysInfo.dwAllocationGranularity) then
    begin
      pbAlloc := PByte(ULONG_PTR((ULONG_PTR(pbAlloc) + (sSysInfo.dwAllocationGranularity - 1)) div sSysInfo.dwAllocationGranularity) * sSysInfo.dwAllocationGranularity);
      Result  := VirtualAlloc(pbAlloc, ASize, MEM_COMMIT or MEM_RESERVE
{$IFDEF CPUX64}
        or MEM_TOP_DOWN
{$ENDIF}
        , PAGE_EXECUTE_READWRITE);
      if Result <> nil then
        Break;
    end;
    pbAlloc := Pointer(NativeUInt(mbi.BaseAddress) + mbi.RegionSize);
  end;

end;

function HookProc(Func, NewFunc: Pointer): Pointer; overload;
begin
  if not HookProc(Func, NewFunc, Result) then
    Result := nil;
end;

function HookProcInModule(DLLName, FuncName: PChar; NewFunc: Pointer): Pointer;
begin
  if not HookProcInModule(DLLName, FuncName, NewFunc, Result) then
    Result := nil;
end;

function HookProcInModule(DLLName, FuncName: PChar; NewFunc: Pointer; out originalFunc: Pointer): Boolean;
var
  h: HMODULE;
begin
  Result := FALSE;
  h      := GetModuleHandle(DLLName);
  if h = 0 then
    h := LoadLibrary(DLLName);
  if h = 0 then
    Exit;
  Result := HookProc(GetProcAddress(h, FuncName), NewFunc, originalFunc);
end;

function HookProc(Func, NewFunc: Pointer; out originalFunc: Pointer): Boolean;
  procedure FixFunc();
  var
    ldiasm: TDISASM;
    len   : longint;
  begin
    ZeroMemory(@ldiasm, SizeOf(ldiasm));
    ldiasm.EIP   := UIntPtr(Func);
    ldiasm.Archi := {$IFDEF CPUX64}64{$ELSE}32{$ENDIF};

    len := Disasm(ldiasm);
    Inc(ldiasm.EIP, len);
    //
    if (ldiasm.Instruction.Mnemonic[0] = 'j') and (ldiasm.Instruction.Mnemonic[1] = 'm') and (ldiasm.Instruction.Mnemonic[2] = 'p') and (ldiasm.Instruction.AddrValue <> 0) then
    begin
      Func := Pointer(ldiasm.Instruction.AddrValue);
      FixFunc();
    end;
  end;

var
  oldProc                   : POldProc;
  newProc                   : PNewProc;
  backCodeSize              : Integer;
  newProtected, oldProtected: DWORD;
  threads                   : THandles;
  nOriginalPriority         : Integer;
  JmpAfterBackCode          : PJMPCode;
begin
  Result := FALSE;
  if (Func = nil) or (NewFunc = nil) then
    Exit;

  FixFunc();
  newProc      := PNewProc(Func);
  backCodeSize := CalcHookCodeSize(Func);
  if backCodeSize < 0 then
    Exit;
  nOriginalPriority := GetThreadPriority(GetCurrentThread());
  SetThreadPriority(GetCurrentThread(), THREAD_PRIORITY_TIME_CRITICAL);
  // ��д�ڴ��ʱ��Ҫ���������߳�,������ɴ���.
  threads := SuspendOtherThread(Func, backCodeSize);
  try
    if not VirtualProtect(Func, backCodeSize, PAGE_EXECUTE_READWRITE, oldProtected) then
      Exit;
    //

    originalFunc := TryAllocMem(Func, PageSize);
    // VirtualAlloc(nil, PageSize, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
    if originalFunc = nil then
      Exit;

    FillMemory(originalFunc, SizeOf(TOldProc), $90);
    oldProc := POldProc(originalFunc);
{$IFDEF USEINT3}
    oldProc.Int3OrNop := $CC;
{$ENDIF}
    oldProc.BackUpCodeSize := backCodeSize;
    oldProc.OldFuncAddr    := Func;
    CopyMemory(@oldProc^.BackCode, Func, backCodeSize);
    JmpAfterBackCode := PJMPCode(@oldProc^.BackCode[backCodeSize]);
{$IFDEF USELONGJMP}
    oldProc^.JmpRealFunc.JMP       := $25FF;
    oldProc^.JmpRealFunc.JmpOffset := 0;
    oldProc^.JmpRealFunc.Addr      := UIntPtr(Int64(Func) + backCodeSize);

    JmpAfterBackCode^.JMP       := $25FF;
    JmpAfterBackCode^.JmpOffset := 0;
    JmpAfterBackCode^.Addr      := UIntPtr(Int64(Func) + backCodeSize);

    oldProc^.JmpHookFunc.JMP       := $25FF;
    oldProc^.JmpHookFunc.JmpOffset := 0;
    oldProc^.JmpHookFunc.Addr      := UIntPtr(NewFunc);
{$ELSE}
    oldProc^.JmpRealFunc.JMP  := $E9;
    oldProc^.JmpRealFunc.Addr := (NativeInt(Func) + backCodeSize) - (NativeInt(@oldProc^.JmpRealFunc) + 5);

    oldProc^.JmpHookFunc.JMP  := $E9;
    oldProc^.JmpHookFunc.Addr := NativeInt(NewFunc) - (NativeInt(@oldProc^.JmpHookFunc) + 5);
{$ENDIF}
    //
    FillMemory(Func, backCodeSize, $90);

    newProc^.JMP  := $E9;
    newProc^.Addr := NativeInt(@oldProc^.JmpHookFunc) - (NativeInt(@newProc^.JMP) + 5);;
    // NativeInt(NewFunc) - (NativeInt(@newProc^.JMP) + 5);

    if not VirtualProtect(Func, backCodeSize, oldProtected, newProtected) then
      Exit;

    // ˢ�´������е�ָ���.�����ⲿ��ָ�����.ִ�е�ʱ��һ��.
    FlushInstructionCache(GetCurrentProcess(), newProc, backCodeSize);
    FlushInstructionCache(GetCurrentProcess(), oldProc, PageSize);
    Result := True;
  finally
    ResumOtherThread(threads);
    SetThreadPriority(GetCurrentThread(), nOriginalPriority);
  end;
end;

function UnHook(OldFunc: Pointer): Boolean;
var
  oldProc                   : POldProc ABSOLUTE OldFunc;
  newProc                   : PNewProc;
  backCodeSize              : Integer;
  newProtected, oldProtected: DWORD;
  threads                   : THandles;
  nOriginalPriority         : Integer;
begin
  Result := FALSE;
  if (OldFunc = nil) then
    Exit;

  backCodeSize := oldProc^.BackUpCodeSize;
  newProc      := PNewProc(oldProc^.OldFuncAddr);

  nOriginalPriority := GetThreadPriority(GetCurrentThread());
  SetThreadPriority(GetCurrentThread(), THREAD_PRIORITY_TIME_CRITICAL);
  threads := SuspendOtherThread(oldProc, SizeOf(TOldProc));
  try
    if not VirtualProtect(newProc, backCodeSize, PAGE_EXECUTE_READWRITE, oldProtected) then
      Exit;

    CopyMemory(newProc, @oldProc^.BackCode, oldProc^.BackUpCodeSize);

    if not VirtualProtect(newProc, backCodeSize, oldProtected, newProtected) then
      Exit;

    VirtualFree(oldProc, PageSize, MEM_FREE);
    // ˢ�´������е�ָ���.�����ⲿ��ָ�����.ִ�е�ʱ��һ��.
    FlushInstructionCache(GetCurrentProcess(), newProc, backCodeSize);
  finally
    ResumOtherThread(threads);
    SetThreadPriority(GetCurrentThread(), nOriginalPriority);
  end;
end;

function CalcInterfaceMethodAddr(var AInterface; AMethodIndex: Integer): Pointer;
type
  TBuf = array [0 .. $FF] of byte;
  PBuf = ^TBuf;
var
  pp : PPointer;
  buf: PBuf;
begin
  pp := PPointer(AInterface)^;
  Inc(pp, AMethodIndex);
  Result := pp^;
  { Delphi��COM����ķ�����Ƚ��ر�,COM�ӿ�ʵ�����Ƕ����һ����Ա,ʵ���ϵ��õ�
    ������Self������ӿڳ�Ա�ĵ�ַ,����Delphi��COM������ֱ��ָ����󷽷�,����ָ��
    һС�λ���ָ��,��Self��ȥ(�Ӹ���)�����Ա�ڶ����е�ƫ��,������Selfָ�������ת
    ����������ķ������.

    ��������Ҫ"͵��"һ�·���ָ��ָ���ͷ�����ֽ�,���������Selfָ���,��ô����Delphi
    ʵ�ֵ�COM����.���Ǿ��������������Ķ����ַ.

    �����������жϺʹ���Delphi��COM�����.��������ʵ�ֵ�COM������Զ����Ե�.
    ��Ϊ�����ĺ���ͷ�����Ƕ���ջ�׵Ĵ�����߲������ֲ������Ĵ������.
    ��������һ����������һ������,Ҳ����Self��ָ��.���Ը���������ж�.
  }
  buf := Result;
  {
    add Self,[-COM�������ʵ�ֶ���ƫ��]
    JMP  �����ķ���
    �����ľ���Delphi���ɵ�COM���󷽷���ǰ��ָ��
  }
{$IFDEF CPUX64}
  // add rcx, -COM�����ƫ��, JMP ��������ķ�����ַ,X64��ֻ��һ��stdcall����Լ��.����Լ������stdcall�ı���
  if (buf^[0] = $48) and (buf^[1] = $81) and (buf^[2] = $C1) and (buf^[7] = $E9) then
    Result := Pointer(NativeInt(@buf[$C]) + PDWORD(@buf^[8])^);
{$ELSE}
  // add [esp + $04],-COM�����ƫ��, JMP�����Ķ����ַ,stdcall/cdecl����Լ��
  if (buf^[0] = $81) and (buf^[1] = $44) and (buf^[2] = $24) and (buf^[03] = $04) and (buf^[8] = $E9) then
    Result := Pointer(NativeInt(@buf[$D]) + PDWORD(@buf^[9])^)
  else // add eax,-COM�����ƫ��, JMP�����Ķ����ַ,�Ǿ���Register����Լ����
    if (buf^[0] = $05) and (buf^[5] = $E9) then
      Result := Pointer(NativeInt(@buf[$A]) + PDWORD(@buf^[6])^);
{$ENDIF}
end;

function HookInterface(var AInterface; AMethodIndex: Integer; NewFunc: Pointer; out originalFunc: Pointer): Boolean;
begin
  Result := HookProc(CalcInterfaceMethodAddr(AInterface, AMethodIndex), NewFunc, originalFunc);
end;

end.
