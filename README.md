#kibana3 [![Build Status](https://travis-ci.org/thejandroman/kibana3.svg?branch=master)](https://travis-ci.org/thejandroman/kibana3)

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [Examples](#examples)
4. [Usage](#usage)
    * [Classes](#classes)
      * [kibana3](#class-kibana3)
5. [Limitiations](#limitations)
6. [Contributing](#contributing)
7. [License](#license)

##Overview
The kibana3 puppet module allows one to setup and configure the [kibana3](http://www.elasticsearch.org/overview/kibana/) interface to Logstash and ElasticSearch.

##Module Description
This module should cover all configuration options for kibana3 v3.0.0.

This module checks out the [kibana3 source](https://github.com/elasticsearch/kibana) directly from github and requires git to be installed. By default this module will install git via the [puppetlabs/git](https://github.com/puppetlabs/puppetlabs-git) module. This behavior can be disabled.

Kibana3 requires a webserver to serve its content. By default this module will install apache via the [puppetlabs/apache](https://github.com/puppetlabs/puppetlabs-apache) module. This behavior can be disabled.

##Setup
Kibana3 can be installed with a base configuration with `include kibana3` with default configuration options. To disable managing of git or apache see options below.

This module also provides for a way to uninstall via the `ensure` parameter. If `ensure => 'absent'` is specified and `manage_ws => true` and/or `manage_git => true` is specified, the respective module's packages and configs will also be uninstalled.

###Examples
To install kibana3 accepting all default options:
```puppet
  include kibana3
```
To specify a specific elasticsearch host to kibana3:
```puppet
  class {
    'kibana3':
      config_es_port     => '9201',
      config_es_protocol => 'https',
      config_es_server   => 'es.my.domain',
  }
```
To manage webserver configuration outside of the kibana3 module:
```puppet
  class {
    'kibana3':
      manage_ws => false,
  }
```

## Usage
###Classes
####Class: `kibana3`
#####`ensure`
**Data Type:** _string_
**Default:** _present_
Set to 'absent' to uninstall. Beware, if `manage_git` or `manage_ws` are set to true their respective module's packages and configs will also be uninstalled.

#####`config_default_route`
**Data Type:** _string_
**Default:** _/dashboard/file/default.json_
This is the default landing page when you don't specify a dashboard to load. You can specify files, scripts or saved dashboards here. For example, if you had saved a dashboard called 'WebLogs' to elasticsearch you might
use: `config_default_route => '/dashboard/elasticsearch/WebLogs',`

#####`config_es_port`
**Data Type:** _string_
**Default:** _9200_
The port of the elasticsearch server. Because kibana3 is browser based this must be accessible from the browser loading kibana3.

#####`config_es_protocol`
**Data Type:** _string_
**Default:** _http_
The protocol (http/https) of the elasticsearch server. Because kibana3 is browser based this must be accessible from the browser loading kibana3.

#####`config_es_server`
**Data Type:** _string_
**Default:** _"+window.location.hostname+"_
The FQDN of the elasticsearch server. Because kibana3 is browser based this must be accessible from the browser loading kibana3.

#####`config_kibana_index`
**Data Type:** _string_
**Default:** _kibana-int_
The default ES index to use for storing Kibana specific object such as stored dashboards.

#####`config_panel_names`
**Data Type:** _array_
**Default:** _['histogram','map','goal','table','filtering','timepicker','text','hits','column','trends','bettermap','query','terms','stats','sparklines']_
An array of panel modules available. Panels will only be loaded when they are defined in the dashboard, but this list is used in the "add panel" interface.

#####`k3_folder_owner`
**Data Type:** _string_
**Default:** _undef_
The owner of the kibana3 install located at `k3_install_folder`. If `k3_folder_owner` remains 'undef' it defaults to one of two case:
 * if `manage_ws => false` then `k3_folder_owner => 'root'`
 * if `manage_ws => true` then `k3_folder_owner => $::apache::params::user`

#####`k3_install_folder`
**Data Type:** _string_
**Default:** _/opt/kibana3_
The folder to install kibana3 into.

#####`k3_release`
**Data Type:** _string_
**Default:** _a50a913 (v3.0.1)_
A tag or branch from the [kibana3](https://github.com/elasticsearch/kibana) repo. Note that you should use the commit hash instead of the tag name (see [issue #5](https://github.com/thejandroman/kibana3/issues/5)) or puppet will overwrite the config.js file.

#####`manage_git`
**Data Type:** _bool_
**Default:** _true_
Should the module manage git.

#####`manage_ws`
**Data Type:** _bool_
**Default:** _true_
Should the module manage the webserver.

#####`ws_port`
**Data Type:** _bool_
**Default:** _true_
Change the default port for the webserver to a custom value. Only taken into account if `manage_ws => true`.

##Limitations
 * Tested and built on Ubuntu 12.04.
 * Tested with Kibana v3.0.0.

##Contributing
Pull requests are welcome. Please document and include rspec tests.

##License
See [LICENSE](https://github.com/thejandroman/kibana3/blob/master/LICENSE) file.
