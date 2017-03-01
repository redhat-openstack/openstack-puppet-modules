# == fluentd::install_plugin::file
#
# install a plugin with by copying a file to /etc/${fluentd::product_name}/plugins
#
# Parameters:
#  the name of this ressource reflects the filename of the plugin, which must
#  be copied to fluentd/files
#
#  ensure:      "present"(default) or "absent", install or uninstall a plugin
#
define fluentd::install_plugin::file (
    $ensure      = 'present',
    $plugin_name = $name,
) {
    file {
        "/etc/${fluentd::product_name}/plugin/${plugin_name}":
            ensure => $ensure,
            owner  => ${fluentd::product_name},
            group  => ${fluentd::product_name},
            mode   => '0640',
            source => "puppet:///fluentd/plugins/${plugin_name}",
            notify => Service["${::fluentd::service_name}"];
    }
}
