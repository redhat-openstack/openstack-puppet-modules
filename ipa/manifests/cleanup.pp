# Definition: ipa::cleanup
#
# Cleans up an IPA installation
define ipa::cleanup (
  $svrpkg  = {},
  $clntpkg = {}
) {

  $pkgrmcmd = $::osfamily ? {
    RedHat => '/usr/bin/yum -y remove',
    Debian => '/usr/bin/aptitude -y purge'
  }

  $pkgcmd = regsubst($pkgrmcmd,'\s.*$','')

  Cron['k5start_admin'] -> Cron['k5start_root'] -> Exec["cleanup-${name}"]

  exec { "cleanup-${name}":
    command   => "/bin/bash -c \"if [ -x /usr/sbin/ipactl ]; then /usr/sbin/ipactl stop ; fi ;\
                 if [ -n \"${::ipa_adminhomedir}\" ] && [ -d ${::ipa_adminhomedir} ]; then /bin/rm -rf ${::ipa_adminhomedir} ; fi ;\
                 if [ -x /usr/sbin/ipa-client-install ]; then /bin/echo | /usr/sbin/ipa-client-install --uninstall --unattended ; fi ;\
                 if [ -x /usr/sbin/ipa-server-install ]; then /usr/sbin/ipa-server-install --uninstall --unattended ; fi ;\
                 if [ -d /var/lib/pki-ca ]; then /usr/bin/pkiremove -pki_instance_root=/var/lib -pki_instance_name=pki-ca -force ; fi ;\
                 if [ -x ${pkgcmd} ]; then ${pkgrmcmd} ${svrpkg} ${clntpkg} krb5-server 389-ds-base 389-ds-base-libs pki-ca pki-util pki-ca certmonger pki-native-tools pki-symkey pki-setup ipa-pki-common-theme pki-selinux ipa-pki-ca-theme ipa-python ; fi ;\
                 if [ -e /etc/openldap/ldap.conf.ipabkp ]; then /bin/cp -f /etc/openldap/ldap.conf.ipabkp /etc/openldap/ldap.conf ; fi ;\
                 if [ -e /etc/krb5.conf.ipabkp ]; then /bin/cp -f /etc/krb5.conf.ipabkp /etc/krb5.conf ; fi ;\
                 if [ -e /etc/krb5.keytab ]; then /bin/mv -f /etc/krb5.keytab /etc/krb5.keytab.puppet-ipa.cleanup ; fi ;\
                 if [ -e /root/ipa.csr ]; then /bin/mv -f /root/ipa.csr /root/ipa.csr.$(/bin/date +%s) ; fi ;\
                 if [ -d /var/lib/certmonger ]; then find /var/lib/certmonger -type f -exec /bin/rm -f '{}' \; ; fi ;\
                 if [ -d /var/lib/ipa ]; then /usr/bin/find /var/lib/ipa -type f -exec /bin/rm -f '{}' \; ; fi ;\
                 if [ -d /var/lib/ipa-client ]; then /usr/bin/find /var/lib/ipa-client -type f -exec /bin/rm -f '{}' \; ; fi ;\
                 if [ -d /etc/ipa ]; then /usr/bin/find /etc/ipa -type f -exec /bin/rm -f '{}' \; ; fi\"",
    timeout   => '0',
    logoutput => true
  }

  Cron <|title == 'k5start_root'|> {
    ensure  => 'absent',
    require => undef
  }

  notify { 'Running IPA install cleanup, please wait.': } ->
  cron { 'k5start_admin': ensure  => 'absent';}
}
