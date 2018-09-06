#!/usr/bin/env bash
__default_network='10.0.15'
export CHEFF_NETWORK=${1:-$__default_network}

localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 > /dev/null
grep -qw LANG /etc/environment || echo 'LANG=en_US.utf-8'>> /etc/environment
grep -qw LC_ALL /etc/environment || echo 'LC_ALL=en_US.utf-8'>> /etc/environment

rpm --import https://packages.chef.io/chef.asc > /dev/null
yum install yum-utils -y > /dev/null

cat >chef-stable.repo <<EOL
[chef-stable]
name=chef-stable
baseurl=https://packages.chef.io/repos/yum/stable/el/\$releasever/\$basearch/
gpgcheck=1
enabled=1
EOL
yum-config-manager --add-repo chef-stable.repo > /dev/null
[[ ! -e /etc/yum.repos.d/chef-stable.repo ]] && mv chef-stable.repo /etc/yum.repos.d/
yum-config-manager --save --setopt=chef-stable.skip_if_unavailable=true
yum install chef -y > /dev/null  || {
wget -P /tmp  https://packages.chef.io/files/stable/chef/12.16.42/el/7/chef-12.16.42-1.el7.x86_64.rpm;
rpm -Uvh  /tmp/chef-12.16.42-1.el7.x86_64.rpm;
}
# configure hosts file for our internal network defined by Vagrantfile

cat >> /etc/hosts <<EOL
# vagrant environment nodes
${CHEFF_NETWORK}.10  chef-server
${CHEFF_NETWORK}.15  lb
${CHEFF_NETWORK}.21  web1
${CHEFF_NETWORK}.22  web2
${CHEFF_NETWORK}.23  web3
EOL
