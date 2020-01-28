@echo off
cd %SWARM_DIR%

pwsh -command ".\scripts\configs_check.ps1 %*"