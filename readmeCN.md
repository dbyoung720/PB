PB(PBox)
=============

# PB(PBox) ��һ������ DLL ��̬�ⴰ���ģ�黯����ƽ̨

- [English](readme.md)

## һ��������ּ
    ���ž������޸Ļ��޸�ԭ�й���(EXE)Դ����(Delphi��VC��QT)��ԭ��;
    ֧�� Delphi DLL ���塢VC DLL ����(Dialog/MFC)��QT DLL ����; 

## ��������ƽ̨
    Delphi11.3��WIN10X64 �¿�����
    WIN10X64�²���ͨ����֧��X86��X64��
    ���䣺dbyoung@sina.com��
    QQȺ��101611228��

## ����ʹ�÷���
### Delphi��
* Delphi ԭ EXE �����ļ����޸�Ϊ DLL ���̡�������������Ϳ����ˣ�ԭ�д��벻�����κ��޸ģ�
* �ѱ����� DLL �ļ����õ� plugins Ŀ¼�¾Ϳ����ˣ�
* ʾ����modules\curlUI��
* ʾ����modules\sPath��
* ʾ����modules\pm��
* Delphi ����������
```
 procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;
```
### VC2022
* �� VC ���� EXE ת���� DLL�����������Ե���: [https://blog.csdn.net/dbyoung/article/details/103987103]
* VC ԭ EXE�����ڶԻ��򣬲����κ��޸ġ��½� Dll.cpp �ļ���������������Ϳ����ˣ�
* VC ԭ EXE������   MFC����Ҫ�����޸ģ�
* �ѱ����� DLL �ļ����õ� plugins Ŀ¼�¾Ϳ����ˣ�
* ʾ��(���ڶԻ���)��modules\7-zip��
* ʾ��(���ڶԻ���)��modules\Notepad2��
* ʾ��(����   MFC)��modules\mpc-be��
* VC2022 ����������
```
enum TLangStyle {lsDelphiDll, lsVCDLGDll, lsVCMFCDll, lsQTDll, lsEXE};
extern "C" __declspec(dllexport) void db_ShowDllForm_Plugins(TLangStyle* lsFileType, char** strParentName, char** strSubModuleName, char** strClassName, char** strWindowName, const bool show = false)
```

### QT
* QT ԭ EXE�������κ��޸ġ����룬�õ� LIB��RES��OBJ �ļ���
* �½� Dll.cpp �ļ���������������Ϳ����ˣ����롢���ӵõ� DLL �ļ���
* �ѱ����� DLL �ļ����õ� plugins Ŀ¼�¾Ϳ����ˣ�
* ��ʵ�� VC Dialog DLL ��ʽһģһ������װ�͵��ã�
* ʾ����modules\cmake-gui��
* ʾ����modules\qBittorrent��
* ����������
```
enum TLangStyle {lsDelphiDll, lsVCDLGDll, lsVCMFCDll, lsQTDll, lsEXE};
extern "C" __declspec(dllexport) void db_ShowDllForm_Plugins(TLangStyle* lsFileType, char** strParentName, char** strSubModuleName, char** strClassName, char** strWindowName, const bool show = false)
```

## �ģ�Dll �����������˵��
* Delphi ��
```
 procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName: PAnsiChar); stdcall;

 frm                 ��Delphi �� DLL ������������
 strParentModuleName ����ģ�����ƣ�
 strSubModuleName    ����ģ�����ƣ�
```
* VC2022/QT ��
```
extern "C" __declspec(dllexport) void db_ShowDllForm_Plugins(TLangStyle* lsFileType, char** strParentName, char** strSubModuleName, char** strClassName, char** strWindowName, const bool show = false)

 lsFileType        ���ǻ��� Dialog(�Ի���) �� DLL ���壬���ǻ��� MFC �� DLL ���壬���ǻ��� QT �� DLL ���壻
 strParentName     ����ģ�����ƣ�
 strSubModuleName  ����ģ�����ƣ�
 strClassName      ��DLL �������������
 strWindowName     ��DLL ������ı�������
 show              ����ʾ/���ش��壻
```

## �壺��ɫ����
    ����֧�֣��˵���ʽ��ʾ����ť���Ի��򣩷�ʽ��ʾ���б��ӷ�ʽ��ʾ��
    ֧�ֽ�һ�� EXE ���������ʾ�����ǵĴ����У�
    ֧�ִ���������̬�仯�� EXE��DLL ���� ����֧�ֶ��ĵ����壻
    ֧���ļ��Ϸ��� EXE��DLL ���壻
    ֧�� x86 EXE ���� x64 EXE��x64 EXE ���� x86 EXE��
    
## ������֪���ڵ�BUG��
    1���ļ��Ϸ�ֻ���Ϸŵ��������ϣ�����ֱ���Ϸŵ���ģ�� DLL �����У���������Ȩ����ɵ�����(��Դ����������ͨȨ�ޡ��� PBox �ǹ���ԱȨ��)��

## �ߣ�������������
    ������ݿ�֧�֣����ڱ��˶����ݿⲻ��Ϥ�����Կ�������������ҵ��ʱ�俪����;
    
## �ˣ�ע�����
   1��������� PBox(x64) ����� JavaCV ģ�飬��Ҫ��װ CUDA11 SDK������ CUDA11 SDK �� BIN Ŀ¼��ӵ�ϵͳ����·���У�
   2����Ϊ��ʼ��Java VM���� Delphi IDE �У��ᱨ�쳣��c0000005 ACCESS_VIOLATION��ѡ�� "Ignore this exception type"���´ξͲ�����ʾ�ˣ�
