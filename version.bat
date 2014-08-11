@echo off
rem toine512 - 10/08/2014
rem The correct charset is OEM437 (OEM-US)
title Versions
color 1F

echo ExifTool version:
YTMusic-res\exiftool.exe -ver
echo.
YTMusic-res\ffmpeg.exe -version
pause