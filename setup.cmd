@echo off
res\ReadVersion.exe tasch1.exe res\Version.nsh
TITLE Creating Setup package
call purge.cmd
"c:\Program Files (x86)\NSIS\makensis.exe" /V4 Res\Tasch1.nsi
pause
