OpenStack Puppet Modules
========================

[Puppet](http://puppetlabs.com/puppet/puppet-open-source) modules shared between
[Packstack](https://github.com/stackforge/packstack) and [Foreman](http://theforeman.org/).

How to add a new Puppet module
------------------------------

First you have to install [bade](https://github.com/paramite/bade), a utility
for managing Puppet modules using GIT subtrees.

    git clone https://github.com/paramite/bade
    cd bade
    python setup.py develop

Then create a [fork of the OpenStack Puppet Modules repository](https://help.github.com/articles/fork-a-repo/)
and [create a local clone of it](https://help.github.com/articles/fork-a-repo/#step-2-create-a-local-clone-of-your-fork).

    git clone git@github.com:YOUR_USERNAME/openstack-puppet-modules.git
    cd openstack-puppet-modules

Now create a new [branch](http://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging) in your local clone.

    git checkout -b NAME_OF_THE_MODULE

Afterwards add the new Puppet module, `puppet-module-collectd` in this example.

    bade add --upstream https://github.com/pdxcat/puppet-module-collectd.git --hash cf79540be4623eb9da287f6d579ec4a4f4ddc39b --commit

Finally add some more details (e.g. why you want to add this Puppet module)
to the commit message, push the branch and [initiate a pull request](https://help.github.com/articles/using-pull-requests/#initiating-the-pull-request).

    git commit --amend
    git push --set-upstream origin collectd
