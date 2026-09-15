@echo off
start /D %~dp0 /HIGH /WAIT pnputil.exe -a %~dp0SynPD.inf /install
pause