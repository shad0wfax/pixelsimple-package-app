@echo off
setlocal

REM Example usage: hls_playlist_generator.bat Z:\Downloads\Nova\ Z:\Downloads\Nova\hls_playlist.m3u8 ts 10 Z:\Downloads\Nova\hls_t.complete 10 /someurl

REM - mandatory - the hls_media_dir should have the trailing \ at the end. Simplifies the script.
set hls_media_dir=%1
set playlist_file=%2
set hls_file_extension=%3
set check_interval_in_sec=%4
set hls_transcode_complete_file=%5
set segment_time=%6
set base_uri=%7

REM Other variables
set temp_playlist_file=%hls_media_dir%hls_temp.m3u8
set log_file=%hls_media_dir%hls_log.txt
set hls_file_start=#EXTM3U
set hls_file_duration=#EXT-X-TARGETDURATION:%segment_time%
set hls_file_sequence=#EXT-X-MEDIA-SEQUENCE:0
REM TODO: what is that 10 below? read the damn manual!
set hls_segment_header=#EXTINF:10, no desc
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
echo %hls_media_dir% >> %log_file%
echo %playlist_file% >> %log_file%
echo %hls_file_extension% >> %log_file%
echo %check_interval_in_sec% >> %log_file%
echo %hls_transcode_complete_file% >> %log_file%
echo %segment_time% >> %log_file%
echo %base_uri% >> %log_file%

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
		echo %hls_segment_header% >> %temp_playlist_file%
		REM removing the quotes from media dir if present
		echo %base_uri%%hls_media_dir:"=%%%~f >> %temp_playlist_file%
	)	
	echo %hls_file_end% >> %temp_playlist_file%
	copy /b %temp_playlist_file% %playlist_file% > nul
	
	if %completed%==false (
		echo completed=%completed% at %date% %time%  >> %log_file%	
		goto until_hls_transcode_complete
	) else (
		echo completed=%completed% Going to end! at %date% %time%  >> %log_file%	
		goto end
	)
	
	
:end
if exist %temp_playlist_file% del %temp_playlist_file% > nul 
