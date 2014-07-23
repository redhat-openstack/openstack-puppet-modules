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

    package { $plugin_name:
      ensure   => $ensure,
      provider => 'fluentgem',
      notify   => Service["${fluentd::service_name}"];
    }

}
