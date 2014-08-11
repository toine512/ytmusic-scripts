@echo off
rem toine512 - 09/08/2014
rem The correct charset is OEM437 (OEM-US)

title Youtube music video generator
color 3F
echo �����������������������������������������������������������������������������ͻ
echo �                        Youtube music video generator                        �
echo �                          by toine512, August 2014.                          �
echo �                Background image courtesy of Christophe GOSSA.               �
echo �����������������������������������������������������������������������������ͼ

if "%~1"=="" goto PRINTMAN
if "%~2"=="" goto PRINTMAN
if "%~3"=="" goto PRINTMAN

rem Additional filters on top of ffmpeg filter chain
set ffvftop=

echo.

rem Auto generating the description or not?
if "%~2"=="auto" (
   YTMusic-res\exiftool.exe -p YTMusic-res/template.txt -charset UTF8 "%~1" >YTMusic_infotext
) else (
   rem Using a local copy of the text file prevents a huge mess in ffmpeg command since we can't do any escaping here
   copy /d /v /y /b "%~2" YTMusic_infotext >nul
   if errorlevel 1 (
      echo Making a local copy of the text file failed!
      exit /b 2
   )
)

rem Extract the cover from audio file if asked
if not "%~4"=="" (
   YTMusic-res\ffmpeg.exe -v fatal -y -i "%~1" -map 0:v:%~4 -c:v png -an -sn -f image2 YTMusic_cover
   if not errorlevel 1 (
      rem Adds the cover overlay at the beginning of the filter chain
      set ffvftop=movie="filename=YTMusic_cover:f=image2",scale="w=300:h=300:flags=lanczos:force_original_aspect_ratio=decrease",[in]overlay="main_w-overlay_w-50:50",
   )
)

rem Run ffmpeg
YTMusic-res\ffmpeg.exe -y -loop 1 -i YTMusic-res/b720.png -i "%~1" -shortest -map_metadata 1:g -f mov -movflags faststart -pix_fmt yuv420p -c:v libx264 -flags +cgop -r 1 -coder 0 -refs 1 -deblock 0:0:0 -me_method zero -me_range 16 -cmp zero -subq 0 -psy 1 -psy-rd 1.00:0.00 -mixed-refs 0 -trellis 0 -8x8dct 0 -fast-pskip 1 -bluray-compat 0 -nr 0 -bf 0 -weightp 0 -g 250 -keyint_min 1 -sc_threshold 50 -mbtree 0 -crf 20.0 -qmin 0 -qmax 69 -qcomp 0.60 -qdiff 4 -aq-mode none -vf %ffvftop%drawtext="x=50:y=50:textfile=YTMusic_infotext:fontfile='YTMusic-res/DejaVuSans.ttf':fontsize=24:fontcolor=black" -c:a copy -sn "%~3"
set fferrorlvl=%ERRORLEVEL%
echo.

rem Cleanup
del /q YTMusic_infotext >nul 2>&1
del /q YTMusic_cover >nul 2>&1

rem Deal with ffmpeg exit code
if %fferrorlvl% gtr 0 (
   echo ffmpeg failed! See the command output.
   exit /b 3
)

rem End.
echo Goodbye.
exit /b 0

:PRINTMAN
echo �����������������������������������������������������������������������������ͻ
echo � Missing arguments!                                                          �
echo �                                                                             �
echo � Name:                                                                       �
echo �     YTMusic.bat Youtube music video generator                               �
echo �                                                                             �
echo � Synopsis:                                                                   �
echo �     YTMusic.bat source_audiofile {source_textfile^|auto} output_file         �
echo �                 [cover_index]                                               �
echo �                                                                             �
echo � Description:                                                                �
echo �     Creates a video in MOV format suitable for Youtube using a still image  �
echo �     containing the text from source_textfile and copying the audio stream   �
echo �     from source_audiofile.                                                  �
echo �     If you pass "auto" instead of a text file path, the description is      �
echo �     generated from the audio container tags according to the following      �
echo �     ExiTtool format file YTMusic-res/template.txt.                          �
echo �     The text is printed in DejaVu Sans 24pt font on a bright gray shaded    �
echo �     background.                                                             �
echo �     The cover picture integarted in the audio file can be displayed. This   �
echo �     is activated by specifying the nth video stream containing the cover in �
echo �     the order given by ffmpeg/ffprobe (first ^= 0). This is 0 when the       �
echo �     cover is the only picture integrated into the file. (For Jamendo files  �
echo �     it is usually 2). Use probe.bat to find what's inside your audio files. �
echo �                                                                             �
echo �     Encoder: ffmpeg (thanks!)                                               �
echo �                                                                             �
echo �     Descritption text file must be encoded in UTF8 (w/o BOM).               �
echo �     The background image may be found in YTMusic-res/b720.png. The          �
echo �     size of the picture must be 1280x720.                                   �
echo �                                                                             �
echo �     ffmpeg.exe and DejaVuSans.ttf also need to be present in YTMusic-res/.  �
echo �                                                                             �
echo � Exit codes:                                                                 �
echo �     0 ^| Success.                                                            �
echo �     1 ^| Missing arguments (must have 3).                                    �
echo �     2 ^| Making a local copy of the description file failed.                 �
echo �     3 ^| ffmpeg encountered an error.                                        �
echo �����������������������������������������������������������������������������ͼ
pause
exit /b 1