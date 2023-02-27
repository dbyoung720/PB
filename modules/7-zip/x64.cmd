@echo off
setlocal enabledelayedexpansion
Color A

set CurrentCD=%~dp0

:: VS2022 编译
SET "PARAMS=-property installationPath -requires Microsoft.Component.MSBuild Microsoft.VisualStudio.Component.VC.ATLMFC Microsoft.VisualStudio.Component.VC.Tools.x86.x64  -latest -prerelease -version [,17.0)"
set "VS2022=vswhere.exe %PARAMS%"
FOR /f "delims=" %%A IN ('!VS2022!') DO SET "VCVARS=%%A\VC\Auxiliary\Build\vcvars64.bat"
CALL "%VCVARS%"

:: 编译原有的 7zip 源码
CD /D %CurrentCD%src\CPP\7zip
set CL=/MP
nmake

:: 编译 7zFM.CPP
CD /D %CurrentCD%
cl /c  /Zi /nologo /W3 /WX- /diagnostics:classic /O2 /Oy- /GL /D WIN32 /D STATIC_BUILD /D BOOKMARK_EDITION /D NDEBUG /D _CRT_SECURE_NO_WARNINGS /D _UNICODE /D UNICODE /Gm- /EHsc /MT /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /Gd /analyze- /FC  %CurrentCD%7zFM.cpp

:: 与原来编译 EXE 产生出的 OBJ/LIB/RES 一起，连接为动态库
link /dll -out:7zFM.dll /DELAYLOAD:mpr.dll -nologo -RELEASE -OPT:REF -OPT:ICF -LTCG /LARGEADDRESSAWARE /FIXED:NO 7zFM.obj %CurrentCD%src\CPP\7zip\Bundles\FM\x64\*.obj %CurrentCD%src\CPP\7zip\Bundles\FM\x64\resource.res comctl32.lib htmlhelp.lib comdlg32.lib Mpr.lib Gdi32.lib delayimp.lib oleaut32.lib ole32.lib user32.lib advapi32.lib shell32.lib

:: 复制到 PBox plugins 目录下
copy /Y 7zFM.dll ..\..\bin\Win64\plugins\7-zip.dll

:: 删除临时文件
del 7zFM.dll
del 7zFM.exp
del 7zFM.lib
del 7zFM.obj
del vc140.pdb

pause
