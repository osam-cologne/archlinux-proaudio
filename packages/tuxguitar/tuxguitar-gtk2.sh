#!/bin/sh -e
export PATH="/usr/lib/jvm/java-11-openjdk/bin:$PATH"
for jar in /opt/tuxguitar/lib/*.jar; do
  CP="$CP:$jar"
done
export SWT_GTK3=0
exec java -cp "$CP" \
  -Dtuxguitar.home.path=/opt/tuxguitar \
  -Dtuxguitar.share.path=/opt/tuxguitar/share/ \
  -Djava.library.path="/opt/tuxguitar/lib:$LD_LIBRARY_PATH" \
  org.herac.tuxguitar.app.TGMainSingleton $*
