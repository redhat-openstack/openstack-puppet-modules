require 'spec_helper_acceptance'

describe 'wget' do

  let(:wget_manifest) { "class { 'wget': }" }
  let(:manifest) { wget_manifest }

  before do
    shell "rm -f /tmp/index*"
  end

  context 'when running as root' do
    let(:manifest) { super() + %Q(
        wget::fetch { "download Google's index":
          source      => 'http://www.google.com/index.html',
          destination => '/tmp/index.html',
          timeout     => 0,
          verbose     => false,
        }
      )
    }

    it 'should be idempotent' do
      apply_manifest(manifest, :catch_failures => true)
      apply_manifest(manifest, :catch_changes => true)
      shell('test -e /tmp/index.html')
    end
  end

  context 'when running as user' do
    before do
      apply_manifest(wget_manifest, :catch_failures => true)
    end

    let(:manifest) { %Q(
      wget::fetch { 'download Google index':
        source      => 'http://www.google.com/index.html',
        destination => '/tmp/index-vagrant.html',
        timeout     => 0,
        verbose     => false,
      }
    ) }

    it "should succeed" do
      shell("cat << EOF | su - vagrant -c 'puppet apply --verbose --detailed-exitcodes --modulepath=/etc/puppet/modules'\n#{manifest}", :acceptable_exit_codes => [2]) do |r|
        expect(r.stdout).to match(%r{Wget::Fetch\[download Google index\].*returns: executed successfully})
      end
      shell('test -e /tmp/index-vagrant.html')
    end
  end

end
