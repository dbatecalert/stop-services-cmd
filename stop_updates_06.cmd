:: 
:: Copyright 2022 DBA Tec Alert, LLC
:: 
:: Tips to ETH 0x8b3477924e89be6f18817300d3fba9296878a9bb BTC 396ZCWzkPvUzcTrLBgcac42RyhJGX7dB5V
:: 
:: Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
:: 
:: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
:: 
:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
:: 

:: stop_updates

@echo off
setlocal enableextensions enabledelayedexpansion
set /a _exit_seconds = 5
set "_stop_all_and_disable_not_protected_services=test_stop_services.txt"
set "_ref_quoted_string=EMPTY"
set "_ref_start_time=EMPTY"
set "_scriptname=%~nx0"
set "_scriptdir=%~dp0"
set "_scriptdrive=%~d0"
set "_take_action=GO-WORK"
set /a _count_services = 0
set /a _running_services = 0
set /a _stopped_services = 0
set /a _protected_services = 0
set /a _notdisabled_notprotected = 0
cls

%_scriptdrive%
cd %_scriptdir%

echo:...
echo:... services info [%_stop_all_and_disable_not_protected_services%]
for /f "delims=" %%a in (%_stop_all_and_disable_not_protected_services%) do ( 
for /f "tokens=1,2 delims== " %%b in (' sc getkeyname %%a ^| find "=" ') do (
for /f "tokens=1,2,3 delims=: " %%d in (' sc query %%c ^| find "STATE" ') do (
for /f "tokens=1,2,3,4,5,6 delims=: " %%g in (' sc qprotection %%c ^| find "PROTECTION LEVEL:" ') do (
for /f "tokens=1,2,3 delims=: " %%m in (' sc qc %%c ^| find "START_TYPE" ') do (
  set /a _count_services +=1 
  IF /I %%f == RUNNING ( set /a _running_services +=1 & echo:%%f %%a ^(%%c^) ) ELSE ( set /a _stopped_services +=1 )
  IF /I %%k == NONE. (IF /I NOT %%o == DISABLED ( set /a _notdisabled_notprotected +=1 )) ELSE ( set /a _protected_services +=1 ) 
)))))
echo:... summary: found [%_count_services%] running [%_running_services%] notdisabled [%_notdisabled_notprotected%] stopped [%_stopped_services%] protected [%_protected_services%]
IF /I "%_running_services%" == "0" (IF /I "%_notdisabled_notprotected%" == "0" ( set "_take_action=STOP-NO-WORK" ))
::
:: PARAMETERS - { %%a "Update Orchestrator Service" },
::    { %%b Name, %%c UsoSvc },
::    { %%d STATE, %%e 4, %%f RUNNING },
::    { %%g SERVICE, %%h UsoSvc, %%i PROTECTION, %%j LEVEL, %%k WINDOWS, %%l LIGHT }, 
::    { %%m START_TYPE , %%n 2, %%o AUTO_START }
:: 
:: STATE - RUNNING, STOPPED, START_PENDING, STOP_PENDING
:: PROTECTION LEVEL - NONE, WINDOWS LIGHT, ANTIMALWARE LIGHT
:: START_TYPE - AUTO_START, DEMAND_START, DISABLED, AUTO_START (DELAYED) (boot|system|auto|demand|disabled|delayed-auto)

echo:...
echo:... protected services info (may be stopped but not disabled)
for /f "delims=" %%a in (%_stop_all_and_disable_not_protected_services%) do ( 
for /f "tokens=1,2 delims== " %%b in (' sc getkeyname %%a ^| find "=" ') do (
for /f "tokens=1,2,3 delims=: " %%d in (' sc query %%c ^| find "STATE" ') do (
for /f "tokens=1,2,3,4,5,6 delims=: " %%g in (' sc qprotection %%c ^| find /V "[SC]" ^| find /V "PROTECTION LEVEL: NONE" ') do (
for /f "tokens=1,2,3 delims=: " %%m in (' sc qc %%c ^| find "START_TYPE" ') do (
  echo:%%f %%a ^(%%c^)  START TYPE: %%o  PROTECTION LEVEL: %%k %%l
)))))
echo:...
::
:: PARAMETERS - { %%a "Update Orchestrator Service" },
::    { %%b Name, %%c UsoSvc },
::    { %%d STATE, %%e 4, %%f RUNNING },
::    { %%g SERVICE, %%h UsoSvc, %%i PROTECTION, %%j LEVEL, %%k WINDOWS, %%l LIGHT }, 
::    { %%m START_TYPE , %%n 2, %%o AUTO_START }
:: 
:: STATE - RUNNING, STOPPED, START_PENDING, STOP_PENDING
:: PROTECTION LEVEL - NONE, WINDOWS LIGHT, ANTIMALWARE LIGHT
:: START_TYPE - AUTO_START, DEMAND_START, DISABLED, AUTO_START (DELAYED) (boot|system|auto|demand|disabled|delayed-auto)

