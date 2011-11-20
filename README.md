# puppet-timezone

Manage timezone settings via Puppet

## How to use

### Set timezone to UTC
```
    class { 'timezone':
        timezone => "UTC",
    }
```

### Set timezone to Europe/Berlin
```
    class { 'timezone':
        timezone => "Europe/Berlin",
    }
```
