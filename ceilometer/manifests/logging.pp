# == Class: ceilometer::logging
#
# ceilometer logging configuration
#
# === Parameters:
#
# [*verbose*]
#   (Optional) Should the daemons log verbose messages
#   Defaults to $::os_service_default.
#
# [*debug*]
#   (Optional) Should the daemons log debug messages
#   Defaults to $::os_service_default.
#
# [*use_syslog*]
#   (Optional) Use syslog for logging.
#   Defaults to $::os_service_default.
#
# [*use_stderr*]
#   (Optional) Use stderr for logging
#   Defaults to $::os_service_default.
#
# [*log_facility*]
#   (Optional) Syslog facility to receive log lines.
#   Defaults to $::os_service_default.
#
# [*log_dir*]
#   (Optional) Directory where logs should be stored.
#   If set to boolean false, it will not log to any directory.
#   Defaults to '/var/log/ceilometer'.
#
# [*logging_context_format_string*]
#   (Optional) Format string to use for log messages with context.
#   Defaults to $::os_service_default.
#   Example: '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s\
#             [%(request_id)s %(user_identity)s] %(instance)s%(message)s'
#
# [*logging_default_format_string*]
#   (Optional) Format string to use for log messages without context.
#   Defaults to $::os_service_default.
#   Example: '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s\
#             [-] %(instance)s%(message)s'
#
# [*logging_debug_format_suffix*]
#   (Optional) Formatted data to append to log format when level is DEBUG.
#   Defaults to $::os_service_default.
#   Example: '%(funcName)s %(pathname)s:%(lineno)d'
#
# [*logging_exception_prefix*]
#   (Optional) Prefix each line of exception output with this format.
#   Defaults to $::os_service_default.
#   Example: '%(asctime)s.%(msecs)03d %(process)d TRACE %(name)s %(instance)s'
#
# [*log_config_append*]
#   (Optional) The name of an additional logging configuration file.
#   Defaults to $::os_service_default.
#   Example: https://docs.python.org/2/howto/logging.html
#
# [*default_log_levels*]
#   (Optional) Hash of logger (keys) and level (values) pairs.
#   Defaults to $::os_service_default.
#   Example:
#     { 'amqp' => 'WARN', 'amqplib' => 'WARN', 'boto' => 'WARN',
#       'qpid' => 'WARN', 'sqlalchemy' => 'WARN', 'suds' => 'INFO',
#       'iso8601' => 'WARN',
#       'requests.packages.urllib3.connectionpool' => 'WARN' }
#
# [*publish_errors*]
#   (Optional) Publish error events (boolean value).
#   Defaults to $::os_service_default.
#
# [*fatal_deprecations*]
#   (Optional) Make deprecations fatal (boolean value)
#   Defaults to $::os_service_default.
#
# [*instance_format*]
#   (Optional) If an instance is passed with the log message, format it
#              like this (string value).
#   Defaults to $::os_service_default.
#   Example: '[instance: %(uuid)s] '
#
# [*instance_uuid_format*]
#   (Optional) If an instance UUID is passed with the log message, format
#              it like this (string value).
#   Defaults to $::os_service_default.
#   Example: instance_uuid_format='[instance: %(uuid)s] '
#
# [*log_date_format*]
#   (Optional) Format string for %%(asctime)s in log records.
#   Defaults to $::os_service_default.
#   Example: 'Y-%m-%d %H:%M:%S'
#
class ceilometer::logging(
  $use_syslog                    = $::os_service_default,
  $use_stderr                    = $::os_service_default,
  $log_facility                  = $::os_service_default,
  $log_dir                       = '/var/log/ceilometer',
  $verbose                       = $::os_service_default,
  $debug                         = $::os_service_default,
  $logging_context_format_string = $::os_service_default,
  $logging_default_format_string = $::os_service_default,
  $logging_debug_format_suffix   = $::os_service_default,
  $logging_exception_prefix      = $::os_service_default,
  $log_config_append             = $::os_service_default,
  $default_log_levels            = $::os_service_default,
  $publish_errors                = $::os_service_default,
  $fatal_deprecations            = $::os_service_default,
  $instance_format               = $::os_service_default,
  $instance_uuid_format          = $::os_service_default,
  $log_date_format               = $::os_service_default,
) {

  # NOTE(spredzy): In order to keep backward compatibility we rely on the pick function
  # to use ceilometer::<myparam> first then ceilometer::logging::<myparam>.
  $use_syslog_real = pick($::ceilometer::use_syslog,$use_syslog)
  $use_stderr_real = pick($::ceilometer::use_stderr,$use_stderr)
  $log_facility_real = pick($::ceilometer::log_facility,$log_facility)
  $log_dir_real = pick($::ceilometer::log_dir,$log_dir)
  $verbose_real  = pick($::ceilometer::verbose,$verbose)
  $debug_real = pick($::ceilometer::debug,$debug)

  if is_service_default($default_log_levels) {
    $default_log_levels_real = $default_log_levels
  } else {
    $default_log_levels_real = join(sort(join_keys_to_values($default_log_levels, '=')), ',')
  }

  ceilometer_config {
    'DEFAULT/debug':                         value => $debug_real;
    'DEFAULT/verbose':                       value => $verbose_real;
    'DEFAULT/use_stderr':                    value => $use_stderr_real;
    'DEFAULT/use_syslog':                    value => $use_syslog_real;
    'DEFAULT/log_dir':                       value => $log_dir_real;
    'DEFAULT/syslog_log_facility':           value => $log_facility_real;
    'DEFAULT/logging_context_format_string': value => $logging_context_format_string;
    'DEFAULT/logging_default_format_string': value => $logging_default_format_string;
    'DEFAULT/logging_debug_format_suffix':   value => $logging_debug_format_suffix;
    'DEFAULT/logging_exception_prefix':      value => $logging_exception_prefix;
    'DEFAULT/log_config_append':             value => $log_config_append;
    'DEFAULT/default_log_levels':            value => $default_log_levels_real;
    'DEFAULT/publish_errors':                value => $publish_errors;
    'DEFAULT/fatal_deprecations':            value => $fatal_deprecations;
    'DEFAULT/instance_format':               value => $instance_format;
    'DEFAULT/instance_uuid_format':          value => $instance_uuid_format;
    'DEFAULT/log_date_format':               value => $log_date_format;
  }
}
