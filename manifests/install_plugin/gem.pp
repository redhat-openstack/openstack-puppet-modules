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
    $ensure      = 'present',
    $plugin_name = $name,
) {

    case $::osfamily {
        'debian': {
            $fluent_gem_path = '/usr/lib/fluent/ruby/bin/fluent-gem'
        }
        'redhat': {
            $fluent_gem_path = '/usr/lib64/fluent/ruby/bin/fluent-gem'
        }
        default: {
            fail("${::osfamily} is currently not supported by this module")
        }
    }
    case $ensure {
        present: {
            exec {
                "install_fluent-${plugin_name}":
                    command => "${fluent_gem_path} install ${plugin_name}",
                    user    => 'root',
                    unless  => "${fluent_gem_path} list --local ${plugin_name} | /bin/grep -q ${plugin_name}",
                    notify  => Service["${fluentd::service_name}"];
            }
        }
        absent: {
            exec {
                "install_fluent-${plugin_name}":
                    command => "${fluent_gem_path} uninstall ${plugin_name}",
                    user    => 'root',
                    unless  => "${fluent_gem_path} list --local ${plugin_name} | /bin/grep -qv ${plugin_name}",
                    notify  => Service["${fluentd::service_name}"];
            }
        }
        default: {
            fail("ensure => ${ensure} is currently not supported by this module")
        }
    }
}
