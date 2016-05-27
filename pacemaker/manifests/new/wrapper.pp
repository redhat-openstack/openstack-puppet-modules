# == Define: pacemaker::new::wrapper
#
# This definition can be added to a simple service to turn it into
# a Pacemaker service together with Pacemaker resource and handler creation.
#
# [*ensure*]
#   (optional) Create or remove the files
#   Default: present
#
# [*ocf_root_path*]
#   (optional) Path to the ocf folder
#   Default: /usr/lib/ocf
#
# [*primitive_class*]
#   Class of the created primitive
#   Default: ocf
#
# [*primitive_provider*]
#   (optional) Provider of the created primitive
#   Default: undef
#
# [*primitive_type*]
#   Type of the created primitive. Set this to your OCF script.
#   Default: undef
#
# [*prefix*]
#   (optional) Use p_ prefix for the Pacemaer primitive
#   Default: false
#
# [*service*]
#   Set the rela name of the service. The title will be used unless set.
#   Default: undef
#
# [*parameters*]
#   (optional) Instance attributes hash of the primitive
#   Default: undef
#
# [*operations*]
#   (optional) Operations hash of the primitive
#   Default: undef
#
# [*metadata*]
#   (optional) Primitive meta-attributes hash
#   Default: undef
#
# [*complex_metadata*]
#   (optional) Meta-attributes of the complex primitive
#   Default: undef
#
# [*complex_type*]
#   (optional) Set this to 'clone' or 'master' to create a complex primitive
#   Default: undef
#
# [*use_handler*]
#   (optional) Should the handler script be created
#   Default: true
#
# [*handler_root_path*]
#   (optional) Where the handler should be placed
#   Default: /usr/local/bin
#
# [*ocf_script_template*]
#   (optional) Generate the OCF script from this template
#   Default: undef
#
# [*ocf_script_file*]
#   (optional) Download the OCF script from this file
#   Default: undef
#
# [*create_primitive*]
#   (optional) Should the Pcemaker primitive be created
#   Default: true
#
# [*service_override*]
#   Should the service provider be overriden?
#   Default: true
#
# [*service_provider*]
#   (optional) The name of Pacemaker service provider
#   to be set to this service.
#   Default: pacemaker_xml
#
define pacemaker::new::wrapper (
  $ensure              = 'present',
  $ocf_root_path       = '/usr/lib/ocf',
  $primitive_class     = 'ocf',
  $primitive_provider  = undef,
  $primitive_type      = undef,
  $prefix              = false,
  $service             = undef,

  $parameters          = undef,
  $operations          = undef,
  $metadata            = undef,

  $complex_metadata    = undef,
  $complex_type        = undef,

  $use_handler         = true,
  $handler_root_path   = '/usr/local/bin',

  $ocf_script_template = undef,
  $ocf_script_file     = undef,

  $create_primitive    = true,
  $service_override    = true,
  $service_provider    = 'pacemaker_xml'
) {
  validate_absolute_path($ocf_root_path)

  validate_string($primitive_class)
  validate_string($primitive_type)

  validate_bool($prefix)
  validate_absolute_path($handler_root_path)
  validate_bool($create_primitive)
  validate_bool($service_override)

  if empty($primitive_type) or empty($primitive_class) {
    fail 'Both primitive_type and primitive_class should be set!'
  }

  $service_name = pick($service, $name)

  if $prefix {
    $primitive_name = "p_${service_name}"
  } else {
    $primitive_name = $service_name
  }

  $ocf_script_name  = "${service_name}-ocf-file"
  $ocf_handler_name = "ocf_handler_${service_name}"

  $ocf_dir_path     = "${ocf_root_path}/resource.d"
  $ocf_script_path  = "${ocf_dir_path}/${primitive_provider}/${primitive_type}"
  $ocf_handler_path = "${handler_root_path}/${ocf_handler_name}"

  if $service_override {
    Service <| title == $service_name |> {
      provider => $service_provider,
    }

    Service <| name == $service_name |> {
      provider => $service_provider,
    }
  }

  if $create_primitive {
    pacemaker_resource { $primitive_name :
      ensure             => $ensure,
      primitive_class    => $primitive_class,
      primitive_type     => $primitive_type,
      primitive_provider => $primitive_provider,
      parameters         => $parameters,
      operations         => $operations,
      metadata           => $metadata,
      complex_metadata   => $complex_metadata,
      complex_type       => $complex_type,
    }
  }

  if $ocf_script_template or $ocf_script_file {
    file { $ocf_script_name :
      ensure => $ensure,
      path   => $ocf_script_path,
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
    }

    if $ocf_script_template {
      File[$ocf_script_name] {
        content => template($ocf_script_template),
      }
    } elsif $ocf_script_file {
      File[$ocf_script_name] {
        source => "puppet:///modules/${ocf_script_file}",
      }
    }
  }

  if ($primitive_class == 'ocf') and ($use_handler) {
    file { $ocf_handler_name :
      ensure  => $ensure,
      path    => $ocf_handler_path,
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      content => template('pacemaker/ocf_handler.sh.erb'),
    }
  }

  File <| title == $ocf_script_name |> ->
  Pacemaker_resource <| title == $primitive_name |>

  File <| title == $ocf_script_name |> ~>
  Service <| title == $service_name |>

  Pacemaker_resource <| title == $primitive_name |> ->
  Service <| title == $service_name |>

  File <| title == $ocf_handler_name |> ->
  Service <| title == $service_name |>

  File <| title == $ocf_script_name |> ~>
  Service <| name == $service_name |>

  Pacemaker_resource <| title == $primitive_name |> ->
  Service <| name == $service_name |>

  File <| title == $ocf_handler_name |> ->
  Service <| name == $service_name |>

}