:: 
:: display GO-WORK but Administrator skips ahead, or display STOP-NO-WORK and exit
IF /I %_take_action% == GO-WORK ( call :sub_display_take_action_osk_pause_but_administrator_skips_ahead ) ELSE ( call :sub_display_take_action_delay_exit )

:: 
:: REQUIRE administrator
::   Some Windows User Account Control (UAC) options may cause failure or early exit - see REFERENCE(s).
::   UAC "no" exits, UAC "yes" cscript will "rerun (as administrator)" all above service info commands (by design)
if exist "%temp%\doadmin.vbs" del "%temp%\doadmin.vbs"
fsutil dirty query %systemdrive%  >nul 2>&1 && goto :(admin_priv_success)
cmd /u /c echo:Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "%~0", "", "", "runas", 1 > "%temp%\doadmin.vbs" & cscript //nologo "%temp%\doadmin.vbs" & exit
:: 
:: PARAMETERS - iRetVal = Shell.ShellExecute( _
::   sFile, _
::   [ ByVal vArguments ], _
::   [ ByVal vDirectory ], _
::   [ ByVal vOperation ], _
::   [ ByVal vShow ] _
:: )
:: vArguments - A string that contains parameter values for the operation.
:: vDirectory - The fully qualified path of the directory that contains the file specified by sFile. If this parameter is not specified, the current working directory is used.
:: *vOperation - The operation to be performed. This value is set to one of the verb strings that is supported by the file. For a discussion of verbs, see the Remarks section. If this parameter is not specified, the default operation is performed.
::   runas - Launches an application as Administrator. User Account Control (UAC) will prompt the user for consent to run the application elevated or enter the credentials of an administrator account used to run the application.
::   open - Launches an application. If this file is not an executable file, its associated application is launched.
:: *vShow - 1  Open the application with a normal window. If the window is minimized or maximized, the system restores it to its original size and position.
:: Remarks: This method is equivalent to launching one of the commands associated with a file's shortcut menu. Each command is represented by a verb string. 
:: 
:: EXAMPLE doadmin.vbs content
:: Set UAC = CreateObject("Shell.Application") : UAC.ShellExecute "C:\Windows\System32\_myScripts\this_script_name.cmd", "", "", "runas", 1 
:: 
:: REFERENCE(s):  
:: "Shell.ShellExecute method" - https://docs.microsoft.com/en-us/windows/win32/shell/shell-shellexecute
:: "Launching Applications (ShellExecute, ShellExecuteEx, SHELLEXECUTEINFO)" - https://docs.microsoft.com/en-us/windows/win32/shell/launch#object-verbs
:: "How User Account Control works" - https://docs.microsoft.com/en-us/windows/security/identity-protection/user-account-control/how-user-account-control-works

::----------------------------------------------
::-- Administrator privileges required below
::----------------------------------------------
:(admin_priv_success)
echo:... administrator granted

:: README - Windows Event Viewer logs service actions (ID 1)
eventcreate /T INFORMATION /SO %_scriptname% /ID 1 /L APPLICATION /D "Running service actions on services listed in %_stop_all_and_disable_not_protected_services% [%_scriptdir%]" >nul 2>&1

echo:... 
echo:... current directory is %CD% 

echo:...
echo:... stop running
for /f "delims=" %%a in (%_stop_all_and_disable_not_protected_services%) do ( 
for /f "tokens=1,2 delims== " %%b in (' sc getkeyname %%a ^| find "=" ') do (
for /f "tokens=1,2,3 delims=: " %%d in (' sc query %%c ^| find "STATE" ') do (
  (IF /I %%f == RUNNING ( 
    call :sub_escape_quoted_string %%a _ref_quoted_string
    call :sub_get_running_start_time_as_administrator %%c _ref_start_time
    call :sub_stopped_event_create_as_administrator %%f ^(%%c^)
    for /f "tokens=1,2,3 delims=: " %%g in (' sc stop %%c ^| find "STATE" ') do ( echo:%%i %%a ^(%%c^) )
  ))
)))
echo:... stop complete
:: 
:: PARAMETERS - { %%a "Update Orchestrator Service" }, 
::    { %%b Name, %%c UsoSvc },
::    { %%d STATE, %%e 4, %%f RUNNING }, 
::    { %%g STATE, %%h 3, %%i STOP_PENDING }
::
:: STATE - RUNNING, STOPPED, START_PENDING, STOP_PENDING

