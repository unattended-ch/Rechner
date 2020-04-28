@echo off
TITLE Creating Backup package
call purge.cmd
rem call setup.cmd
res\zip -uro9 backup\Tasch1.zip *.* -x *.dsm -x *.zip -x *_setup.exe -x *.o* -x *.ppu
res\dn backup\Tasch1.zip
pause