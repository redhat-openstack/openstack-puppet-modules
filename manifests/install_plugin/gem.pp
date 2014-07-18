# == fluentd::install_plugin::gem
#
# install a plugin with /usr/lib/fluent/ruby/bin/fluent-gem
#
# Parameters:
#  the name of this ressource reflects the name of the gem
#
#  ensure:      "present"(default) or "absent", install or uninstall a plugin
#
define fluentd::install_plugin::gem (
    $ensure      = 'latest',
    $plugin_name = $name,
) {

    case $::osfamily {
        'debian': {
            $fluent_gem_path = '/usr/lib/fluent/ruby/bin'
        }
        'redhat': {
            $fluent_gem_path = '/usr/lib64/fluent/ruby/bin'
        }
        default: {
            fail("${::osfamily} is currently not supported by this module")
        }
    }

    package { $plugin_name:
      ensure   => $ensure,
      provider => 'fluentgem',
      path     => "${fluent_gem_path};${::path}",
      notify   => Service["${fluentd::service_name}"];
    }

}
