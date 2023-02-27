@echo off
setlocal enabledelayedexpansion
color A

set CurrentCD=%~dp0

:: VS2022 编译
SET "PARAMS=-property installationPath -requires Microsoft.Component.MSBuild Microsoft.VisualStudio.Component.VC.ATLMFC Microsoft.VisualStudio.Component.VC.Tools.x86.x64  -latest -prerelease -version [,17.0)"
set "VS2022=vswhere.exe %PARAMS%"
FOR /f "delims=" %%A IN ('!VS2022!') DO SET "VCVARS=%%A\VC\Auxiliary\Build\vcvars32.bat"
CALL "%VCVARS%"

:: 解压相关库
CD /D %CurrentCD%
CD..
set LastCD=%CD%
call %LastCD%\temp\7z x -o"%CurrentCD%" "%CurrentCD%Patch\x86.7z" -y

:: 编译 cmake-gui.cpp 文件
CD /D %CurrentCD%
cl /c  /Zi /nologo /W3 /WX- /diagnostics:classic /O2 /Oy- /GL /D WIN32 /D STATIC_BUILD /D BOOKMARK_EDITION /D NDEBUG /D _CRT_SECURE_NO_WARNINGS /D _UNICODE /D UNICODE /Gm- /EHsc /MT /GS /arch:SSE2 /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /Gd /analyze- /FC  %CurrentCD%cmake-gui.cpp

:: 连接得到 DLL 文件
link /dll /OUT:cmake-gui.dll ^
  /INCREMENTAL:NO ^
  /NOLOGO ^
  /MANIFEST ^
  /MANIFESTUAC:"level='asInvoker' uiAccess='false'" ^
  /manifest:embed ^
  /SUBSYSTEM:WINDOWS ^
  /TLBID:1 ^
  /DYNAMICBASE ^
  /NXCOMPAT ^
  /MACHINE:X86 ^
  /machine:X86 -stack:10000000 ^
  cmake-gui.obj ^
  x86\*.* ^
  /SAFESEH  ^
 dbghelp.lib winmm.lib advapi32.lib comdlg32.lib crypt32.lib d2d1.lib d3d11.lib dwmapi.lib dwrite.lib dxgi.lib dxguid.lib gdi32.lib glu32.lib imm32.lib iphlpapi.lib kernel32.lib mpr.lib ^
 netapi32.lib ole32.lib oleaut32.lib opengl32.lib psapi.lib rpcrt4.lib shell32.lib shlwapi.lib user32.lib  userenv.lib uuid.lib uxtheme.lib version.lib winmm.lib winspool.lib ws2_32.lib wtsapi32.lib

:: 复制文件到插件目录
copy /Y cmake-gui.dll ..\..\bin\Win32\plugins\cmake.dll

:: 删除临时文件
del cmake-gui.dll
del cmake-gui.exp
del cmake-gui.lib
del cmake-gui.obj
del vc140.pdb

pause
