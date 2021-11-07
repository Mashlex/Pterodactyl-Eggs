#!/bin/bash

if [ -z ${TS_VERSION} ] || [ ${TS_VERSION} == latest ]; then
    TS_VERSION=$(curl -sSL https://teamspeak.com/versions/server.json | jq -r '.linux.x86_64.version')
fi

# get installed version from version_installed.txt
INSTALLED_VERSION=$(cat version.txt)
echo "Installed TeamSpeak3 Version: $INSTALLED_VERSION"


updateToVersion() {
    TSVERSION=$1
    echo "cleaning up files before the update..."
    rm -r doc
    rm -r redist
    rm -r serverquerydocs
    rm -r sql
    rm -r tsdns
    rm -r CHANGELOG
    rm ./*.so
    rm ./LICENSE*
    rm ts3server
    echo "downloading teamspeak version $TSVERSION and extracting file..."
    curl -L http://files.teamspeak-services.com/releases/server/${TS_VERSION}/teamspeak3-server_linux_amd64-${TS_VERSION}.tar.bz2 | tar -xvj --strip-components=1
    echo 'download and extraction finished'
    chmod +x ts3server_minimal_runscript.sh
    echo 'permissions set.'
    echo '' > .ts3server_license_accepted
    echo 'accepted license'
    echo "$TSVERSION" > version_installed.txt
    echo 'version written into version_installed.txt file'
}

if [ "$LATEST_VERSION" != "$INSTALLED_VERSION" ];
then
    updateToVersion "$LATEST_VERSION"
elif [ "$SERVER_VERSION" != "$INSTALLED_VERSION" ] && [ "$STATIC_VERSION" = 1 ];
then
    updateToVersion "$SERVER_VERSION"
else
    echo 'No update required.'
fi

if [ ! -f ts3server.ini ]; then
    ./ts3server_startscript.sh start createinifile=1
    PID=$(pgrep ts3server)
    kill "$PID"
fi

echo 'starting server...'
./ts3server_startscript.sh start inifile=ts3server.ini