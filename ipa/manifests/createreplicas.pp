define ipa::createreplicas {

  $replicas = ipa_string2hash($::ipa_replicascheme)
  create_resources('ipa::replicaagreement',$replicas)

}
