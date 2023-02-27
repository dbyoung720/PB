@echo off
setlocal enabledelayedexpansion
Color A

set CurrentCD=%~dp0

:: VS2022 ����
SET "PARAMS=-property installationPath -requires Microsoft.Component.MSBuild Microsoft.VisualStudio.Component.VC.ATLMFC Microsoft.VisualStudio.Component.VC.Tools.x86.x64  -latest -prerelease -version [,17.0)"
set "VS2022=vswhere.exe %PARAMS%"
FOR /f "delims=" %%A IN ('!VS2022!') DO SET "VCVARS=%%A\VC\Auxiliary\Build\vcvars64.bat"
CALL "%VCVARS%"

:: ����ԭ�е� 7zip Դ��
CD /D %CurrentCD%src\CPP\7zip
set CL=/MP
nmake

:: ���� 7zFM.CPP
CD /D %CurrentCD%
cl /c  /Zi /nologo /W3 /WX- /diagnostics:classic /O2 /Oy- /GL /D WIN32 /D STATIC_BUILD /D BOOKMARK_EDITION /D NDEBUG /D _CRT_SECURE_NO_WARNINGS /D _UNICODE /D UNICODE /Gm- /EHsc /MT /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /Gd /analyze- /FC  %CurrentCD%7zFM.cpp

:: ��ԭ������ EXE �������� OBJ/LIB/RES һ������Ϊ��̬��
link /dll -out:7zFM.dll /DELAYLOAD:mpr.dll -nologo -RELEASE -OPT:REF -OPT:ICF -LTCG /LARGEADDRESSAWARE /FIXED:NO 7zFM.obj %CurrentCD%src\CPP\7zip\Bundles\FM\x64\*.obj %CurrentCD%src\CPP\7zip\Bundles\FM\x64\resource.res comctl32.lib htmlhelp.lib comdlg32.lib Mpr.lib Gdi32.lib delayimp.lib oleaut32.lib ole32.lib user32.lib advapi32.lib shell32.lib

:: ���Ƶ� PBox plugins Ŀ¼��
copy /Y 7zFM.dll ..\..\bin\Win64\plugins\7-zip.dll

:: ɾ����ʱ�ļ�
del 7zFM.dll
del 7zFM.exp
del 7zFM.lib
del 7zFM.obj
del vc140.pdb

pause
