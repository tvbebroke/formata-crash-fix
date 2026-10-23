@echo off
rem Undo the Formata crash fix.
reg delete "HKCU\Environment" /v OPENSSL_ia32cap /f
echo.
echo Removed. Restart Steam for it to take effect.
pause
