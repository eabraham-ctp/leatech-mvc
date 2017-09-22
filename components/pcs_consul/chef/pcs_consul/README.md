# Consul cookbook
## MVC Platform Common Services

This MVC wrapper cookbook installs Consul either as a server (for the primary
Consul cluster members) or as a client (for VMs registering as services or
using the Consul service registry).

### Local Development

A major problem with local cookbook development is working with cookbooks that contain sensitive values.  Luckily, Test Kitchen removes the need to hard-code these values into our attributes.rb file, which can be forgotten when you finish your testing and commit to your remote branch.

#### Test-Kitchen Integration

[Test-Kitchen](http://kitchen.ci) is an incredibly powerful and useful framework for both cookbook development and cookbook testing.  

* In order to use this cookbook with Kitchen, you must export the *__sumologic__* credentials:

```shell
export SUMO_ACCESS_KEY=...
export SUMO_ACCESS_ID=...
```

Now your __*.kitchen.yml*__ file will be able to read in these environment variables before syncing the cookbooks and transferring attributes to the Chef-Zero client running inside of the VM that you're running for your convergence tests.
