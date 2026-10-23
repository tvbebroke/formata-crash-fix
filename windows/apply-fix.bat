@echo off
rem Formata crash fix: stop the game's old OpenSSL from using the buggy SHA-extension code path.
setx OPENSSL_ia32cap ":~0x20000000"
echo.
echo Done. Fully exit and restart Steam, then launch Formata.
pause
