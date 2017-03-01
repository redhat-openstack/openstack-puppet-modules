# Definition: ipa::message
#
# Sends a notification or a fail message to the log during catalog compilation
define ipa::message (
  $type,
  $message
) {
  case $type {
    'debug': {
      debug($message)
    }
    'info': {
      info($message)
    }
    'alert': {
      alert($message)
    }
    'crit': {
      crit($message)
    }
    'emerg': {
      emerg($message)
    }
    'warning': {
      warning($message)
    }
    'notice': {
      notice($message)
    }
    'fail': {
      fail($message)
    }
    default: {
      notify { 'Invalid message type, valid types are debug, info, alert, crit, emerg, err, warning, notice or fail': }
    }
  }
}
