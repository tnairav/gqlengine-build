#!/bin/bash


export BUILD_VERSION=v1.3.1
export GHC_VERSION=8.10.1

set -ex


mkdir -p /tmp/gqlbuild && cd /tmp/gqlbuild


echo Building $BUILD_VERSION
apt update
apt install --yes \
    build-essential \
    libffi-dev \
    libffi6 \
    libgmp-dev \
    libgmp10 \
    libncurses-dev \
    libncurses5 \
    libtinfo5 \
    libkrb5-dev \
    libssl-dev \
    locales \
    lsb-release \
    wget \
    curl \
    git

echo 'en_US.UTF-8 UTF-8' | tee /etc/locale.gen
locale-gen

export LANG=en_US.UTF-8
export LC_COLLATE=C
export LC_ALL="en_US.UTF-8"

export LC_CTYPE="$LC_ALL"
export LC_NUMERIC="$LC_ALL"
export LC_TIME="$LC_ALL"
export LC_MONETARY="$LC_ALL"
export LC_MESSAGES="$LC_ALL"
export LC_PAPER="$LC_ALL"
export LC_NAME="$LC_ALL"
export LC_ADDRESS="$LC_ALL"
export LC_TELEPHONE="$LC_ALL"
export LC_MEASUREMENT="$LC_ALL"
export LC_IDENTIFICATION="$LC_ALL"

update-locale LC_ALL=$LC_ALL


wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
apt update
apt install -y libpq-dev

mkdir -p ~/.ghcup/bin ~/.cabal/bin
export PATH=~/.cabal/bin:~/.ghcup/bin:$PATH

wget -O ~/.ghcup/bin/ghcup http://downloads.haskell.org/~ghcup/x86_64-linux-ghcup
chmod +x ~/.ghcup/bin/ghcup

ghcup install ghc $GHC_VERSION
ghcup set ghc $GHC_VERSION
ghcup install cabal

git clone https://github.com/hasura/graphql-engine.git
cd graphql-engine/server
git checkout -b build $BUILD_VERSION

cp cabal.project.ci cabal.project.local
cabal v2-update
cabal v2-build -j
cp `find dist-newstyle/ -name graphql-engine -type f` .
strip graphql-engine
mv graphql-engine /


cd / && rm -rf /tmp/gqlbuild
