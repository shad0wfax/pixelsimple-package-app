@echo off

REM example usage: c:\Users\Akshay\Desktop\media_scanner.bat c:\Users\Akshay\ c:\Users\Akshay\Desktop\out.txt true "\.mov$ \.mp4$"

set base_dir=%1
set output_file_name=%2
set recursive=%3
set file_filters=%4

echo base_dir = %base_dir%
echo output_file_name = %output_file_name%
echo recursive = %recursive%
echo file_filters = %file_filters%

REM TODO: error handling - if access issues then abort this script.
REM purge stuff to start with
if exist %output_file_name% del %output_file_name% > nul

if %recursive%==true (
	echo executing recursive:: dir /b /s %base_dir% | findstr /i %file_filters% > %output_file_name%

	dir /b /s %base_dir% | findstr /i %file_filters% >> %output_file_name%

) else (
	echo executing non-recursive:: dir /b %base_dir% | findstr /i %file_filters% > %output_file_name%

	REM Less performant version for non-recursive. Since dir command doesn't provide full path for non recursive.

	for /f "usebackq tokens=*" %%f in (`dir /b %base_dir% ^| findstr /i %file_filters% 2^>nul:`) do (
		
		echo %base_dir%%%f >> %output_file_name%

	)	

)

endlocal

REM exit 0