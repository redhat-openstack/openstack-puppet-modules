# == Class zookeeper::repo
#
# This class manages yum repository for Zookeeper packages
#

class zookeeper::repo(
  $source = undef,
  $ensure = present,
) {

  if $source {
    case $::osfamily {
      'redhat': {
        case $source {
          undef: {} #nothing to do
          'cloudera': {
            $cdhver = '4'
            $osrel = $::operatingsystemmajrelease

            case $::hardwaremodel {
              'i386', 'x86_64': {
                $repourl = "http://archive.cloudera.com/cdh${cdhver}/redhat/6/${::hardwaremodel}/cdh/cloudera-cdh${cdhver}.repo"
              }
              default: {
                fail("Yum repository '${source}' is not supported for architecture ${::hardwaremodel}")
              }
            }
            case $osrel {
              '6', '7': {
                # parameter ensure is not supported before Puppet 3.5
                if versioncmp($::puppetversion, '3.5.0') >= 0 {
                  yumrepo { "cloudera-cdh${cdhver}":
                    ensure   => $ensure,
                    descr    => "Cloudera's Distribution for Hadoop, Version ${cdhver}",
                    baseurl  => "http://archive.cloudera.com/cdh${cdhver}/redhat/6/${::hardwaremodel}/cdh/${cdhver}/",
                    gpgkey   => "http://archive.cloudera.com/cdh${cdhver}/redhat/6/${::hardwaremodel}/cdh/RPM-GPG-KEY-cloudera",
                    gpgcheck => 1
                  }
                } else {
                  yumrepo { "cloudera-cdh${cdhver}":
                    descr    => "Cloudera's Distribution for Hadoop, Version ${cdhver}",
                    baseurl  => "http://archive.cloudera.com/cdh${cdhver}/redhat/6/${::hardwaremodel}/cdh/${cdhver}/",
                    gpgkey   => "http://archive.cloudera.com/cdh${cdhver}/redhat/6/${::hardwaremodel}/cdh/RPM-GPG-KEY-cloudera",
                    gpgcheck => 1
                  }
                }
              }
              default: {
                fail("Yum repository '${source}' is not supported for redhat version ${osrel}")
              }
            }
          }
        }
      }
      default: {
        fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
      }
    }
  }
}
