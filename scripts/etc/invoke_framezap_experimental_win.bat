@echo off
title PixelSimple App Test
echo.
echo Starting FrameZap...
echo.
echo To stop, press Ctrl+c
setlocal

REM if "%JAVA_HOME%" == "" set _JAVACMD=java.exe
REM if not exist "%JAVA_HOME%\bin\java.exe" set _JAVACMD=java.exe
REM if "%_JAVACMD%" == "" set _JAVACMD="%JAVA_HOME%\bin\java.exe"

set PIXELSIMPLE_HOME=%~dp0
set LIB_DIR=%PIXELSIMPLE_HOME%\lib
set APP_CONFIG_FILE=%PIXELSIMPLE_HOME%\config\app_config_win.properties
set JETTY_CONFIG_FILE=%PIXELSIMPLE_HOME%\config\jetty_config.xml
set CLASSPATH=%PIXELSIMPLE_HOME%\*.jar
set SERVER_PORT=9999

for %%a in ("%LIB_DIR%\*.*") do call :process %%~nxa
goto :next

:process
set CLASSPATH=%CLASSPATH%;%LIB_DIR%\%1
goto :end

:next

set _JAVACMD="%PIXELSIMPLE_HOME%\jre\bin\java.exe"

REM %_JAVACMD% -server -Xmx512m -XX:MaxPermSize=128m -Djetty.home="%ARTIFACTORY_HOME%" -Dartifactory.home="%ARTIFACTORY_HOME%" -Dfile.encoding=UTF8 -cp "%CLASSPATH%" org.artifactory.standalone.main.Main %*
%_JAVACMD% -server -Xmx512m -XX:MaxPermSize=128m -Dapp.home=%PIXELSIMPLE_HOME% -DappConfigFile=%APP_CONFIG_FILE% -Djetty.home=%PIXELSIMPLE_HOME% -Djetty.configFile=%JETTY_CONFIG_FILE% -Dserver.port=%SERVER_PORT% -cp %CLASSPATH% com.pixelsimple.appbootstrap.jetty.AppBootstrap %*

@endlocal
:end
