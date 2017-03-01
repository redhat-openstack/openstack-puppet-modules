keepalived

This is the keepalived module.

License
-------

Apache2

Contact
-------

bruno.leon@unyonsys.com

Parameters
==========

[*notification_email_to*] = [ "root@${domain}" ]
  An array of emails to send notifications to

[*notification_email_from*] = "keepalived@${domain}"
  The source adress of notification messages

[*smtp_server*] = 'localhost'
  The SMTP server to use to send notifications.

[*smtp_connect_timeout*] = '30'
  The SMTP server to use to send notifications.

[*router_id*] = $::hostname
  The router_id identifies us on the network.

Variables
=========

[*$keepalived::variables::keepalived_conf*]
  Path to keepalived.conf configuration file

Examples
========

    class { keepalived: }
    keepalived::instance { '50':
      interface         => 'eth0',
      virtual_ips       => [ '192.168.200.17 dev eth0' ],
      state             => hiera( "keepalived_50_state" ),
      priority          => hiera( "keepalived_50_priority" ),
    }

Developement
============

You can run the test-suite with the following commands:

    bundle exec rake spec
    bundle exec rake lint
