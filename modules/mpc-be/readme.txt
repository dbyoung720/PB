1���� MFC EXE ���޸�Ϊ MFC DLL��
2���޸� CMPlayerCApp::InitInstance()��
3����� Dll ����������

ע��
  ����Ҫ�޸�һЩ��������Ϊ EXE �� DLL ����޸�����С��
  1��ģ������һ�� EXE �У�ģ�������Լ�����������һ�����Ϊ�ա�DLL �У��Ͳ����ˡ����޸ģ�
  2������λ�ã�һЩ���򣬶����ڳ��򴴽�ʱ�����ô���λ�á������Ҫɾ������
  3��MPC-BE Դ�����У�Detour ����û���ͷţ����ͷŵ���
  4��ʹ�õ� MPC-BE �汾 5500��
  5��MPC-BE Դ���ַ��https://svn.code.sf.net/p/mpcbe/code/trunk



MFC ��װ

    MFC EXE

      _tWinMain    ---> AfxWinMain  ---> pThread->InitInstance
                                                 ��
                                                 ��
      appmodul.cpp ---> winmain.cpp ---> �û�����(CxxxApp::InitInstance��CxxxApp �̳��� CWinApp)
     ��-------> ϵͳ��װ�Ĵ��� <------ ��
     ��   �⣺  nafxcw.lib (ANSI)      ��
     ��   �⣺  uafxcw.lib (UNICODE)   ��




    MFC DLL (��̬��׼MFC DLL)
    
      DllMain  ---> InternalDllMain ---> InitInstance
                                             ��
                                             ��
       dllmodul.cpp -------------------> �û�����(InitInstance)
     ��-------> ϵͳ��װ�Ĵ��� <------ ��
     ��   �⣺  nafxcw.lib (ANSI)      ��
     ��   �⣺  uafxcw.lib (UNICODE)   ��



   �������������Щ��������������������������Щ���������������������������������
   ��          ��          SDK		       ��		          MFC            ��
   �������������੤�����������Щ������������੤�������������Щ�����������������
   ��          ��    EXE     ��   DLL      ��     EXE      ��   DLL          ��
   �������������੤�����������੤�����������੤�������������੤����������������
   �� DEBUG    ��LIBCMTD.LIB ��MSVCRTD.LIB ��              ��                ��
   �������������੤�����������੤�����������੤�������������੤����������������
   �� RELEASE  ��LIBCMT.LIB  ��MSVCRT.LIB  ��              ��                ��
   �������������ة������������ة������������ة��������������ة�����������������

C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\MSVC\14.27.29110\atlmfc\src\mfc
