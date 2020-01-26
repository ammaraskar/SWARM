@echo off
cd %SWARM_DIR%

pwsh -command ".\scripts\rig_check.ps1 %*"