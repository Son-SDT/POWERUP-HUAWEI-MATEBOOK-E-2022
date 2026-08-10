# [VIETNAMESE BELOW]
# POWERUP-HUAWEI-MATEBOOK-E-2022

Automatically switch [ThrottleStop](https://throttlestop.net) power profiles based on AC/Battery status — no more manually toggling profiles every time you plug or unplug the charger.

Built for the **Huawei MateBook E 2022**, but works on any laptop where you want ThrottleStop to auto-switch between an AC profile and a Battery profile.

("PowerUp" here means making the Huawei MateBook E 2022 more powerful — it has no relation to TechPowerUp.)

## 1. Results

- Default **9W → 15W** (when plugged in via ThrottleStop): LOL goes from **3x-4x fps → 6x-9x fps**
- Temperature: **6x°C → 7x°C**
- Tested on **Windows 10 LTSC**
- Note: sit in a cool/air-conditioned room for the best thermal results when raising the power limit

## 2. Setup

**Step 1** — Download ThrottleStop from [throttlestop.net](https://throttlestop.net)

**Step 2** — Clone this repository
```
git clone https://github.com/Son-SDT/POWERUP-HUAWEI-MATEBOOK-E-2022.git
```

**Step 3** — Copy `ThrottleStop.exe` into the cloned folder:
```
./POWERUP-HUAWEI-MATEBOOK-E-2022/ThrottleStop.exe
```

**Step 4** — Right-click `1_Setup_Task_run_once.bat` → **Run as administrator**

**Step 5** — Restart your PC, or run immediately:
```
schtasks /Run /TN "ThrottleStop_Monitor"
```

## 3. How the script works

The system has 2 main parts, running fully in the background — no windows, no popups:

**a) `monitor.ps1`** — an infinite loop that, every **5 seconds**:
- Checks whether the laptop is on **AC** or **Battery** (calls the `GetSystemPowerStatus` WinAPI directly — very lightweight, negligible RAM/CPU usage)
- Compares it to the state from the previous check
- If **unchanged** → does nothing, just makes sure ThrottleStop is still running (auto-restarts it if it was closed or crashed)
- If **changed** (charger just plugged in/unplugged):
  1. Closes the currently running ThrottleStop
  2. Copies the matching `.ini` file (`ThrottleStop_AC.ini` or `ThrottleStop_Battery.ini`) over `ThrottleStop.ini`
  3. Relaunches ThrottleStop with the new profile

**b) 2 Scheduled Tasks** (created by `1_Setup_Task_run_once.bat`, with Admin rights):
- `ThrottleStop_Elevated` — dedicated to launching `ThrottleStop.exe` with elevated rights, without showing a UAC popup
- `ThrottleStop_Monitor` — runs `monitor.ps1` hidden in the background, with elevated rights (needed to close a ThrottleStop instance running as Admin), auto-starting on every Windows login

Because the 2 tasks are split this way, relaunching ThrottleStop on every profile switch **never shows a "Yes" UAC popup**, and the whole process takes under 2 seconds, completely silently.

## Uninstall
```
schtasks /Delete /TN "ThrottleStop_Elevated" /F
schtasks /Delete /TN "ThrottleStop_Monitor" /F
```
Then delete the project folder.

## Disclaimer

This project only automates launching and configuring ThrottleStop — it doesn't modify or redistribute ThrottleStop itself. ThrottleStop directly adjusts CPU power limits and voltage-related settings; use at your own risk, and make sure you understand what your `.ini` values do before applying them. Not affiliated with TechPowerUp or the ThrottleStop developer.

---



# POWERUP-HUAWEI-MATEBOOK-E-2022

