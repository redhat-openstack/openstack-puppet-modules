puppet-fluentd
==============

[![Build Status](https://travis-ci.org/mmz-srf/puppet-fluentd.png?branch=master)](https://travis-ci.org/mmz-srf/puppet-fluentd)

Manage Fluentd installation and configuration with Puppet using the td-agent. 

## Used Modules 
- apt: "https://github.com/puppetlabs/puppetlabs-apt.git"
- concat: "https://github.com/puppetlabs/puppetlabs-concat.git"
- stdlib: "https://github.com/puppetlabs/puppetlabs-stdlib.git"

## Todo's 
- ~~No RedHat suport yet~~ (THX to [pranav](https://github.com/pranav) ) 
- ~~Automatic installation of td-agent Plugins~~ (THX to [darktim](https://github.com/darktim) ) 
- Ouput copy and roundrobin to multiple stores
- ~~Monitor/Restart Service~~ (THX to [darktim](https://github.com/darktim) ) 
- Logrotate td-agent logs

## Contributing
* Fork it
* Create a feature branch (`git checkout -b my-new-feature`)
* Run rspec tests (`bundle exec rake spec` or `rake spec`)
* Commit your changes (`git commit -am 'Added some feature'`)
* Push to the branch (`git push origin my-new-feature`)
* Create new Pull Request

## Configuration
How to Configure a Agent to send Data to a centralised Fluentd-Server

### Create a Agent 
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
    }
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
    }
  }
  
  fluentd::configfile { 'forward': }
  fluentd::match { 'forward_main': 
    configfile => 'forward'
    pattern => '**',
    type => 'forward',
    servers => [
      {'host' => 'PUT_YOUR_HOST_HERE', 'port' => '24224'}
    ],
  }
```
#### creates on the agent side following files : 
```
/etc/td-agent/
  ├── config.d
  │   ├── collector.conf
  │   ├── forward.conf
  │   └── syslog.conf
  ├── ...
  ...
```

### Create a Collector 
```
  include ::fluentd

  fluentd::configfile { 'forward': }
  fluentd::source { 'forward_collector': 
    configfile => 'forward'
    type => 'forward',
  #  config => {
  #    'port' => '24224',
  #    'bind' => '0.0.0.0',
  #  }
  }

  fluentd::match { 'forward_apache': 
    configfile => 'forward'
    pattern => '**',
    type => 'elasticsearch',
    config => {
      'logstash_format' => 'true',
    }
  }
```

#### creates on the agent side following files : 
```
/etc/td-agent/
  ├── config.d
  │   └── forward.conf
  ├── ...
  ...
```
 
