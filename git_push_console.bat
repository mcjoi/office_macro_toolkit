@echo off
setlocal
set "SCRIPT=%~dp0push.bat"
start "Git Push Console" cmd /k "%SCRIPT%"
endlocal
