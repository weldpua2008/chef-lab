#!/usr/bin/env bash
__default_user='testlab@testlab.com'
__default_password='password'
__default_network='10.0.15'
export CHEF_USER=${1:-__default_user}
export CHEF_PASS=${2:-__default_password}
export CHEFF_NETWORK=${3:-__default_network}
#
export DISTRIB_CODENAME=$(awk -F'=' '/DISTRIB_CODENAME=/{print $2}'  /etc/*-release)
[[ "x${DISTRIB_CODENAME}" = "x" ]] && export DISTRIB_CODENAME="trusty"
echo "deb https://packages.chef.io/repos/apt/stable ${DISTRIB_CODENAME} main" > /etc/apt/sources.list.d/chef-stable.list

grep -qw LANG /etc/environment || echo 'LANG=en_US.utf-8'>> /etc/environment
grep -qw LC_ALL /etc/environment || echo 'LC_ALL=en_US.utf-8'>> /etc/environment
locale-gen || dpkg-reconfigure locales

wget -qO - https://packages.chef.io/chef.asc |  apt-key add -

apt-get update -y -qq > /dev/null
apt-get upgrade -y -qq > /dev/null
apt-get -y -q install linux-headers-$(uname -r) build-essential > /dev/null

echo "Installing Chef server..."
apt-get -y -q install chef-server-core > /dev/null || {
  wget -P /tmp https://packages.chef.io/stable/ubuntu/14.04/chef-server-core_12.11.1-1_amd64.deb > /dev/null;
  dpkg -i /tmp/chef-server-core_12.11.1-1_amd64.deb;
}
apt-get -y -q install  chefdk

locale-gen UTF-8

mkdir -p /home/vagrant/certs
chown -R vagrant:vagrant /home/vagrant

chef-server-ctl reconfigure
echo "Waiting for services..."

reties=0
until (curl -s -D - http://localhost:8000/_status) | grep "200 OK"; do
  sleep 15s
  retries=$((retries+1))
  [[ ${retries} -gt 5 ]] && break
done

reties=0
while (curl -s http://localhost:8000/_status) | grep "fail"; do
  sleep 15s
  [[ ${retries} -gt 5 ]] && break
done


printf "\033c"
chef-server-ctl user-create testlabdev Test Lab ${CHEF_USER} ${CHEF_PASS} --filename /home/vagrant/certs/testlabdev.pem
chef-server-ctl org-create testcheflab "Test Chef Lab" --association_user testlabdev --filename /home/vagrant/certs/testcheflab.pem
chef-server-ctl install chef-manage
chef-server-ctl reconfigure
chef-manage-ctl reconfigure --accept-license

#chef-server-ctl install opscode-reporting
#chef-server-ctl reconfigure
#opscode-reporting-ctl reconfigure --accept-license


# configure hosts file for our internal network defined by Vagrantfile
cat >> /etc/hosts <<EOL
# vagrant environment nodes
${CHEFF_NETWORK}.10  chef-server
${CHEFF_NETWORK}.15  lb
${CHEFF_NETWORK}.21  web1
${CHEFF_NETWORK}.22  web2
${CHEFF_NETWORK}.23  web3
EOL
mkdir -p /home/vagrant/.chef /home/vagrant/cookbooks /home/vagrant/cookbooks

cat > /home/vagrant/.chef/knife.rb  <<EOL
# See https://docs.getchef.com/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "testlabdev"
#client_key               "#{current_dir}/testlabdev.pem"
client_key               "/home/vagrant/certs/testlabdev.pem"

chef_server_url           "https://chef-server/organizations/testcheflab"
#cookbook_path            ["#{current_dir}/../cookbooks"]
cookbook_path             ["/home/vagrant/cookbooks"]
knife[:editor]  =          "/usr/bin/vim"
EOL

cp /home/vagrant/certs/testcheflab.pem /etc/chef/client.pem
knife ssl fetch
knife ssl check

printf "\033c"
echo "Chef Console is ready: http://chef-server with login: testlabdev password: password"
