@echo off
cd %SWARM_DIR%

pwsh -command ".\scripts\lspci.ps1 %*"