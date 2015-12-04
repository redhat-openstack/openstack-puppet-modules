# == fluentd::install_plugin::file
#
# install a plugin with by copying a file to /etc/td-agent/plugins
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
        "/etc/td-agent/plugin/${plugin_name}":
            ensure => $ensure,
            owner  => td-agent,
            group  => td-agent,
            mode   => '0640',
            source => "puppet:///fluentd/plugins/${plugin_name}",
            notify => Service["${::fluentd::service_name}"];
    }
}
