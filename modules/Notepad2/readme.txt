1、正常编译 Notepad2，得到 LIB 文件、RES 文件、OBJ文件；
2、新建 DLL 导出函数 CPP 文件 NP2.cpp，因为 VC Dialog EXE 的入口点函数是 WinMain，导出函数直接调用 WinMain 就可以了。
