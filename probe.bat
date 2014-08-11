@echo off
rem toine512 - 09/08/2014
rem The correct charset is OEM437 (OEM-US)
title File prober (exiftool+ffmpeg)
color 2F

if "%~1"=="" goto PRINTMAN

echo Metadata:
echo.
YTMusic-res\exiftool.exe "%~1"
echo.
echo.
echo ffmpeg streams:
echo.
YTMusic-res\ffmpeg.exe -i "%~1" 2>&1 | findstr /c:Input /c:Stream /c:comment
exit /b 0

:PRINTMAN
echo Usage:
echo     probe.bat file_path
echo.
pause
exit /b 1