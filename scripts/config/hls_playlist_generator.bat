@echo off
set test_file=Z:\Downloads\Nova\test_file.txt
title PixelSimple App Test
echo.
echo Starting FrameZap... >> %test_file%
echo.
echo To stop, press Ctrl+c >> %test_file%
setlocal

REM FindStr.exe - grep
REM tasklist.exe - ps
REM cat - copy /b 
REM command >> file	Append standard output of command to file
REM command 1>> file	Append standard output of command to file (same as previous)
REM command 2>> file	Append standard error of command to file (OS/2 and NT)

REM ref links:
REM http://stackoverflow.com/questions/5657035/how-can-i-write-the-pipe-command-linux-in-windows-batch
REM http://stackoverflow.com/questions/1613644/how-to-replace-names-recursively-via-windows-batch-operation
REM http://commandwindows.com/command1.htm

REM for /f "tokens=*" %%i IN (Z:\Downloads\Nova\ffmpeg_out.txt) DO @echo %%i >> %test_file%
REM if ERRORLEVEL 1 goto err_handler
REM goto all_fine
REM :err_handler
REM echo Unable to open the file >> %test_file%
REM :all_fine
REM echo All fine and dandy now >> %test_file% 

rem if exist "Z:\Downloads\Nova\ffmpeg_out.txt" (
rem     echo Wow! able to open the file >> %test_file%
rem ) else (
rem     echo Unable to open the file >> %test_file%
rem )

REM wait 5s to ensure that the out.txt file is created.
REM TIMEOUT /T 5 /NOBREAK
@ping 127.0.0.1 -n 5 -w 1000 > nul

REM set /p line=< Z:\Downloads\Nova\ffmpeg_out.txt
for /f "tokens=*" %%i IN (Z:\Downloads\Nova\ffmpeg_out.txt) DO @echo %%i >> %test_file%

REM # some error if errorlevel >= 1
if ERRORLEVEL 1 (
	echo great snakes! some error >> %test_file%
	echo %line%
) else (
	echo holy crap! all good  >> %test_file%
	echo %line%
)

