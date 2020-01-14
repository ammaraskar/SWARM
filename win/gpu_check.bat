@echo off
cd %SWARM_DIR%

pwsh -command ".\scripts\gpu_check.ps1 %*"
