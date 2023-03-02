@echo off

call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"

cd..
cd bin

lib /def:"..\lib\avcodec-60.def"   /machine:amd64 /out:"..\lib\avcodec-60.lib"
lib /def:"..\lib\avdevice-60.def"  /machine:amd64 /out:"..\lib\avdevice-60.lib"
lib /def:"..\lib\avformat-60.def"  /machine:amd64 /out:"..\lib\avformat-60.lib"
lib /def:"..\lib\avutil-58.def"    /machine:amd64 /out:"..\lib\avutil-58.lib"
lib /def:"..\lib\avfilter-9.def"   /machine:amd64 /out:"..\lib\avfilter-9.lib"
lib /def:"..\lib\postproc-57.def"  /machine:amd64 /out:"..\lib\postproc-57.lib"
lib /def:"..\lib\swresample-4.def" /machine:amd64 /out:"..\lib\swresample-4.lib"
lib /def:"..\lib\swscale-7.def "   /machine:amd64 /out:"..\lib\swscale-7.lib"
