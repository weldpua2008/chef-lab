## Manage your Chef Server with Knife on macOS.

knife is the command-line tool that provides an interface between your workstation and the Chef server. knife enables you to upload your cookbooks to the Chef server and work with nodes, the servers that you manage.

knife requires two files to authenticate with the Chef server.

* an `RSA private key`
  Every request to the Chef server is authenticated through an RSA public key pair. The Chef server holds the public part; you hold the private part.
* a knife configuration file
  The configuration file is typically named `knife.rb`. It contains information such as the Chef server's URL, the location of your RSA private key, and the default location of your cookbooks.

### Connection to Chef server on Vagrant

1). Preparetions
> 100.64.0.10 is ip of Chef Server

```bash
mkdir  ~/learn-chef/.chef/
cd  ~/learn-chef/.chef/
ssh-keygen -R  100.64.0.10
ssh-copy-id vagrant@100.64.0.10
```

2). Copy RSA private key

```bash
scp vagrant@100.64.0.10:/home/vagrant/certs/testlabdev.pem  ~/learn-chef/.chef/chefadmin.pem
```

3). Crete knife configuration file

Add this to your knife configuration file, `~/learn-chef/.chef/knife.rb`. Then replace the value for `chef_server_url` with your Chef server's FQDN.
```
current_dir = File.dirname(__FILE__)
log_level                 :info
log_location              STDOUT
node_name                 "chefadmin"
client_key                "#{current_dir}/chefadmin.pem"
chef_server_url           "https://chef-server/organizations/testcheflab"
cookbook_path             ["#{current_dir}/../cookbooks"]```

4). Verify your setup

```
$ knife ssl fetch
WARNING: Certificates from chef-server will be fetched and placed in your trusted_cert
directory (/Users/weldpua2008/learn-chef/.chef/trusted_certs).

Knife has no means to verify these are the correct certificates. You should
verify the authenticity of these certificates after downloading.

Adding certificate for chef-server in /Users/weldpua2008/learn-chef/.chef/trusted_certs/chef-server.crt
```

```
$ knife ssl check
Connecting to host chef-server:443
Successfully verified certificates from `chef-server'
```
