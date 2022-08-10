#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

USERNAME=${USERNAME:-"codespace"}

set -eux

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

export DEBIAN_FRONTEND=noninteractive

# Enables the oryx tool to generate manifest-dir which is needed for running the postcreate tool
DEBIAN_FLAVOR="focal-scm"
mkdir -p /opt/oryx && echo "vso-focal" > /opt/oryx/.imagetype
echo "DEBIAN|${DEBIAN_FLAVOR}" | tr '[a-z]' '[A-Z]' > /opt/oryx/.ostype

# For the codespaces image, oryx build tool installs the detected platforms in /home/codespace/*. Hence, linking current platforms to the /home/codespace/ path and adding it to the PATH.
# This ensures that whatever platfornm versions oryx detects and installs are set as root.
NODE_PATH="/home/codespace/.nodejs/current"
mkdir -p /home/codespace/.nodejs
ln -snf /usr/local/share/nvm/current $NODE_PATH

PHP_PATH="/home/codespace/.php/current"
mkdir -p /home/codespace/.php
ln -snf /usr/local/php/current $PHP_PATH

PYTHON_PATH="/home/codespace/.python/current"
mkdir -p /home/codespace/.python
ln -snf /usr/local/python/current $PYTHON_PATH

JAVA_PATH="/home/codespace/.java/current"
mkdir -p /home/codespace/.java
ln -snf /usr/local/sdkman/candidates/java/current $JAVA_PATH

RUBY_PATH="/home/codespace/.ruby/current"
mkdir -p /home/codespace/.ruby
ln -snf /usr/local/rvm/rubies/default $RUBY_PATH

DOTNET_PATH="/home/codespace/.dotnet"
ln -snf /usr/local/dotnet/current $DOTNET_PATH
mkdir -p /opt/dotnet/lts
cp -R /usr/local/dotnet/current/dotnet /opt/dotnet/lts
cp -R /usr/local/dotnet/current/LICENSE.txt /opt/dotnet/lts
cp -R /usr/local/dotnet/current/ThirdPartyNotices.txt /opt/dotnet/lts

HOME_DIR="/home/codespace/"
chown -R codespace:codespace ${HOME_DIR}
chmod -R g+r+w "${HOME_DIR}"
find "${HOME_DIR}" -type d | xargs -n 1 chmod g+s

OPT_DIR="/opt/"
chown -R codespace:oryx ${OPT_DIR}
chmod -R g+r+w "${OPT_DIR}"
find "${OPT_DIR}" -type d | xargs -n 1 chmod g+s

echo "Defaults secure_path=\"${DOTNET_PATH}:${NODE_PATH}/bin:${PHP_PATH}/bin:${PYTHON_PATH}/bin:${JAVA_PATH}/bin:${RUBY_PATH}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin:/usr/local/share:${PATH}\"" >> /etc/sudoers.d/$USERNAME

echo "Done!"
