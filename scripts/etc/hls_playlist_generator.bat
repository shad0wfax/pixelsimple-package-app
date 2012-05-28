@echo off
setlocal ENABLEDELAYEDEXPANSION

REM Example usage: hls_playlist_generator.bat Z:\Downloads\Nova\ Z:\Downloads\Nova\hls_playlist.m3u8 ts 10 Z:\Downloads\Nova\pixelsimple_hls_transcode.complete 10  C:\dev\pixelsimple\ffprobe\32_bit\1.0\ffprobe.exe /someurl

REM - mandatory - the hls_media_dir should have the trailing \ at the end. Simplifies the script.
set hls_media_dir=%1
set playlist_file=%2
set hls_file_extension=%3
set check_interval_in_sec=%4
set hls_transcode_complete_file=%5
set segment_time=%6
set ffprobe_path=%7
REM Stripping the end double quotes - The base uri can contain '=' param. Hence it needs to be passed with quotes (if passed) 
set base_uri=%~8

REM Other variables
set temp_playlist_file=%hls_media_dir%hls_temp.m3u8
set log_file=%hls_media_dir%hls_log.txt
REM a temp file to compute the ffprobe segment output. Will be removed later.
set duration_file=%hls_media_dir%hls_segment_duration_file.pixelsimple
set hls_file_start=#EXTM3U
REM target_duration is hard coded to segment_time for now. Can extend this to be a param if needed.
set target_duration=%6
set hls_file_duration=#EXT-X-TARGETDURATION:%target_duration%
set hls_file_sequence=#EXT-X-MEDIA-SEQUENCE:0
REM The description (after comma below) is left blank. Extend the script if needed.
set hls_segment_header=#EXTINF:
set hls_file_end=#EXT-X-ENDLIST
set completed=false

REM TODO: error handling - if access issues then abort this script.
REM purge stuff to start with
if exist %playlist_file% del %playlist_file% > nul
if exist %log_file% del %log_file% > nul

REM init stuff
echo.>%playlist_file%
echo.>%log_file%

echo Starting the transcoding at %date% %time% >> %log_file%
echo hls_media_dir = %hls_media_dir% >> %log_file%
echo playlist_file = %playlist_file% >> %log_file%
echo hls_file_extension = %hls_file_extension% >> %log_file%
echo check_interval_in_sec = %check_interval_in_sec% >> %log_file%
echo hls_transcode_complete_file = %hls_transcode_complete_file% >> %log_file%
echo segment_time = %segment_time% >> %log_file%
echo ffprobe_path = %ffprobe_path% >> %log_file%
echo base_uri = %base_uri% >> %log_file%

goto until_hls_transcode_complete

:until_hls_transcode_complete

	if exist %hls_transcode_complete_file% (
		set completed=true
		goto create_playlist
	) else (
		REM wait for the specified time. 
		@ping -n %check_interval_in_sec% 127.0.0.1 > nul
		goto create_playlist
	)

:create_playlist
	if exist %temp_playlist_file% del %temp_playlist_file% > nul 
	REM create the file hearder parts
	echo %hls_file_start% >> %temp_playlist_file%
	echo %hls_file_duration% >> %temp_playlist_file%
	echo %hls_file_sequence% >> %temp_playlist_file%
		
	for /f "usebackq tokens=*" %%f in (`dir /b %hls_media_dir% ^| findstr %hls_file_extension% 2^>nul:`) do (
	
		if %completed%==false (
			REM If transcoding is in progress, use the supplied segment_time, else compute the actual time. 
			REM Since if transcoding is in progress, we treat that as live streaming.
			echo %hls_segment_header%%segment_time%, >> %temp_playlist_file%
		) else (
			REM Ensure media file is quoted in double quotes for ffprobe. Strip any quote off media dir first.
			set mediaFile="%hls_media_dir:"=%%%~f"
			echo Going to compute the actual video length size of !mediaFile! using ffprobe and rewrite #EXTINF tag >> %log_file%
			
			REM Execute ffprobe command and write it to duration file, then read it back to a variabnle.
			REM Need to do this, since if ffprobe path contains double quotes, it fails to execute in for loop directly.
			%ffprobe_path% -i !mediaFile! -print_format json -show_format 2>nul | findstr /I duration > %duration_file%
			set /p ffprobeOutput=<%duration_file%
			echo ffprobeOutput = !ffprobeOutput! >> %log_file%
			
			for /f "usebackq tokens=2 delims=:" %%g in ('!ffprobeOutput!') do (
				REM convert it to an integer (basically drop off the decimal places, as per the spec)
				REM TODO: Ideally it should rounded off to the nearest integer, but it is not done for now. Redirecting any conversion error to nul.
				set /a dur=%%g 2>nul
				
				REM we just need 2 places after decimal (if present)
				echo Duration of %%~f is %%g will use !dur!  >> %log_file%

				REM no description added. Can extend in future to indlude segment descriptions if needed.
				echo %hls_segment_header%!dur!, >> %temp_playlist_file%
			)
		)
		
		REM removing the quotes from media dir if present
		echo %base_uri%%%~f >> %temp_playlist_file%
	)	

	copy /b %temp_playlist_file% %playlist_file% > nul
	
	if %completed%==false (
		echo completed=%completed% at %date% %time%  >> %log_file%	
		goto until_hls_transcode_complete
	) else (
		REM adding the end tag at the end of transcode. During transcoding, it will be considered a live-stream. This avoids bugs.
		echo %hls_file_end% >> %playlist_file%
		echo completed=%completed% Going to end! at %date% %time%  >> %log_file%	
		goto end
	)
	
:end
	if exist %temp_playlist_file% del %temp_playlist_file% > nul 
	if exist %duration_file% del %duration_file% > nul 
endlocal