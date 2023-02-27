set CurrentCD=%~dp0

:: 设置环境变量
set MPCBE_MSYS=F:\Green\Language\MSYS_MPC
set MPCBE_MINGW=F:\Green\Language\MSYS_MPC\mingw
set Path=F:\Green\Language\GIT\TortoiseSVN\bin;%Path%

:: 编译 x86
CD /D %CurrentCD%SRC
call build Win32 Release

:: 复制文件
CD /D %CurrentCD%
copy /Y SRC\bin\mpc-be_x86\mpc-be.dll               ..\..\bin\Win32\plugins\mpc-be.dll
copy /Y SRC\bin\mpc-be_x86\Lang\mpcresources.sc.dll ..\..\bin\Win32\plugins\Lang\mpcresources.sc.dll

pause
