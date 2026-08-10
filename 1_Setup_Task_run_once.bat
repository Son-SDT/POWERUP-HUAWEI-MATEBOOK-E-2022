@echo off
:: =====================================================================
:: CHI CHAY FILE NAY 1 LAN DUY NHAT. Run as administrator.
:: Monitor gio dung PowerShell (monitor.ps1) thay vi .bat - on dinh hon
:: nhieu trong Task Scheduler, va -WindowStyle Hidden an cua so that su.
:: =====================================================================
setlocal
set "ScriptDir=%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [LOI] Phai chay bang quyen Administrator! Chuot phai -^> Run as administrator.
    pause
    exit /b 1
)

echo Dang xoa task cu (neu co)...
schtasks /Delete /TN "ThrottleStop_Elevated" /F >nul 2>&1
schtasks /Delete /TN "ThrottleStop_Monitor" /F >nul 2>&1

echo.
echo [1/2] Tao task chay ThrottleStop.exe...
powershell -NoProfile -Command ^
  "$action = New-ScheduledTaskAction -Execute '%ScriptDir%ThrottleStop.exe';" ^
  "$trigger = New-ScheduledTaskTrigger -AtLogOn;" ^
  "$principal = New-ScheduledTaskPrincipal -UserId \"$env:USERDOMAIN\$env:USERNAME\" -RunLevel Highest -LogonType Interactive;" ^
  "$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit ([TimeSpan]::Zero);" ^
  "Register-ScheduledTask -TaskName 'ThrottleStop_Elevated' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null;" ^
  "Write-Host '  [OK] ThrottleStop_Elevated da tao.'"

echo.
echo [2/2] Tao task chay Monitor (PowerShell, an cua so, quyen cao)...
powershell -NoProfile -Command ^
  "$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%ScriptDir%monitor.ps1\"' -WorkingDirectory '%ScriptDir%';" ^
  "$trigger = New-ScheduledTaskTrigger -AtLogOn;" ^
  "$principal = New-ScheduledTaskPrincipal -UserId \"$env:USERDOMAIN\$env:USERNAME\" -RunLevel Highest -LogonType Interactive;" ^
  "$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew;" ^
  "Register-ScheduledTask -TaskName 'ThrottleStop_Monitor' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null;" ^
  "Write-Host '  [OK] ThrottleStop_Monitor da tao.'"

echo.
echo ===================================================================
echo   HOAN TAT. Chay ngay: schtasks /Run /TN "ThrottleStop_Monitor"
echo   (Lan nay se KHONG hien cua so nao ca - chay hoan toan an)
echo ===================================================================
echo.
pause
