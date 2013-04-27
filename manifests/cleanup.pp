define ipa::cleanup (
  $svrpkg = {},
  $clntpkg = {}
){

  Cron["k5start_admin"] -> Cron["k5start_root"] -> Exec[$name]

  exec {
    "$name":
      command   => "/bin/bash -c \"if [ -x /usr/sbin/ipactl ]; then /usr/sbin/ipactl stop ; fi ;\
                   if [ -n \"${::ipaadminhomedir}\" ] && [ -d ${::ipaadminhomedir} ]; then /bin/rm -rf ${::ipaadminhomedir} ; fi ;\
                   if [ -x /usr/sbin/ipa-server-install ]; then /usr/sbin/ipa-server-install --uninstall --unattended ; fi ;\
                   if [ -d /var/lib/pki-ca ]; then /usr/bin/pkiremove -pki_instance_root=/var/lib -pki_instance_name=pki-ca -force ; fi ;\
                   /usr/bin/yum -y remove ${svrpkg} ${clntpkg} krb5-server 389-ds-base 389-ds-base-libs pki-ca pki-util pki-ca certmonger pki-native-tools pki-symkey pki-setup ipa-pki-common-theme pki-selinux ipa-pki-ca-theme ;\
                   if [ -f /etc/ipa/default.conf ]; then /bin/rm -rf /etc/ipa/default.conf ; fi ;\
                   if [ -d /var/lib/certmonger/ ]; then /bin/rm -rf /var/lib/certmonger/ ; fi ;\
                   if [ -d /var/lib/ipa \]; then /bin/rm -rf /var/lib/ipa ; fi ;\
                   if [ -d /var/lib/ipa-client/ ]; then /bin/rm -rf /var/lib/ipa-client/ ; fi ;\
                   if [ -d /etc/ipa/ ]; then /bin/rm -rf /etc/ipa/ ; fi\"",
      timeout   => '0',
      logoutput => true,
  }

  Cron <|title == 'k5start_root'|> {
    ensure  => "absent",
    require => undef
  }

  cron {
    "k5start_admin":
      ensure  => "absent",
      command => "/usr/bin/k5start -f ${::ipaadminhomedir}/admin.keytab -U -o admin -k /tmp/krb5cc_${::ipaadminuidnumber} > /dev/null 2>&1",
      user    => 'root',
      minute  => "*/1";
  }<- notify { "Running IPA install cleanup, please wait.": }
}
