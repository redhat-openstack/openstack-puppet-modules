require 'spec_helper'

describe 'pacemaker::new::wrapper', type: :define do
  before(:each) do
    puppet_debug_override
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:title) { 'my_service' }

      let(:pre_condition) do
        <<-eof
service { 'my_service' :
  ensure => 'running',
  enable => 'true',
}
        eof
      end

      context 'when the primitive type or class is not set' do
        it 'should fail' do
          expect do
            is_expected.to compile.with_all_deps
          end.to raise_error /Both primitive_type and primitive_class should be set/
        end
      end

      context 'when parameters are set' do

        let(:params) do
          {
              primitive_type: 'Dummy',
              primitive_provider: 'pacemaker',
              parameters: {
                  'fake' => 'test',
              },
              operations: {
                  'monitor' => {
                      'timeout' => '10',
                      'interval' => '20',
                  },
                  'start' => {
                      'timeout' => '30',
                  },
                  'stop' => {
                      'timeout' => '30',
                  },
              },
              metadata: {
                  'resource-stickiness' => '1',
              },
              service_provider: 'pacemaker_xml',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_pacemaker__new__wrapper('my_service') }

        it 'should set the wrapped service provider to the Pacemaker one' do
          is_expected.to contain_service('my_service').with_provider 'pacemaker_xml'
        end

        it 'should create a Pacemaker resource for the service' do
          parameters = {
              ensure: 'present',
              primitive_class: 'ocf',
              primitive_type: 'Dummy',
              primitive_provider: 'pacemaker',
              parameters: {
                  'fake' => 'test',
              },
              operations: {
                  'monitor' => {
                      'timeout' => '10',
                      'interval' => '20',
                  },
                  'start' => {
                      'timeout' => '30',
                  },
                  'stop' => {
                      'timeout' => '30',
                  },
              },
              metadata: {
                  'resource-stickiness' => '1',
              },
              before: ['Service[my_service]'],
          }

          is_expected.to contain_pacemaker_resource('my_service').with(parameters)
        end

        it 'should override the service type provider' do
          is_expected.to contain_service('my_service').with_provider('pacemaker_xml')
        end

        it 'should create a handler for this service' do
          handler_text = <<-'eof'
#!/bin/sh
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
export OCF_ROOT='/usr/lib/ocf'
export OCF_RA_VERSION_MAJOR='1'
export OCF_RA_VERSION_MINOR='0'
export OCF_RESOURCE_INSTANCE='my_service'

# OCF Parameters
export OCF_RESKEY_fake='test'

help() {
cat<<EOF
OCF wrapper for my_service Pacemaker primitive

Usage: ocf_handler_my_service [-dh] (action)

Options:
-d - Use set -x to debug the shell script
-h - Show this help

Main actions:
* start
* stop
* monitor
* meta-data
* validate-all

Multistate:
* promote
* demote
* notify

Migration:
* migrate_to
* migrate_from

Optional and unused:
* usage
* help
* status
* reload
* restart
* recover
EOF
}

color() {
  '/bin/echo' -e "\033[${1}m${2}\033[0m"
}

red() {
  color 31 "${1}"
}

green() {
  color 32 "${1}"
}

blue() {
  color 34 "${1}"
}

ec2error() {
  case "${1}" in
    0) green 'Success' ;;
    1) red 'Error: Generic' ;;
    2) red 'Error: Arguments' ;;
    3) red 'Error: Unimplemented' ;;
    4) red 'Error: Permissions' ;;
    5) red 'Error: Installation' ;;
    6) red 'Error: Configuration' ;;
    7) blue 'Not Running' ;;
    8) green 'Master Running' ;;
    9) red 'Master Failed' ;;
    *) red "Unknown" ;;
  esac
}

DEBUG='0'
while getopts ':dh' opt; do
  case $opt in
    d)
      DEBUG='1'
      ;;
    h)
      help
      exit 0
      ;;
    \?)
      echo "Invalid option: -${OPTARG}" >&2
      help
      exit 1
      ;;
  esac
done

shift "$((OPTIND - 1))"

ACTION="${1}"

# set default action to monitor
if [ "${ACTION}" = '' ]; then
  ACTION='monitor'
fi

# alias status to monitor
if [ "${ACTION}" = 'status' ]; then
  ACTION='monitor'
fi

# view defined OCF parameters
if [ "${ACTION}" = 'params' ]; then
  env | grep 'OCF_'
  exit 0
fi

if [ "${DEBUG}" = '1' ]; then
  bash -x /usr/lib/ocf/resource.d/pacemaker/Dummy "${ACTION}"
else
  /usr/lib/ocf/resource.d/pacemaker/Dummy "${ACTION}"
fi
ec="${?}"

message="$(ec2error ${ec})"
echo "Exit status: ${message} (${ec})"
exit "${ec}"
          eof

          parameters = {
              ensure: 'present',
              owner: 'root',
              group: 'root',
              mode: '0700',
              content: handler_text,
          }

          is_expected.to contain_file('ocf_handler_my_service').with(parameters)
        end

        context 'with prefix enabled' do
          let(:params) do
            {
                prefix: true,
                primitive_type: 'Dummy',
            }
          end

          it 'should create the resource with "p_" prefix' do
            is_expected.to contain_pacemaker_resource('p_my_service')
          end
        end

        context 'with create_primitive disables' do
          let(:params) do
            {
                create_primitive: false,
                primitive_type: 'Dummy',
            }
          end

          it 'should not create the Pacemaker resource' do
            is_expected.not_to contain_pacemaker_resource('my_service')
          end
        end

        context 'with ocf file source provided' do
          let(:params) do
            {
                ocf_script_file: 'pacemaker/my-ocf-file.sh',
                primitive_type: 'Dummy',
                primitive_provider: 'pacemaker',
            }
          end

          it 'should create the OCF file' do
            parameters = {
                path: '/usr/lib/ocf/resource.d/pacemaker/Dummy',
                ensure: 'present',
                mode: '0755',
                owner: 'root',
                group: 'root',
                source: 'puppet:///modules/pacemaker/my-ocf-file.sh',
                before: ['Pacemaker_resource[my_service]'],
                notify: ['Service[my_service]'],
            }
            is_expected.to contain_file('my_service-ocf-file').with(parameters)
          end
        end

        context 'when the service name is set' do
          let(:params) do
            {
                primitive_type: 'Dummy',
                primitive_provider: 'pacemaker',
                service: 'another_service',
            }
          end

          it 'should create a correct primitive' do
            is_expected.to contain_pacemaker_resource('another_service')
          end

          it 'should create a correct handler' do
            is_expected.to contain_file('ocf_handler_another_service')
          end
        end

        context 'with "systemd" primitive class' do
          let(:params) do
            {
                primitive_type: 'my_service',
                primitive_class: 'systemd',
            }
          end

          it 'should create a native "systemd" primitive' do
            parameters = {
                ensure: 'present',
                primitive_class: 'systemd',
                primitive_type: 'my_service',
                primitive_provider: nil,
            }

            is_expected.to contain_pacemaker_resource('my_service').with(parameters)
          end

          it 'should not create a wrapper' do
            is_expected.not_to contain_file('my_service-ocf-file')
          end

        end

        context 'when "service_override" is disabled' do
          let(:params) do
            {
              primitive_class: 'pacemaker',
              primitive_type: 'my_service',
              service_override: false,
            }
          end
          it 'should not override the service type provider' do
            is_expected.not_to contain_service('my_service').with_provider('pacemaker_xml')
          end
        end

      end

    end
  end
end
