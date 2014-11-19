define pacemaker::resource::service($group='',
                                    $clone=false,
                                    $interval='30s',
                                    $monitor_params=undef,
                                    $ensure='present',
                                    $options='') {

  include ::pacemaker::params
  $res = "pacemaker::resource::${::pacemaker::params::services_manager}"
  create_resources($res,
    { "$name" => { group    => $group,
                  clone    => $clone,
                  interval => $interval,
                  monitor_params => $monitor_params,
                  ensure   => $ensure,
                  options  => $options,
                }
    })
}
