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
git clone --depth 1 -b $CORE_BRANCH https://github.com/owncloud/core
cd core
git submodule update --init

cd $WORKDIR
echo "New Workdir: $WORKDIR"

#setup db
mysql -e 'create database oc_autotest;'
mysql -u root -e "CREATE USER 'oc_autotest'@'localhost' IDENTIFIED BY 'owncloud'";
mysql -u root -e "grant all on oc_autotest.* to 'oc_autotest'@'localhost'";

#
# copy install script
#
echo "New Workdir2: $WORKDIR"

bash ./core_install.sh mysql
