#!/bin/bash

USERNAME=${1:-codespace}
SECURE_PATH_BASE=${2:-$PATH}

echo "Defaults secure_path=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin:/usr/local/share:${SECURE_PATH_BASE}\"" >> /etc/sudoers.d/$USERNAME

# Install and setup fish
apt-get install -yq fish
FISH_PROMPT="function fish_prompt\n    set_color green\n    echo -n (whoami)\n    set_color normal\n    echo -n \":\"\n    set_color blue\n    echo -n (pwd)\n    set_color normal\n    echo -n \"> \"\nend\n"
printf "$FISH_PROMPT" >> /etc/fish/functions/fish_prompt.fish
printf "if type code-insiders > /dev/null 2>&1; and not type code > /dev/null 2>&1\n  alias code=code-insiders\nend" >> /etc/fish/conf.d/code_alias.fish

# Add user to a Docker group
apt-get -y install --no-install-recommends sudo
sudo -u ${USERNAME} mkdir /home/${USERNAME}/.vsonline
groupadd -g 800 docker
usermod -a -G docker ${USERNAME}

# Create user's .local/bin
sudo -u ${USERNAME} mkdir -p /home/${USERNAME}/.local/bin
