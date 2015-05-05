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
- stdlib: "https://github.com/puppetlabs/puppetlabs-stdlib.git"

## Contributing

- Fork it
- Create a feature branch (`git checkout -b my-new-feature`)
- Run rspec tests (`bundle exec rake spec` or `rake spec`)
- Commit your changes (`git commit -am 'Added some feature'`)
- Push to the branch (`git push origin my-new-feature`)
- Create new Pull Request

### Branches in this module
- **master** tested and working. Latest Version on http://forge.puppetlabs.com
- **developmemt** includes the newewst features. works too, mostly. 

## Configuration

How to configure a Agent to send data to a centralised Fluentd-Server

### Install a Plugin

Install your fluentd plugin. (Check [here](http://fluentd.org/plugin/) for the
right plugin name.)

You can choose from a file or gem based installation.

```
include ::fluentd

fluentd::install_plugin { 'elasticsearch':
  plugin_type => 'gem',
  plugin_name => 'fluent-plugin-elasticsearch',
}
```

### Create an Agent

The agent watches over your logfiles and sends its content to the collector.

```
include ::fluentd

fluentd::source { 'apache':
  config => {
    'format'   => 'apache2',
    'path'     => '/var/log/apache2/access.log',
    'pos_file' => '/var/tmp/fluentd.pos',
    'tag'      => 'apache.access_log',
    'type'     => 'tail',
  },
}

fluentd::source { 'syslog':
  config => {
    'format'   => 'syslog',
    'path'     => '/var/log/syslog',
    'pos_file' => '/tmp/td-agent.syslog.pos',
    'tag'      => 'system.syslog',
    'type'     => 'tail',
  },
}

fluentd::match { 'forward':
  pattern  => '**',
  priority => '80',
  config   => {
    'type'    => 'forward',
    'servers' => [
      { 'host' => 'fluentd.example.com', 'port' => '24224' }
    ],
  },
}

# ensure an old config is no longer there
fluentd::source { 'some_source':
  ensure => 'absent',
}
```

...creates the following files:

```
/etc/td-agent/
  ├── config.d
  │   ├── 50-source-apache.conf
  │   ├── 50-source-syslog.conf
  │   └── 80-match-forward.conf
  ├── ...
  ...
```

### Create a Collector

The Collector collects all the data from the Agents. He now stores the data in
files, Elasticsearch or elsewhere.

```
include ::fluentd

fluentd::source { 'collector':
  priority => '10',
  config   => {
    'type' => 'forward',
  }
}

fluentd::match { 'collector':
  pattern => '**',
  config  => {
    'type'            => 'elasticsearch',
    'logstash_format' => true,
  },
}

# all rsyslog daemons on the clients sends their messages to 5140
fluentd::source { 'rsyslog':
  type   => 'syslog',
  config => {
    'port' => '5140',
    'bind' => '0.0.0.0',
    'tag'  => 'system.local',
  },
}
```

...creates the following files:

```
/etc/td-agent/
  ├── config.d
  │   ├── 10-source-collector.conf
  │   ├── 50-match-collector.conf
  │   └── 50-source-rsyslog.conf
  ├── ...
  ...
```

### Copy output to multiple stores

An array of configurations implies type "copy".

````
$logger=[ { 'host' => 'logger-sample01', 'port' => '24224'},
          { 'host' => 'logger-example01', 'port' => '24224', 'standby' => ''} ]

fluentd::match { 'forward_to_logger':
  pattern => 'alocal',
  config  => [
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
}
```

### add a filter
```
    fluentd::filter { 'myfilter':
      pattern             => '**',
      config     => {
        'type'                => 'grep',
        'input_key'           => 'key',
        'regexp'              => '/*.foo.*/',
        'exclude'             => 'baar',
        'output_tag'          => 'mytag',
        'add_tag_prefix'      => 'pre_',
        'remove_tag_prefix'   => 'remove_',
        'add_tag_suffix'      => '_after',
        'remove_tag_suffix'   => '_remove',
        'customvalue' => true,
      }
    }
```
