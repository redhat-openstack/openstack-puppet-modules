# == Define: haproxy::balancermember::collect_exported
#
# Defined type used to collect haproxy::balancermember exported resource
#
# === Parameters
#
# None
#
# === Examples
#
# haproxy::balancermember::collect_exported { 'SomeService': }
#
define haproxy::balancermember::collect_exported {
    Haproxy::Balancermember <<| listening_service == $name |>>
}
