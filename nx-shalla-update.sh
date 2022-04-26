#!/bin/sh
#
# Downloader de lista negra para NxFilter
# Modificado: 26/04/2022
#
# Este script irá baixar a lista negra atual
# tarball de Blacklists UT1, extraia-o, pare o NxFilter,
# chame a importação nxd.ShallaUpdate, reinicie o
# serviço e limpar a bagunça.
#
clear

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#
# Local de instalação do NxFilter e heap Java
# opções de tamanho. Altere conforme necessário.
#
export NX_HOME=/nxfilter
export JVM_HEAP="1024m"
export PATH=$PATH:/usr/bin:/usr/local/bin

if [ ! -f "$NX_HOME/nxd.jar" ]; then
  echo "\n ERROR! NxFilter environment not found at \"$NX_HOME\"!"
  echo " - Set the NX_HOME var for this script to NxFilter's application directory and try again.\n"
  exit 1
fi

echo "Download de Blacklist UTI..."
cd /tmp
wget ftp://ftp.ut-capitole.fr/pub/reseau/cache/squidguard_contrib/blacklists.tar.gz

echo "Extraindo Blacklist.tar.gz..."
tar -xf blacklists.tar.gz
mv blacklists BL

echo "Parando Serviço NxFilter..."
$NX_HOME/bin/shutdown.sh
sleep 5

#NX_UPDATE="-Djava.net.preferIPv4Stack=true -Xmx$JVM_HEAP -Djava.security.egd=file:/dev/./urandom -cp $NX_HOME/nxd.jar:$NX_HOME//lib/*: nxd.ShallaUpdate /tmp/BL"
#NX_UPDATE="-Djava.net.preferIPv4Stack=true -Xms256m -Xmx256m -Djava.security.egd=file:/dev/./urandom -cp $NX_HOME/nxd.jar:$NX_HOME//lib/*: nxd.util.ShallaUpdate /tmp/BL"
NX_UPDATE="-Djava.net.preferIPv4Stack=true -Xms$JVM_HEAP -Xmx$JVM_HEAP -Djava.security.egd=file:/dev/./urandom -cp $NX_HOME/nxd.jar:$NX_HOME//lib/*: nxd.util.ShallaUpdate /tmp/BL"
cd $NX_HOME

echo "Importando Categorias..."
/usr/bin/java $NX_UPDATE

echo "Reiniciando Serviço..."
$NX_HOME/bin/startup.sh -d

echo "Limpando..."
rm -r -f /tmp/BL
rm -f /tmp/blacklists.tar.gz

echo "Feito."
exit
