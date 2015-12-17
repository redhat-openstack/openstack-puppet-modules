include fluentd

fluentd::plugin { 'fluent-plugin-elasticsearch': }

fluentd::config { '500_elasticsearch.conf':
  config => {
    'source' => {
      'type' => 'unix',
      'path' => '/tmp/td-agent/td-agent.sock',
    },
    'match'  => {
      'tag_pattern'     => '**',
      'type'            => 'elasticsearch',
      'index_name'      => 'foo',
      'type_name'       => 'bar',
      'logstash_format' => true,
    }
  }
}
