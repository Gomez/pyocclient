#!/bin/bash
#
# ownCloud
#
# @author Thomas Müller
# @copyright 2014 Thomas Müller thomas.mueller@tmit.eu
#

set -e

WORKDIR=$PWD
CORE_BRANCH=$1
echo "Work directory: $WORKDIR"
php -v
php -i | grep xml
git clone --depth 1 -b $CORE_BRANCH https://github.com/owncloud/core
cd core
git submodule update --init

cd $WORKDIR
echo "New Workdir: $WORKDIR"

#
# install script
#
cd core

DATABASENAME=oc_autotest
DATABASEUSER=oc_autotest
ADMINLOGIN=admin
BASEDIR=$PWD

DBCONFIGS="sqlite"
#PHPUNIT=$(which phpunit)

# use tmpfs for datadir - should speedup unit test execution
DATADIR=$BASEDIR/data-autotest

echo "Using database $DATABASENAME"

cat > ./tests/autoconfig-sqlite.php <<DELIM
<?php
\$AUTOCONFIG = array (
  'installed' => false,
  'dbtype' => 'sqlite',
  'dbtableprefix' => 'oc_',
  'adminlogin' => '$ADMINLOGIN',
  'adminpass' => 'admin',
  'directory' => '$DATADIR',
);
DELIM

function execute_tests {
    echo "Setup environment for $1 testing ..."
    # back to root folder
    cd $BASEDIR

    # revert changes to tests/data
    git checkout tests/data/*

    # reset data directory
    rm -rf $DATADIR
    mkdir $DATADIR

    cp $BASEDIR/tests/preseed-config.php $BASEDIR/config/config.php

    # copy autoconfig
    cp $BASEDIR/tests/autoconfig-sqlite.php $BASEDIR/config/autoconfig.php

    # trigger installation
    echo "INDEX"
    php -f index.php
    echo "END INDEX"

}

#
# start test execution
#
if [ -z "$1" ]
  then
    # run all known database configs
    for DBCONFIG in $DBCONFIGS; do
        execute_tests $DBCONFIG
    done
else
    execute_tests $1 $2 $3
fi

# show environment


echo "owncloud configuration:"
cat $BASEDIR/config/config.php


echo "data directory:"
ls -ll $DATADIR

echo "owncloud.log:"
#cat $DATADIR/owncloud.log

cd $BASEDIR

cd ..
cat /etc/apache2/sites-available/default
bash ./runtests.sh
