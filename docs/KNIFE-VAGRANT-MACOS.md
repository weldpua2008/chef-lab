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
scp vagrant@100.64.0.10:/home/vagrant/certs/testlabdev.pem  ~/learn-chef/.chef/testlabdev.pem
```

3). Crete knife configuration file

Add this to your knife configuration file, `~/learn-chef/.chef/knife.rb`. Then replace the value for `chef_server_url` with your Chef server's FQDN.
```
current_dir = File.dirname(__FILE__)
log_level                 :info
log_location              STDOUT
node_name                 "testlabdev"
client_key                "#{current_dir}/testlabdev.pem"
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


PS:
You can use the following for https://learn.chef.io/modules/manage-a-node-chef-server/ubuntu/bring-your-own-system/bootstrap-your-node#/:
```
mkdir ~/learn-chef/cookbooks
cd ~/learn-chef/cookbooks
git clone https://github.com/learn-chef/learn_chef_apache2.git
ssh-keygen -R web1
knife bootstrap web1 --ssh-user  vagrant --ssh-password 'vagrant' --ssh-port 22 --sudo  --node-name web1 --run-list 'recipe[learn_chef_apache2]'
```

    __NOTE:  Because of private ip is the first interface in Vagrant append the `--json-attributes` argument to the end of your knife bootstrap command in this format:__
    ```--json-attributes '{"cloud": {"public_ip": "NODE_PUBLIC_IP_ADDRESS"}}'```


If you're working with an Amazon EC2, Microsoft Azure, or Google Compute Engine instance, replace the ipaddress part of the `--attribute ipaddress` argument with the corresponding entry from this table.


|Cloud provider| Attribute|	Notes|
|---|---|---|
|EC2|	`cloud.public_hostname`	|Chef sets this attribute during the bootstrap process.|
|Azure|	`cloud.public_ip`|This is the attribute you set in the previous part when you bootstrapped your node.|
|Compute Engine|	cloud_v2.public_ipv4|	Chef sets this attribute during the bootstrap process.|




Use from your macOS connection via hostname instead of ip address

```
knife ssh 'name:web1' 'sudo chef-client' --ssh-user vagrant --ssh-password 'vagrant' --attribute hostname
```

5). Manage Berkshelf

5.1). Create `~/learn-chef/Berksfile`
```
source 'https://supermarket.chef.io'
cookbook 'chef-client'
```

5.2). Upload on Chef Server
```
berks install
ls ~/.berkshelf/cookbooks
berks upload --no-ssl-verify
```

    Berkshelf requires a trusted SSL certificate in order to upload cookbooks. The --no-ssl-verify flag disables SSL verification, which is typically fine for testing purposes. Chef server comes with a self-signed SSL certificate. For production, you might use a trusted SSL certificate. The documentation describes how Chef server works with SSL certificates.


6). Creating Roles
Create folder
```mkdir ~/learn-chef/roles ```
Now add the following to a file named `~/learn-chef/roles/web.json`.
```json
{
   "name": "web",
   "description": "Web server role.",
   "json_class": "Chef::Role",
   "default_attributes": {
     "chef_client": {
       "interval": 300,
       "splay": 60
     }
   },
   "override_attributes": {
   },
   "chef_type": "role",
   "run_list": ["recipe[chef-client::default]",
                "recipe[chef-client::delete_validation]",
                "recipe[learn_chef_apache2::default]"
   ],
   "env_run_lists": {
   }
}
```

Define Role `web`
```$ knife role from file roles/web.json
Updated Role web
```
As a verification step, you can run knife role list to view the roles on your Chef server.

```$ knife role list
web
```

You can also run knife `role show web` to view the role's details.
```
knife role show web
chef_type:           role
default_attributes:
  chef_client:
    interval: 300
    splay:    60
description:         Web server role.
env_run_lists:
json_class:          Chef::Role
name:                web
override_attributes:
run_list:
  recipe[chef-client::default]
  recipe[chef-client::delete_validation]
  recipe[learn_chef_apache2::default]
```

The final step is to set your node's run-list. Run the following `knife node run_list set` command to do that.
```
$ knife node run_list set web1 "role[web]"
web1:
  run_list: role[web]

```

As a verification step, you can run the `knife node show` command to view your node's run-list.
```
$ knife node show web1 --run-list
web1:
  run_list: role[web]
```

Run chef-client
```
$ knife ssh 'name:web1' 'sudo chef-client' --ssh-user vagrant --ssh-password 'vagrant' --attribute hostname
```

You can see from the output that the chef-client cookbook set up chef-client as a service on your node.

You can run the knife status command to display a brief summary of the nodes on your Chef server, including the time of the most recent successful chef-client run.

```
$ knife status 'role:web' --run-list
36 seconds ago, web1, ["role[web]"], ubuntu 14.04.
```
Now that chef-client is set up to run every 5—6 minutes, now's a great time to experiment with your node.



[Show Node Info as raw JSON data](https://docs.chef.io/knife_node.html)
> To view node information in raw JSON, use the `-l` or `--long` option:

```knife node show -l -F json NODE_NAME```
