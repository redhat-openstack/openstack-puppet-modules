puppet-fluentd
==============

[![Build Status](https://travis-ci.org/mmz-srf/puppet-fluentd.png?branch=master)](https://travis-ci.org/mmz-srf/puppet-fluentd)

Manage Fluentd installation, configuration and Plugin-management with Puppet using the td-agent. 

## Supported Operating Systems
- Debian (tested on Debian 7.5) 
- Ubuntu 
- Redhat 
- CentOS (tested on CentOS 6.4)

## Used Modules 
- apt: "https://github.com/puppetlabs/puppetlabs-apt.git" (Only for Debian)
- concat: "https://github.com/puppetlabs/puppetlabs-concat.git"
- stdlib: "https://github.com/puppetlabs/puppetlabs-stdlib.git"

## Contributing
* Fork it
* Create a feature branch (`git checkout -b my-new-feature`)
* Run rspec tests (`bundle exec rake spec` or `rake spec`)
* Commit your changes (`git commit -am 'Added some feature'`)
* Push to the branch (`git push origin my-new-feature`)
* Create new Pull Request

### Branches in this module
- **master** tested and working. Latest Version on http://forge.puppetlabs.com
- **developmemt** includes the newewst features. works too, mostly. 

## Configuration
How to configure a Agent to send data to a centralised Fluentd-Server

### Install a Plugin
Install your fluentd plugin. (check here for the right pluginname : http://fluentd.org/plugin/ ). 

You can choose from a file or gem based instalation. 
```
  include ::fluentd
  
  fluentd::install_plugin { 'elasticsearch': 
    plugin_type => 'gem',
    plugin_name => 'fluent-plugin-elasticsearch',
  }
```

### Create a Agent 
The Agent watches over your logfiles and sends its content to the Collector. 
```
  include ::fluentd
  
  fluentd::configfile { 'apache': }
  fluentd::source { 'apache_main': 
    configfile => 'apache'
    type => 'tail',
    format => 'apache2',
    tag => 'apache.access_log',
    config => {
      'path' => '/var/log/apache2/access.log',
      'pos_file' => '/var/tmp/fluentd.pos',
    },
    notify => Class['fluentd::service']
  }
  
  fluentd::configfile { 'syslog': }
  fluentd::source { 'syslog_main': 
    configfile => 'syslog',
    type => 'tail',
    format => 'syslog',
    tag => 'system.syslog',
    config => {
      'path' => '/var/log/syslog',
      'pos_file' => '/tmp/td-agent.syslog.pos',
    },
    notify => Class['fluentd::service']
  }
  
  fluentd::configfile { 'forward': }
  fluentd::match { 'forward_main': 
    configfile => 'forward'
    pattern => '**',
    type => 'forward',
    servers => [
      {'host' => 'PUT_YOUR_HOST_HERE', 'port' => '24224'}
    ],
    notify => Class['fluentd::service']
  }
```
#### creates on the Agent side following files : 
```
/etc/td-agent/
  ├── config.d
  │   ├── apache.conf
  │   ├── syslog.conf
  │   └── forward.conf
  ├── ...
  ...
```

### Create a Collector 
The Collector collects all the data from the Agents. He now stores the data in files, Elasticsearch or elsewhere. 
```
  include ::fluentd

  fluentd::configfile { 'collector': }
  fluentd::source { 'collector_main':
    configfile => 'collector',
    type => 'forward',
    notify => Class['fluentd::service']
  }
  
  fluentd::match { 'collector_main':
    configfile => 'collector',
    pattern => '**',
    type => 'elasticsearch',
    config => {
      'logstash_format' => true,
    },
    notify => Class['fluentd::service']
  }
  
  # receive syslog messages on port 5140
  # all rsyslog daemons on the clients sends theire messages to 5140
  fluentd::configfile { 'rsyslog': }
  fluentd::source { 'rsyslog_main':
    configfile => 'rsyslog',
    type => 'syslog',
    tag => 'system.local',
    config => {
      'port' => '5140',
      'bind' => '0.0.0.0',
    },
    notify => Class['fluentd::service']
  }
```

#### creates on the Collectors side following files : 
```
/etc/td-agent/
  ├── config.d
  │   └── collector.conf
  ├── ...
  ...
```
 
### copy ouput to multiple stores
````
  $logger=[ { 'host' => 'logger-sample01', 'port' => '24224'},
            { 'host' => 'logger-example01', 'port' => '24224', 'standby' => ''} ] 
            
  fluentd::match { 'forward_to_logger':
      configfile  => 'sample_tail',
      pattern     => 'alocal',
      type        => 'copy',
      config      => [
      {
        'type'               => 'forward',
        'send_timeout'       => '60s',
        'recover_wait'       => '10s',
        'heartbeat_interval' => '1s',
        'phi_threshold'      => 8,
        'hard_timeout'       => '60s',
        'flush_interval'     => '5s',
        'servers'            => $logger,
      },
      {
        'type'              => 'stdout',
        'output_type'       => 'json',
      }
      ],
      notify => Class['fluentd::service']
  }

```

### add a filter
```
    fluentd::configfile { 'myfilter': }
    fluentd::filter { 'myfilter_main':
      configfile          => 'myfilter',
      pattern             => '**',
      type                => 'grep',
      input_key           => 'key',
      regexp              => '/*.foo.*/',
      exclude             => 'baar',
      output_tag          => 'mytag',
      add_tag_prefix      => 'pre_',
      remove_tag_prefix   => 'remove_',
      add_tag_suffix      => '_after',
      remove_tag_suffix   => '_remove',
      config     => {
        'customvalue' => true,
      }
    }
```
