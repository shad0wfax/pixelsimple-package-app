#!/bin/sh

JAVACMD=java

# Verify that it is java 6+
javaVersion=`$JAVACMD -version 2>&1 | grep "java version" | egrep -e "1\.[678]"`
if [ -z "$javaVersion" ]; then
    $JAVACMD -version
    echo "** ERROR: The Java of $JAVACMD version is not 1.6 and above."
    exit 1
fi

PIXELSIMPLE_HOME=`dirname "$0"`
LIB_DIR=$PIXELSIMPLE_HOME/lib
APP_CONFIG_FILE=$PIXELSIMPLE_HOME/config/app_config_mac.properties
JETTY_CONFIG_FILE=$PIXELSIMPLE_HOME/config/jetty_config.xml
CLASSPATH=$PIXELSIMPLE_HOME/*.jar
SERVER_PORT=9999
PIXELSIMPLE_HOME="$PIXELSIMPLE_HOME/"

JAVA_OPTIONS=" -Dapp.home=$PIXELSIMPLE_HOME -DappConfigFile=$APP_CONFIG_FILE -Djetty.home=$PIXELSIMPLE_HOME -Djetty.configFile=$JETTY_CONFIG_FILE -Dserver.port=$SERVER_PORT "

# Add all jars under the lib dir to the classpath
for i in `ls $LIB_DIR/*.jar`
do
    CLASSPATH="$CLASSPATH:$i"
done

echo "Runing: exec $JAVACMD$JAVA_OPTIONS -cp \"$CLASSPATH\" com.pixelsimple.appbootstrap.jetty.AppBootstrap $@"
exec "$JAVACMD" $JAVA_OPTIONS -server -Xmx512m -XX:MaxPermSize=128m -cp "$CLASSPATH" com.pixelsimple.appbootstrap.jetty.AppBootstrap "$@"
