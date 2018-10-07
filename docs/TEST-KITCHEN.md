### Checking results

Create the instance now by running `kitchen create`.
    | If you need to destroy your instance before you complete this module, run kitchen destroy. You can later run kitchen create to pick back up where you left off on a fresh instance.



    This command will take longer the first time you run it because Vagrant needs to download the base image, or box. After the base box is downloaded, kitchen create will complete much more quickly.



```
kitchen list
```

Now run `kitchen converge` to apply the cookbook to the Ubuntu virtual machine.
```
kitchen converge
```
    We use the term converge to describe the process of bringing a system closer to its desired state. When you see the word converge, think test and repair.
    `kitchen converge` takes longer the first time you run it on a new instance because Test Kitchen needs to install the Chef tools. Run kitchen converge a second time to see how much faster it is.


Run kitchen list to see the latest status.
```
kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action  Last Error
default-ubuntu-1404  Vagrant  ChefZero     Inspec    Ssh        Converged    <None>
```

Verify that your Test Kitchen instance is configured as expected

```
kitchen exec -c 'wget -qO- localhost'
```

Delete the Test Kitchen instance.
We're all done with our virtual machine, so now run the `kitchen destroy` command to delete it.
