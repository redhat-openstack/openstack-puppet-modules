##  Getting Started

First, install [bade](https://github.com/paramite/bade), a utility
for managing Puppet modules using GIT subtrees:

```
    git clone https://github.com/paramite/bade.git
    cd bade
    python setup.py develop
```

Then create a [fork](https://help.github.com/articles/fork-a-repo/) of the OpenStack Puppet Modules repository
and create a local [clone](https://help.github.com/articles/fork-a-repo/#step-2-create-a-local-clone-of-your-fork) of it.

```
    git clone git@github.com:YOUR_USERNAME/openstack-puppet-modules.git
    cd openstack-puppet-modules
```

Next, create a new [branch](http://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging)
in your local clone.

```
    git checkout -b NAME_OF_TOPIC_BRANCH
```

## Using Bade

### Adding a new Puppet module

We will use `puppet-neutron` for this example:
```
    bade add --upstream https://github.com/openstack/puppet-neutron.git \
    --hash ${COMMIT_HASH} --commit
```

Add some more details (e.g. why you want to add this Puppet module)
to the commit message:
```
    git commit --amend
```

### Updating a module

When updating, you use the name of the module as referenced in the
[Puppetfile](Puppetfile}, in this case 'neutron':

```
    bade update --module ${module} --hash ${COMMIT_HASH}
```


## Submitting your change.

As mentioned in the [README.md](README.md), we use
[gerrithub](https://review.gerrithub.io/#/q/project:redhat-openstack/openstack-puppet-modules)
for our reviews.  You should first make sure your topic branch is rebased and
current against the target version for your change.  For example, if you wish to
update neutron above to the latest revision for master, you would rebase your
topic branch to upstream-master.  Then, simply submit your review against that
branch like so:
```
    git review upstream-master
```
