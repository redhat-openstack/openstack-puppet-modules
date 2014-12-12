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
class manila::quota (
  $quota_shares = 10,
  $quota_snapshots = 10,
  $quota_gigabytes = 1000,
  $quota_driver = 'manila.quota.DbQuotaDriver'
) {

  manila_config {
    'DEFAULT/quota_shares':    value => $quota_shares;
    'DEFAULT/quota_snapshots': value => $quota_snapshots;
    'DEFAULT/quota_gigabytes': value => $quota_gigabytes;
    'DEFAULT/quota_driver':    value => $quota_driver;
  }
}
