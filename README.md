puppet-fluentd
==============

Manage Fluentd installation and configuration with Puppet using the td-agent. 

## Todo's 
- No RedHat suport yet (feel free to send us your pullrequest) 
- Automatic installation of td-agent Plugins

## Configuration

How to Configure a Agent to send Data to a centralised Fluentd-Server


### Create a Agent 

```
  include ::fluentd
  
  fluentd::configfile { 'apache': }
  fluentd::source { 'apache': 
    type => 'tail',
    format => 'apache',
    tag => 'apache.access_log',
    config => {
      'path' => '/var/log/apache2/access.log',
    }
  }
  
  fluentd::configfile { 'syslog': }
  fluentd::source { 'syslog': 
    type => 'syslog',
    tag => 'system',
    config => {
      'port' => '5140',
      'bind' => '0.0.0.0',
    }
  }
  
  fluentd::configfile { 'forward': }
  fluentd::match { 'forward': 
    pattern => '**',
    type => 'forward',
    servers => [
      {'host' => '10.102.80.3', 'port' => '24224'}
    ],
  }
```


### Create a Collector 

```
  include ::fluentd

  fluentd::configfile { 'forward': }
  fluentd::source { 'forward': 
    type => 'forward',
  #  config => {
  #    'port' => '24224',
  #    'bind' => '0.0.0.0',
  #  }
  }


  fluentd::configfile { 'apache': }
  fluentd::match { 'apache': 
    pattern => 'apache.access_log',
    type => 'elasticsearch',
    config => {
      'logstash_format' => 'true',
    }
  }
```