echo:...
echo:... disable notdisabled
for /f "delims=" %%a in (%_stop_all_and_disable_not_protected_services%) do ( 
for /f "tokens=1,2 delims== " %%b in (' sc getkeyname %%a ^| find "=" ') do (
for /f "tokens=1,2,3,4,5,6 delims=:. " %%d in (' sc qprotection %%c ^| find "PROTECTION LEVEL: NONE" ') do (
for /f "tokens=1,2,3 delims=: " %%j in (' sc qc %%c ^| find "START_TYPE" ') do (
  (IF /I NOT %%l == DISABLED ( 
      for /f "delims=" %%m in (' sc config %%c start^=disabled ^| find "SUCCESS" ') do ( echo:DISABLE: %%a ^(%%c^) PROTECTION: %%h %%i )
  ))
))))
echo:... disable complete
:: 
:: PARAMETERS - { %%a "Update Orchestrator Service" }, 
::    { %%b Name, %%c UsoSvc }, 
::    { %%d SERVICE, %%e UsoSvc, %%f PROTECTION, %%g LEVEL, %%h WINDOWS, %%i LIGHT },
::    { %%j START_TYPE, %%k 3, %%l DEMAND_START }, 
::    { %%m [SC] ChangeServiceConfig SUCCESS }
::
:: START_TYPE - AUTO_START, DEMAND_START, DISABLED, AUTO_START (DELAYED) (boot|system|auto|demand|disabled|delayed-auto)
:: PROTECTION LEVEL - NONE, WINDOWS LIGHT, ANTIMALWARE LIGHT

:: 
:: README - allow users to see results
call :sub_display_take_action_delay_exit

:(ready_to_exit)
endlocal
@echo on
exit

::----------------------------------------------
::-- sub routines
::----------------------------------------------

::--------------------------------------------------------
:sub_display_take_action_osk_pause_but_administrator_skips_ahead
fsutil dirty query %systemdrive%  >nul 2>&1 && goto :(admin_priv_success)
:: otherwise non-administrator UAC is manual only, osk for mouse only operation
echo:%_take_action% toggle admin or exit manually ... & start osk & pause
exit /B

::--------------------------------------------------------
:sub_display_take_action_delay_exit
echo:%_take_action% exiting timer ... & timeout /t %_exit_seconds% & goto :(ready_to_exit)
exit /B
  
::--------------------------------------------------------
:sub_escape_quoted_string
set "%~2=INSIDE_SUB_ESCAPE_QUOTED"
set "%~2=\"%~1\""
:: 
:: PARAMETERS - { %1 "Update Orchestrator Service", %2 _ref_quoted_string }, 
::    { %_ref_quoted_string% EMPTY -> INSIDE_SUB_ESCAPE_QUOTED -> \"Update Orchestrator Service\" }
:: 
:: REFERENCE(s):  
::   "Passing by Reference" - https://ss64.com/nt/call.html
exit /B

::--------------------------------------------------------
:sub_get_running_start_time_as_administrator
set "%~2=INSIDE_SUB_GET_RUNNING"
for /f "tokens=1,2 delims=: " %%a in (' sc queryex %1 ^| find "PID" ') do ( 
for /f "tokens=1,2,3,4,5 delims==}" %%c in (' powershell "get-process | select name, id, starttime | select-string %%b" ^| find "StartTime=" ') do (
  set "%~2=[StartTime %%f]"
))
:: 
:: PARAMETERS - { %1 UsoSvc, %2 _ref_start_time },
::    { %_ref_start_time% EMPTY -> INSIDE_SUB_GET_RUNNING -> [StartTime 05/02/2022 19:02:25] },
::    { %%a PID, %%b 6028 }, 
::    { %%c "@{Name", %%d "svchost; Id", %%e "8396; StartTime", %%f "05/02/2022 16:44:48, %%g "" }
:: 
:: REFERENCE(s):  
::   "Passing by Reference" - https://ss64.com/nt/call.html
:: 
:: EXAMPLE: 
::   sc queryex usosvc | find "PID"
::   powershell "get-process | select name, id, starttime | select-string 6028" | find "StartTime="
exit /B

::--------------------------------------------------------
:sub_stopped_event_create_as_administrator
:: README - Windows Event Viewer logs stopped actions (ID 10)
eventcreate /T INFORMATION /SO %_scriptname% /ID 10 /L APPLICATION /D "Stopped %1 %_ref_quoted_string% %2 %_ref_start_time%" >nul 2>&1
:: 
:: PARAMETERS - { %1 RUNNING, %2 (UsoSvc) }, 
::    { %_ref_quoted_string% \"Update Orchestrator Service\" }, 
::    { %_ref_start_time% [StartTime 05/02/2022 19:02:25] }
::
:: REFERENCE(s):  
::   "Passing by Reference" - https://ss64.com/nt/call.html
exit /B

