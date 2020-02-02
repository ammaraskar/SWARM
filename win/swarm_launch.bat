@echo off
CLS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                    Add Program Arguments Below                        ::
::                            example:                                   ::
:: set ARGUMENTS="-location USA -Wallet 1Drusdflq34Seksdljrugj34sdrf321" ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set ARGUMENTS=-location USA -wallet mywallets.test

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                      DO NOT EDIT BELOW HERE                           ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::
:: Automatically check & get admin rights V2
::::::::::::::::::::::::::::::::::::::::::::
@echo off
ECHO.
ECHO =============================
ECHO Running Admin shell
ECHO =============================

:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO.
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

setlocal EnableDelayedExpansion
if [%1]==[] (
    set PARAMETERS=!ARGUMENTS!
) else (
    set COMMANDS=%*
    for /f "tokens=1,* delims= " %%a in ("!COMMANDS!") do set PARAMETERS=%%b 
)

cd /D "%~dp0"

pwsh -executionpolicy bypass -windowstyle normal -noexit -command "Set-Location ..; .\scripts\swarm.ps1 %PARAMETERS%"