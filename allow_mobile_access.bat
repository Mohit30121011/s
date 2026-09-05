@echo off
echo ===================================================
echo   NLogistic - Allowing Mobile Phone Access (Port 8080)
echo ===================================================
echo.
echo 1. Opening Port 8080 in Windows Firewall...
netsh advfirewall firewall add rule name="Tomcat 8080 NLogistic" dir=in action=allow protocol=TCP localport=8080
netsh advfirewall firewall add rule name="Tomcat 8080 NLogistic Out" dir=out action=allow protocol=TCP localport=8080

echo 2. Setting Wi-Fi to Private network...
powershell -Command "Set-NetConnectionProfile -Name 'ROSHAN_5G' -NetworkCategory Private -ErrorAction SilentlyContinue"

echo.
echo ===================================================
echo   SUCCESS! Mobile phones on Wi-Fi can now connect!
echo ===================================================
pause
