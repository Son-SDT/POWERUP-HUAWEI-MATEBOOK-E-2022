# Script theo doi trang thai sac/pin, doi profile ThrottleStop khi can.
# Dung thang WinAPI GetSystemPowerStatus (kernel32.dll) - nhe nhat co the,
# khong can nap them assembly nao (kernel32 da co san trong moi tien trinh).

$sig = @"
[StructLayout(LayoutKind.Sequential)]
public struct SYSTEM_POWER_STATUS {
    public byte ACLineStatus;
    public byte BatteryFlag;
    public byte BatteryLifePercent;
    public byte SystemStatusFlag;
    public int BatteryLifeTime;
    public int BatteryFullLifeTime;
}
[DllImport("kernel32.dll")]
public static extern bool GetSystemPowerStatus(out SYSTEM_POWER_STATUS sps);
"@
Add-Type -MemberDefinition $sig -Name "PowerAPI" -Namespace "Win32"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$StatusFile = Join-Path $ScriptDir "power_status.tmp"
$LogFile = Join-Path $ScriptDir "monitor.log"
$TaskName = "ThrottleStop_Elevated"

Add-Content -Path $LogFile -Value "[$(Get-Date)] ===== Monitor PS1 bat dau chay ====="

$loopCount = 0

while ($true) {
    try {
        $sps = New-Object Win32.PowerAPI+SYSTEM_POWER_STATUS
        [Win32.PowerAPI]::GetSystemPowerStatus([ref]$sps) | Out-Null

        # ACLineStatus: 0 = dang dung Pin, 1 = dang Sac (AC), 255 = khong xac dinh
        if ($sps.ACLineStatus -eq 1) {
            $currentStatus = "1"
        } else {
            $currentStatus = "0"
        }

        $oldStatus = ""
        if (Test-Path $StatusFile) {
            $oldStatus = (Get-Content $StatusFile -Raw -ErrorAction SilentlyContinue)
            if ($oldStatus) { $oldStatus = $oldStatus.Trim() }
        }

        if ($currentStatus -eq $oldStatus) {
            $proc = Get-Process -Name "ThrottleStop" -ErrorAction SilentlyContinue
            if (-not $proc) {
                Add-Content -Path $LogFile -Value "[$(Get-Date)] Khong doi ($currentStatus) nhung ThrottleStop KHONG chay -> khoi dong lai"
                schtasks /Run /TN $TaskName | Out-Null
            }
        } else {
            Add-Content -Path $LogFile -Value "[$(Get-Date)] THAY DOI trang thai: $oldStatus -> $currentStatus"

            Stop-Process -Name "ThrottleStop" -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1

            if ($currentStatus -eq "1") {
                $srcIni = Join-Path $ScriptDir "ThrottleStop_AC.ini"
                Add-Content -Path $LogFile -Value "[$(Get-Date)] Da copy ThrottleStop_AC.ini"
            } else {
                $srcIni = Join-Path $ScriptDir "ThrottleStop_Battery.ini"
                Add-Content -Path $LogFile -Value "[$(Get-Date)] Da copy ThrottleStop_Battery.ini"
            }

            # Doc file .ini nguon, thay placeholder {SCRIPTDIR} bang duong dan
            # thuc te (tu dong theo dung user/may dang chay, khong hardcode)
            $iniContent = Get-Content -Path $srcIni -Raw
            $iniContent = $iniContent -replace [regex]::Escape("{SCRIPTDIR}"), $ScriptDir
            Set-Content -Path (Join-Path $ScriptDir "ThrottleStop.ini") -Value $iniContent -NoNewline

            schtasks /Run /TN $TaskName | Out-Null
            Set-Content -Path $StatusFile -Value $currentStatus -NoNewline
            Add-Content -Path $LogFile -Value "[$(Get-Date)] Da luu trang thai moi: $currentStatus"
        }
    } catch {
        Add-Content -Path $LogFile -Value "[$(Get-Date)] LOI: $_"
    }

    $loopCount++
    if ($loopCount % 720 -eq 0) {
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
    }

    Start-Sleep -Seconds 5
}
