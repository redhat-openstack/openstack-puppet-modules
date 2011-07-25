# puppet-timezone
puppet-timezone is a module for puppet to manage timezone settings on your systems.

## How to use

### Set timezone to UTC
```class { 'timezone':
    timezone => "UTC",
}
```

### Set timezone to Europe/Berlin
```class { 'timezone':
    timezone => "Europe/Berlin",
}
```
