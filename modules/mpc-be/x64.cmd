set CurrentCD=%~dp0

:: ���û�������
set MPCBE_MSYS=F:\Green\Language\MSYS_MPC
set MPCBE_MINGW=F:\Green\Language\MSYS_MPC\mingw
set Path=F:\Green\Language\GIT\TortoiseSVN\bin;%Path%

:: ���� x64
CD /D %CurrentCD%SRC
call build x64 Release

:: �����ļ�
CD /D %CurrentCD%
copy /Y SRC\bin\mpc-be_x64\mpc-be64.dll               ..\..\bin\Win64\plugins\mpc-be.dll
copy /Y SRC\bin\mpc-be_x64\Lang\mpcresources.sc.dll ..\..\bin\Win64\plugins\Lang\mpcresources.sc.dll

pause
