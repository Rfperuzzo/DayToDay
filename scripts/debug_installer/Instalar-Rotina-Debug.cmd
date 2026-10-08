@echo off
setlocal
chcp 65001 >nul
title Instalador Debug - DayToDay

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_debug.ps1" %*
set "INSTALL_RESULT=%ERRORLEVEL%"

echo.
if not "%INSTALL_RESULT%"=="0" (
  echo A instalacao nao terminou. Confira a mensagem acima.
)
echo Pressione qualquer tecla para fechar.
pause >nul
exit /b %INSTALL_RESULT%
