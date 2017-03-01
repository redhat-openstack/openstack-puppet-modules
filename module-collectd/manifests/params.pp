#
class collectd::params {

  case $::osfamily {
    'Debian': {
      $package           = 'collectd'
      $provider          = 'apt'
      $collectd_dir      = '/etc/collectd'
      $plugin_conf_dir   = "${collectd_dir}/conf.d"
      $service_name      = 'collectd'
      $config_file       = "${collectd_dir}/collectd.conf"
      $root_group        = 'root'
      $java_dir          = '/usr/share/collectd/java'
      $python_dir        = '/usr/share/collectd/python'
    }
    'Solaris': {
      $package           = 'CSWcollectd'
      $provider          = 'pkgutil'
      $collectd_dir      = '/etc/opt/csw'
      $plugin_conf_dir   = "${collectd_dir}/conf.d"
      $service_name      = 'collectd'
      $config_file       = "${collectd_dir}/collectd.conf"
      $root_group        = 'root'
      $java_dir          = undef
      $python_dir        = '/opt/csw/share/collectd/python'
    }
    'Redhat': {
      $package           = 'collectd'
      $provider          = 'yum'
      $collectd_dir      = '/etc/collectd.d'
      $plugin_conf_dir   = $collectd_dir
      $service_name      = 'collectd'
      $config_file       = '/etc/collectd.conf'
      $root_group        = 'root'
      $java_dir          = '/usr/share/collectd/java'
      $python_dir        = '/usr/share/collectd/python'
    }
    'Suse': {
      $package           = 'collectd'
      $provider          = 'zypper'
      $collectd_dir      = '/etc/collectd'
      $plugin_conf_dir   = $collectd_dir
      $service_name      = 'collectd'
      $config_file       = '/etc/collectd.conf'
      $root_group        = 'root'
      $java_dir          = undef
      $python_dir        = '/usr/share/collectd/python'
    }
    'FreeBSD': {
      $package           = 'collectd5'
      $provider          = undef
      $collectd_dir      = '/usr/local/etc/collectd'
      $plugin_conf_dir   = $collectd_dir
      $service_name      = 'collectd'
      $config_file       = '/usr/local/etc/collectd.conf'
      $root_group        = 'wheel'
      $java_dir          = undef
      $python_dir        = '/usr/local/share/collectd/python'
    }
    'Archlinux': {
      $package           = 'collectd'
      $provider          = undef
      $collectd_dir      = '/etc/collectd.d'
      $plugin_conf_dir   = $collectd_dir
      $service_name      = 'collectd'
      $config_file       = '/etc/collectd.conf'
      $root_group        = 'wheel'
      $java_dir          = undef
      $python_dir        = '/usr/share/collectd/python'
    }
    'Gentoo': {
      $package           = 'app-admin/collectd'
      $provider          = 'portage'
      $collectd_dir      = '/etc/collectd.d'
      $plugin_conf_dir   = $collectd_dir
      $service_name      = 'collectd'
      $config_file       = '/etc/collectd.conf'
      $root_group        = 'collectd'
      $java_dir          = undef
      $python_dir        = '/usr/share/collectd/python'
    }

    default: {
      fail("${::osfamily} is not supported.")
    }
  }
}
