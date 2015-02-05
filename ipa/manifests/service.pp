# Class: ipa::service
#
# Realizes the IPA service for dependency handling
class ipa::service {
  anchor { 'ipa::service::start': }
  realize Service['ipa']
  anchor { 'ipa::service::end': }

  Anchor['ipa::service::start'] ->
  Service['ipa'] ->
  Anchor['ipa::service::end']

}
