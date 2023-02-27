@echo off
setlocal enabledelayedexpansion
color A

set CurrentCD=%~dp0

:: VS2022 编译
SET "PARAMS=-property installationPath -requires Microsoft.Component.MSBuild Microsoft.VisualStudio.Component.VC.ATLMFC Microsoft.VisualStudio.Component.VC.Tools.x86.x64  -latest -prerelease -version [,17.0)"
set "VS2022=vswhere.exe %PARAMS%"
FOR /f "delims=" %%A IN ('!VS2022!') DO SET "VCVARS=%%A\VC\Auxiliary\Build\vcvars32.bat"
CALL "%VCVARS%"

:: 修改源码
CD /D %CurrentCD%SRC
git apply -v %CurrentCD%NP2.patch 

:: 编译原有的 NOTEPAD2 源码
call %CurrentCD%SRC\Build\build_vs2017.bat /Build /x86 /Release

:: 编译 NP2.CPP
CD /D %CurrentCD%
cl /c  /Zi /nologo /W3 /WX- /diagnostics:classic /O2 /Oy- /GL /D WIN32 /D STATIC_BUILD /D BOOKMARK_EDITION /D NDEBUG /D _CRT_SECURE_NO_WARNINGS /D _UNICODE /D UNICODE /Gm- /EHsc /MT /GS /arch:SSE2 /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /Gd /analyze- /FC  %CurrentCD%NP2.cpp

:: 与原来编译 EXE 产生出的 OBJ/LIB/RES 一起，连接为动态库
link /dll -out:NP2.dll /DELAYLOAD:mpr.dll -nologo -RELEASE -OPT:REF -OPT:ICF -LTCG /LARGEADDRESSAWARE /FIXED:NO NP2.obj %CurrentCD%SRC\bin\VS2017\Release_x86\obj\*.obj %CurrentCD%notepad2.res %CurrentCD%SRC\bin\VS2017\Release_x86\obj\scintilla\Scintilla.lib imm32.lib Shlwapi.lib Comctl32.lib Msimg32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib OpenGL32.Lib

:: 复制到 PBox plugins 目录下
copy /Y NP2.dll ..\..\bin\Win32\plugins\NP2.dll

:: 还原源码
CD /D %CurrentCD%SRC
git clean -d  -fx -f 
git checkout .

:: 删除临时文件
CD /D %CurrentCD%
del NP2.dll
del NP2.exp
del NP2.lib
del NP2.obj
del vc140.pdb
