# == Class: manila::quota
#
# Setup and configure Manila quotas.
#
# === Parameters
#
# [*quota_shares*]
#   (optional) Number of shares allowed per project. Defaults to 10.
#
# [*quota_snapshots*]
#   (optional) Number of share snapshots allowed per project. Defaults to 10.
#
# [*quota_gigabytes*]
#   (optional) Number of share gigabytes (snapshots are also included)
#   allowed per project. Defaults to 1000.
#
# [*quota_driver*]
#   (optional) Default driver to use for quota checks.
#   Defaults to 'manila.quota.DbQuotaDriver'.
#
# [*quota_snapshot_gigabytes*]
#   (optional) Number of snapshot gigabytes allowed per project.
#   Defaults to 1000.
#
# [*quota_share_networks*]
#   (optional) Number of share-networks allowed per project.
#   Defaults to 10.
#
# [*reservation_expire*]
#   (optional) Number of seconds until a reservation expires.
#   Defaults to 86400.
#
# [*until_refresh*]
#   (optional) Count of reservations until usage is refreshed.
#   Defaults to 0.
#
# [*max_age*]
#   (optional) Number of seconds between subsequent usage refreshes.
#   Defaults to 0.
#
class manila::quota (
  $quota_shares             = 10,
  $quota_snapshots          = 10,
  $quota_gigabytes          = 1000,
  $quota_driver             = 'manila.quota.DbQuotaDriver',
  $quota_snapshot_gigabytes = 1000,
  $quota_share_networks     = 10,
  $reservation_expire       = 86400,
  $until_refresh            = 0,
  $max_age                  = 0,
) {

  manila_config {
    'DEFAULT/quota_shares':             value => $quota_shares;
    'DEFAULT/quota_snapshots':          value => $quota_snapshots;
    'DEFAULT/quota_gigabytes':          value => $quota_gigabytes;
    'DEFAULT/quota_driver':             value => $quota_driver;
    'DEFAULT/quota_snapshot_gigabytes': value => $quota_snapshot_gigabytes;
    'DEFAULT/quota_share_networks':     value => $quota_share_networks;
    'DEFAULT/reservation_expire':       value => $reservation_expire;
    'DEFAULT/until_refresh':            value => $until_refresh;
    'DEFAULT/max_age':                  value => $max_age;
  }
}
