# certmonger puppet module

very simple puppet module to request IPA certs via certmonger.

This requires that the machine already be enrolled in an IPA server

When using an NSS database this has a side-effect of creating a file
in the enrolled subdirectory of the NSS database named after the principal.
This is an indicator that the certificate has already been requested.

Be aware of SELinux too. You can't just put NSS databases in any directory
you want. The certmonger status will probably be in NEED_KEY_PAIR in the
case of a AVC.

certmonger uses the host principal on the machine to communicate with IPA.
By default, host principals do not have permission to add new services.
This means you'll probably need to pre-create the services, otherwise
you'll get a status like this:

Request ID '20130823131914':
        status: CA_REJECTED
        ca-error: Server denied our request, giving up: 2100 (RPC failed at server.  Insufficient access: You need to be a member of the serviceadmin role to add services).

When generating an OpenSSL certificate we need to let certmonger create the
key and cert files. If puppet does it first then certmonger will think that
the user provided a key to use (a blank file) and things fail. The current
workaround is to call getcert -f /path/to/cert to make sure the key exists.

TESTING

Between OpenSSL invocations you'll want to clean up. This is what I do:

getcert stop-tracking -i `getcert list -f /tmp/test.crt |grep ID |cut -d\' -f2`
rm -f /tmp/test.key  /tmp/test.crt 
