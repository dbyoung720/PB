1、正常编译 CMake，得到 LIB 文件、RES 文件、OBJ文件；
2、新建 Dll 导出函数 CPP 文件 cmake-gui.cpp，因为 QT 的入口点函数是 WinMain，所以和 VC Dialog Dll 一样，直接调用 WinMain 就可以了。
