@echo off
title PixelSimple App Test
echo.
echo Starting Webme...
echo.
echo To stop, press Ctrl+c
setlocal

REM if "%JAVA_HOME%" == "" set _JAVACMD=java.exe
REM if not exist "%JAVA_HOME%\bin\java.exe" set _JAVACMD=java.exe
REM if "%_JAVACMD%" == "" set _JAVACMD="%JAVA_HOME%\bin\java.exe"

set PIXELSIMPLE_HOME=%~dp0
set LIB_DIR=%PIXELSIMPLE_HOME%\lib
set CLASSPATH=%PIXELSIMPLE_HOME%\*.jar


for %%a in ("%LIB_DIR%\*.*") do call :process %%~nxa
goto :next

:process
set CLASSPATH=%CLASSPATH%;%LIB_DIR%\%1
goto :end

:next

set _JAVACMD="%PIXELSIMPLE_HOME%\jre\bin\java.exe"

REM %_JAVACMD% -server -Xmx512m -XX:MaxPermSize=128m -Djetty.home="%ARTIFACTORY_HOME%" -Dartifactory.home="%ARTIFACTORY_HOME%" -Dfile.encoding=UTF8 -cp "%CLASSPATH%" org.artifactory.standalone.main.Main %*
%_JAVACMD% -cp "%CLASSPATH%" com.pixelsimple.appcore.env.EnvironmentImpl %*

@endlocal
:end