Tự động chuyển profile [ThrottleStop](https://throttlestop.net) theo trạng thái Sạc/Pin — không cần tự tay đổi profile mỗi lần cắm/rút sạc nữa.

Làm cho **Huawei MateBook E 2022**, nhưng dùng được cho bất kỳ laptop nào muốn ThrottleStop tự đổi giữa profile AC và profile Pin.

("PowerUp" ở đây nghĩa là làm cho Huawei MateBook E 2022 mạnh hơn, không liên quan gì tới TechPowerUp.)

## 1. Hiệu quả

- Mặc định **9W → 15W** (khi cắm sạc, qua ThrottleStop): LOL từ **3x-4x fps → 6x-9x fps**
- Nhiệt lượng: **6x°C → 7x°C**
- Đã test trên **Windows 10 LTSC**
- Lưu ý: nên ngồi phòng lạnh (mát) để đạt hiệu quả tản nhiệt tốt nhất khi tăng power limit

## 2. Cách setup

**Bước 1** — Tải ThrottleStop tại [throttlestop.net](https://throttlestop.net)

**Bước 2** — Clone repo này:
```
git clone https://github.com/Son-SDT/POWERUP-HUAWEI-MATEBOOK-E-2022.git
```

**Bước 3** — Copy `ThrottleStop.exe` vào thư mục vừa clone:
```
./POWERUP-HUAWEI-MATEBOOK-E-2022/ThrottleStop.exe
```

**Bước 4** — Chuột phải `1_Setup_Task_run_once.bat` → **Run as administrator**

**Bước 5** — Khởi động lại máy, hoặc chạy ngay:
```
schtasks /Run /TN "ThrottleStop_Monitor"
```

## 3. Cách hoạt động của script

Hệ thống gồm 2 phần chính, chạy hoàn toàn nền, không hiện cửa sổ, không popup:

**a) `monitor.ps1`** — vòng lặp chạy mãi mãi, cứ mỗi **5 giây**:
- Kiểm tra máy đang **Sạc** hay **Pin** (gọi thẳng WinAPI `GetSystemPowerStatus`, rất nhẹ, không tốn RAM/CPU)
- So với trạng thái lần kiểm tra trước
- Nếu **không đổi** → không làm gì, chỉ đảm bảo ThrottleStop vẫn đang chạy (tự khởi động lại nếu bị tắt/crash)
- Nếu **có đổi** (vừa cắm/rút sạc):
  1. Tắt ThrottleStop hiện tại
  2. Copy đúng file `.ini` tương ứng (`ThrottleStop_AC.ini` hoặc `ThrottleStop_Battery.ini`) đè lên `ThrottleStop.ini`
  3. Khởi động lại ThrottleStop với profile mới

**b) 2 Scheduled Task** (được tạo bởi `1_Setup_Task_run_once.bat`, quyền Admin):
- `ThrottleStop_Elevated` — chuyên dùng để mở `ThrottleStop.exe` với quyền cao, không hiện popup UAC
- `ThrottleStop_Monitor` — chạy `monitor.ps1` ẩn ở nền, quyền cao (để có quyền tắt được ThrottleStop đang chạy Admin), tự khởi động mỗi lần đăng nhập Windows

Nhờ tách 2 Task như vậy, việc mở lại ThrottleStop mỗi lần đổi profile **không bao giờ hiện popup "Yes"**, và toàn bộ quá trình diễn ra trong chưa đầy 2 giây, hoàn toàn im lặng.

## Gỡ cài đặt
```
schtasks /Delete /TN "ThrottleStop_Elevated" /F
schtasks /Delete /TN "ThrottleStop_Monitor" /F
```
Sau đó xóa thư mục project.

## Lưu ý

Project này chỉ tự động hóa việc mở và cấu hình ThrottleStop — không chỉnh sửa hay phân phối lại ThrottleStop. ThrottleStop can thiệp trực tiếp vào power limit và điện áp CPU; tự chịu trách nhiệm khi sử dụng, hãy hiểu rõ ý nghĩa các giá trị trong file `.ini` trước khi áp dụng. Không liên kết với TechPowerUp hay tác giả ThrottleStop.
