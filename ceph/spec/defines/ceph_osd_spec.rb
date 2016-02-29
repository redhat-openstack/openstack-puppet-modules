#
#   Copyright (C) 2014 Cloudwatt <libre.licensing@cloudwatt.com>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# Author: Loic Dachary <loic@dachary.org>
# Author: David Gurtner <aldavud@crimson.ch>
#

require 'spec_helper'

describe 'ceph::osd' do

  shared_examples_for 'ceph osd' do

    describe "with default params" do

      let :title do
        '/srv'
      end

      it { is_expected.to contain_exec('ceph-osd-check-udev-/srv').with(
        'command'   => "/bin/true # comment to satisfy puppet syntax requirements
# Before Infernalis the udev rules race causing the activation to fail so we
# disable them. More at: http://www.spinics.net/lists/ceph-devel/msg28436.html
mv -f /usr/lib/udev/rules.d/95-ceph-osd.rules /usr/lib/udev/rules.d/95-ceph-osd.rules.disabled && udevadm control --reload || true
",
       'onlyif'    => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
DISABLE_UDEV=\$(ceph --version | awk 'match(\$3, /[0-9]\\.[0-9]+/) {if (substr(\$3, RSTART, RLENGTH) <= 0.94) {print 1}}')
test -f /usr/lib/udev/rules.d/95-ceph-osd.rules && test \$DISABLE_UDEV -eq 1
",
       'logoutput' => true,
      ) }
      it { is_expected.to contain_exec('ceph-osd-prepare-/srv').with(
        'command'   => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
if ! test -b /srv ; then
  mkdir -p /srv
fi
ceph-disk prepare  /srv 
udevadm settle
",
        'unless'    => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
ceph-disk list | grep -E ' */srv1? .*ceph data, (prepared|active)' ||
ls -l /var/lib/ceph/osd/ceph-* | grep ' /srv\$'
",
        'logoutput' => true
      ) }
      it { is_expected.to contain_exec('ceph-osd-activate-/srv').with(
        'command'   => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
if ! test -b /srv ; then
  mkdir -p /srv
fi
# activate happens via udev when using the entire device
if ! test -b /srv || ! test -b /srv1 ; then
  ceph-disk activate /srv || true
fi
if test -f /usr/lib/udev/rules.d/95-ceph-osd.rules.disabled && test -b /srv1 ; then
  ceph-disk activate /srv1 || true
fi
",
        'unless'    => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
ls -ld /var/lib/ceph/osd/ceph-* | grep ' /srv\$'
",
        'logoutput' => true
      ) }
    end

    describe "with custom params" do

      let :title do
        '/srv/data'
      end

      let :params do
        {
          :cluster => 'testcluster',
          :journal => '/srv/journal',
        }
      end

      it { is_expected.to contain_exec('ceph-osd-check-udev-/srv/data').with(
        'command'   => "/bin/true # comment to satisfy puppet syntax requirements
# Before Infernalis the udev rules race causing the activation to fail so we
# disable them. More at: http://www.spinics.net/lists/ceph-devel/msg28436.html
mv -f /usr/lib/udev/rules.d/95-ceph-osd.rules /usr/lib/udev/rules.d/95-ceph-osd.rules.disabled && udevadm control --reload || true
",
       'onlyif'    => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
DISABLE_UDEV=\$(ceph --version | awk 'match(\$3, /[0-9]\\.[0-9]+/) {if (substr(\$3, RSTART, RLENGTH) <= 0.94) {print 1}}')
test -f /usr/lib/udev/rules.d/95-ceph-osd.rules && test \$DISABLE_UDEV -eq 1
",
       'logoutput' => true,
      ) }
      it { is_expected.to contain_exec('ceph-osd-prepare-/srv/data').with(
        'command'   => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
if ! test -b /srv/data ; then
  mkdir -p /srv/data
fi
ceph-disk prepare --cluster testcluster /srv/data /srv/journal
udevadm settle
",
        'unless'    => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
ceph-disk list | grep -E ' */srv/data1? .*ceph data, (prepared|active)' ||
ls -l /var/lib/ceph/osd/testcluster-* | grep ' /srv/data\$'
",
        'logoutput' => true
      ) }
      it { is_expected.to contain_exec('ceph-osd-activate-/srv/data').with(
        'command'   => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
if ! test -b /srv/data ; then
  mkdir -p /srv/data
fi
# activate happens via udev when using the entire device
if ! test -b /srv/data || ! test -b /srv/data1 ; then
  ceph-disk activate /srv/data || true
fi
if test -f /usr/lib/udev/rules.d/95-ceph-osd.rules.disabled && test -b /srv/data1 ; then
  ceph-disk activate /srv/data1 || true
fi
",
        'unless'    => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
ls -ld /var/lib/ceph/osd/testcluster-* | grep ' /srv/data\$'
",
        'logoutput' => true
      ) }
    end

    describe "with ensure absent" do

      let :title do
        '/srv'
      end

      let :params do
        {
          :ensure => 'absent',
        }
      end

      it { is_expected.to contain_exec('remove-osd-/srv').with(
        'command'   => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
if [ -z \"\$id\" ] ; then
  id=\$(ceph-disk list | sed -nEe 's:^ */srv1? .*(ceph data|mounted on).*osd\\.([0-9]+).*:\\2:p')
fi
if [ -z \"\$id\" ] ; then
  id=\$(ls -ld /var/lib/ceph/osd/ceph-* | sed -nEe 's:.*/ceph-([0-9]+) *-> */srv\$:\\1:p' || true)
fi
if [ \"\$id\" ] ; then
  stop ceph-osd cluster=ceph id=\$id || true
  service ceph stop osd.\$id || true
  ceph  osd rm \$id
  ceph auth del osd.\$id
  rm -fr /var/lib/ceph/osd/ceph-\$id/*
  umount /var/lib/ceph/osd/ceph-\$id || true
  rm -fr /var/lib/ceph/osd/ceph-\$id
fi
",
        'unless'    => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
if [ -z \"\$id\" ] ; then
  id=\$(ceph-disk list | sed -nEe 's:^ */srv1? .*(ceph data|mounted on).*osd\\.([0-9]+).*:\\2:p')
fi
if [ -z \"\$id\" ] ; then
  id=\$(ls -ld /var/lib/ceph/osd/ceph-* | sed -nEe 's:.*/ceph-([0-9]+) *-> */srv\$:\\1:p' || true)
fi
if [ \"\$id\" ] ; then
  test ! -d /var/lib/ceph/osd/ceph-\$id
else
  true # if there is no id  we do nothing
fi
",
        'logoutput' => true
      ) }
    end
  end

  context 'Debian Family' do
    let :facts do
      {
        :osfamily => 'Debian',
      }
    end

    it_configures 'ceph osd'
  end

  context 'RedHat Family' do

    let :facts do
      {
        :osfamily => 'RedHat',
      }
    end

    it_configures 'ceph osd'
  end
end

# Local Variables:
# compile-command: "cd ../.. ;
#    bundle install ;
#    bundle exec rake spec
# "
# End:
