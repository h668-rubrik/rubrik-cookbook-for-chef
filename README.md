# Rubrik Chef Cookbook

## Overview

The Rubrik Chef cookbook is used to configure a host with an SLA domain, and install the Rubrik connector.

## Requirements

The following node attributes should be defined in order to use this cookbook:

Attribute Name | Example Value
--- | ---
rubrik_host | clustera.demo.com
rubrik_username | john.doe@demo.com
rubrik_password | Rubrik123!
rubrik_sla_domain | Gold
rubrik_win_sa_user | sa_rubrik@demo.com
rubrik_win_sa_pass | Rubrik123!

Note that 'rubrik_win_sa_user' and 'rubrik_win_sa_pass' are optional, and will only be required if installing the
connector on a Windows system. If these are omitted then the service will run as LocalSystem.

## Running recipes individually

The recipes can be run individually through the following commands:

### Cluster Info

`sudo chef-client -z -r 'recipe[rubrik::cluster_info]' -l info`

### Get SLA

`sudo chef-client -z -r 'recipe[rubrik::get_sla]' -l info`

### Set SLA

`sudo chef-client -z -r 'recipe[rubrik::set_sla]' -l info`

### On-Demand Snapshot

`sudo chef-client -z -r 'recipe[rubrik::od_backup]' -l info`

### Register Host

`sudo chef-client -z -r 'recipe[rubrik::register_host]' -l info`

## Detail

The resources and providers used are defined in `libraries/rubrik_api.rb`, this module is subject to on-going development.
Currently available resources are detailed below:

### Resources

#### get_cluster_info

##### Action: get

Dumps the cluster ID, version, and API version to the Chef log.

Example usage:

```ruby
rubrik_cluster_info 'get' do
  action :get
end
```

Example output:

```none
[2017-08-25T02:38:22-07:00] INFO: Processing rubrik_cluster_info[get] action get (rubrik::default line 7)
[2017-08-25T02:38:22-07:00] INFO: Cluster ID: 4a5d5fc5-a764-4c9c-8908-9d56e4221fd6
[2017-08-25T02:38:22-07:00] INFO: Cluster Version: 4.0.2-374
[2017-08-25T02:38:22-07:00] INFO: Cluster API version: 1
```

#### set_sla

##### Action: get

Dumps the current SLA domain for the host to the Chef log.

Example usage:

```ruby
rubrik_set_sla 'get' do
  action :get
end
```

Example output:

```none
[2017-08-25T02:38:22-07:00] INFO: Processing rubrik_set_sla[get] action get (rubrik::default line 11)
[2017-08-25T02:38:24-07:00] INFO: Current SLA domain is: Silver
```

##### Action: set

Sets the SLA domain for the host to the value set in `node['rubrik_sla_domain']`.

Example usage:

```ruby
rubrik_set_sla 'set' do
  action :set
end
```

Example output:

```none
[2017-08-25T02:38:24-07:00] INFO: Processing rubrik_set_sla[set] action set (rubrik::default line 15)
[2017-08-25T02:38:27-07:00] INFO: Updated SLA domain to: Silver
```

#### od_backup

##### Action: set

Takes an on-demand backup of the local machine.

Example usage:

```ruby
rubrik_od_backup 'set' do
    action :set
    sla_domain 'Gold'
end
```

**NOTE: If sla_domain is set to 'Unprotected', snapshot will be taken with no SLA domain attached. If it is omitted, then snapshot will be taken with the SLA policy attached to the host. Otherwise, SLA Domain can be specified by name using the `sla_domain` attribute**

Example output:

```none
[2017-09-26T02:21:05-07:00] INFO: Processing rubrik_od_backup[set] action set (rubrik::od_backup line 10)
[2017-09-26T02:21:06-07:00] INFO: Getting ID for SLA domain: Gold
[2017-09-26T02:21:07-07:00] INFO: Triggering snapshot...
[2017-09-26T02:21:07-07:00] INFO: Snapshot initialisation complete
```

#### register_host

##### Action: get

Checks if the current host is registered to the Rubrik cluster. This first checks using the hostname gathered by Ohai, and if this returns a 404, will try via IP address.

Example usage:

```ruby
rubrik_register_host 'get' do
  action :get
end
```

Example output:

```none
[2017-10-09T01:35:38-07:00] INFO: Processing rubrik_register_host[get] action get (rubrik::register_host line 1)
[2017-10-09T01:35:38-07:00] INFO: Host is not registered against the Rubrik cluster
```

##### Action: set

Registers the host to the Rubrik cluster. This uses first the hostname gathered by Ohai, and if this returns a 404, will try via IP address.

Example usage:

```ruby
rubrik_register_host 'set' do
  action :set
end
```

Example output:

```none
[2017-10-09T01:36:00-07:00] INFO: Processing rubrik_register_host[set] action set (rubrik::register_host line 1)
[2017-10-09T01:36:01-07:00] INFO: Host is not registered against the Rubrik cluster, registering now
[2017-10-09T01:36:01-07:00] INFO: Host registered successfully against the Rubrik cluster
```

#### fileset

##### Action: get

Reports on filesets configured for the current host.

Example usage:

```ruby
rubrik_fileset 'get' do
  action :get
end
```

Example output:

```none
[2017-10-09T03:16:10-07:00] INFO: Processing rubrik_fileset[get] action get (rubrik::fileset line 9)
[2017-10-09T03:16:11-07:00] INFO: Host Current host ID is: Host:::a7654d58-dd3e-4918-a635-66b888400820
[2017-10-09T03:16:11-07:00] INFO: This host has 2 filesets currently assigned
[2017-10-09T03:16:11-07:00] INFO: Fileset 'Winner Chicken Dinner' found, with ID: Fileset:::ce5dcde7-937b-43cd-9efd-0ab9de56e363, and SLA domain: Silver
[2017-10-09T03:16:11-07:00] INFO: Fileset 'Home dirs' found, with ID: Fileset:::cb0b04a7-b210-43e3-98a7-2250800138f9, and SLA domain: Silver
```

### Recipes

#### connector.rb

This recipe will install the connector on a RedHat, Debian, or Windows based system, pulling the connector install package from the cluster, and installing it.

##### Action: default

Installs the Rubrik connector on the target system, and configures it with the service account (Windows only) defined in the `rubrik_win_sa_user` and `rubrik_win_sa_pass` node variables.

Example usage:

```ruby
include_recipe 'rubrik::connector'
```

## Limitations

Presently only works with VMware virtual machines, and relies on the vCenter being up to date in the Rubrik cluster.
