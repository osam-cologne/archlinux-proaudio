#!/bin/sh -e
export PATH="/usr/lib/jvm/java-11-openjdk/bin:$PATH"
for jar in /usr/share/java/tuxguitar/*.jar; do
  CP="$CP:$jar"
done
export SWT_GTK3=1
exec java -cp "$CP" \
  -Dtuxguitar.home.path=/usr/share/tuxguitar \
  -Dtuxguitar.share.path=/usr/share/tuxguitar/share \
  -Djava.library.path=/usr/lib/tuxguitar \
  org.herac.tuxguitar.app.TGMainSingleton $*
