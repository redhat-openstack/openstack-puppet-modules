# puppet-timezone [![Build Status](https://secure.travis-ci.org/saz/puppet-timezone.png)](http://travis-ci.org/saz/puppet-timezone)

Manage timezone settings via Puppet

## Usage

### Set timezone to UTC
```
    class { 'timezone':
        timezone => 'UTC',
    }
```

### Set timezone to Europe/Berlin
```
    class { 'timezone':
        timezone => 'Europe/Berlin',
    }
```

## Other class parameters
* ensure: present or absent, default: present
* autoupgrade: true or false, default: false. Auto-upgrade package, if there is a newer version
* package: string, default: OS specific. Set package name, if platform is not supported.
* config_file: string, default: OS specific. Set config_file, if platform is not supported.
* zoneinfo_dir: string, default: OS specific. Set zoneinfo_dir, if platform is not supported.
