# == fluentd::install_plugin
#
# install a plugin with either /usr/lib/fluent/ruby/bin/fluent-gem or a file
#
# you need to sepecify wich one of theese options plus the name.
#
# Parameters:
#  the name of this ressource reflects the either the filename of the plugin, which must
#  be copied to fluentd/files or the name of the gem
#
#  plugin_type: specify "file" to copy that file to /etc/fluentd/plugins
#               specify "gem" to try to install the plugin with fluent-gem
#
#  ensure:      "present"(default) or "absent", install or uninstall a plugin
#
define fluentd::install_plugin (
    $plugin_type,
    $ensure      = 'present',
    $plugin_name = $name,
) {
    case $plugin_type {
        'file': {
            fluentd::install_plugin::file {
                [$plugin_name]:
                    ensure => $ensure,
                    require => Class['Fluentd::Packages']
            }
        }
        'gem': {
            fluentd::install_plugin::gem {
                [$plugin_name]:
                    ensure => $ensure, 
                    require => Class['Fluentd::Packages']
            }
        }
        default: {
            fail("plugin_type => ${plugin_type} is currently not supportet by this module")
        }
    }
}
