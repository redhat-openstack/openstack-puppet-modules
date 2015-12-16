require 'spec_helper'

RSpec.describe 'fluentd::config' do
  let(:pre_condition) { 'include fluentd' }

  context 'on RedHat based system' do
    let(:facts) { { osfamily: 'RedHat' } }

    let(:title) { 'stdout.conf' }

    context 'when config does not contain nested hashes' do
      let(:params) do
        {
          config: {
            'source' => {
              'type' => 'forward'
            },
            'match' => {
              'tag_pattern' => '**',
              'type' => 'stdout'
            }
          }
        }
      end

      it do
        is_expected.to contain_file('/etc/td-agent/config.d/stdout.conf').
          with_content(/<source >/).
          with_content(/type forward/).
          with_content(/<\/source>/).
          with_content(/<match \*\*>/).
          with_content(/type stdout/).
          with_content(/<\/match>/)
      end
    end

    context 'when config contains nested hashes' do
      let(:params) do
        {
          config: {
            'match' => {
              'tag_pattern' => '**',
              'type' => 'forward',
              'server' => [
                { 'host' => 'example1.com', 'port' => 24224 },
                { 'host' => 'example2.com', 'port' => 24224 }
              ]
            }
          }
        }
      end

      it do
        is_expected.to contain_file('/etc/td-agent/config.d/stdout.conf').
          with_content(/<match \*\*>/).
          with_content(/type forward/).
          with_content(/<server >/).
          with_content(/host example1.com/).
          with_content(/port 24224/).
          with_content(/<\/server>/).
          with_content(/host example2.com/).
          with_content(/<\/match>/)
      end
    end
  end
end
