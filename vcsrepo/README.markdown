#vcsrepo

[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-vcsrepo.png?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-vcsrepo)

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with vcsrepo](#setup)
    * [Beginning with vcsrepo](#beginning-with-vcsrepo)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Bazaar](#bazaar)
    * [CVS](#cvs)
    * [Git](#git)
    * [Mercurial](#mercurial)
    * [Perforce](#perforce)
    * [Subversion](#subversion)  
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Type: vcsrepo](#type-vcsrepo)
        * [Providers](#providers)
        * [Features](#features)
        * [Parameters](#parameters)
        * [Features and Parameters by Provider](#features-and-parameters-by-provider)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

The vcsrepo module allows you to use Puppet to easily deploy content from your version control system (VCS).

##Module Description

This module provides a single type with providers for each VCS, which can be used to describe: 

* A working copy checked out from a (remote or local) source, at an
  arbitrary revision
* A blank working copy not associated with a source (when it makes
  sense for the VCS being used)
* A blank central repository (when the distinction makes sense for the VCS
  being used)   

##Setup

Before you begin using vcsrepo, it's worth keeping in mind that this module will not install VCS software for you. If you are going to use this module, you must have already installed your preferred VCS.

Also, this module, like Puppet generally, will not create parent directories for you. You will need to have your parent directories in place before you begin.

###Beginning with vcsrepo	

To get started with the vcsrepo module, you must simply define the type `vcsrepo` with a path to your repository and the [type of VCS](#Usage) you're using in `provider` (in the below example, Git). 

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => git,
    }

##Usage

The vcsrepo module works with the following VCSs:

* [Git (git)](#git)*
* [Bazaar (bzr)](#bazaar)
* [CVS (cvs)](#cvs)
* [Mercurial (hg)](#mercurial)
* [Perforce (p4)](#perforce)
* [Subversion (svn)](#subversion)

**Note:** Git is the only VCS provider officially [supported](https://forge.puppetlabs.com/supported) by Puppet Labs.


###Git

#####To create a blank repository

To create a blank repository suitable for use as a central repository,
define `vcsrepo` without `source` or `revision`.

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => git,
    }

If you're defining `vcsrepo` for a central or official repository, you may want to make it a bare repository.  You do this by setting `ensure` to 'bare' rather than 'present'.

    vcsrepo { "/path/to/repo":
      ensure   => bare,
      provider => git,
    }

#####To clone/pull a repository

To get the current HEAD on the master branch,

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => git,
      source   => "git://example.com/repo.git",
    }

To get a specific revision or branch (can be a commit SHA, tag, or branch name),

 **SHA**

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => git,
      source   => 'git://example.com/repo.git',
      revision => '0c466b8a5a45f6cd7de82c08df2fb4ce1e920a31',
    }

**Tag**

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => git,
      source   => 'git://example.com/repo.git',
      revision => '1.1.2rc1',
    }

**Branch name**

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => git,
      source   => 'git://example.com/repo.git',
      revision => 'development',
    }

To check out a branch as a specific user,

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => git,
      source   => 'git://example.com/repo.git',
      revision => '0c466b8a5a45f6cd7de82c08df2fb4ce1e920a31',
      user     => 'someUser',
    }

To keep the repository at the latest revision (**WARNING:** this will always overwrite local changes to the repository),

    vcsrepo { "/path/to/repo":
      ensure   => latest,
      provider => git,
      source   => 'git://example.com/repo.git',
      revision => 'master',
    }

To clone the repository but skip initialiazing submodules,

    vcsrepo { "/path/to/repo":
      ensure     => latest,
      provider   => git,
      source     => 'git://example.com/repo.git',
      submodules => false,
    }

##### Using multiple remotes with a repository
Instead of specifying a single string in the 'source' property, you can specify a hash with multiple name => URL mappings,

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => git,
      source   => {
        "origin"       => "https://github.com/puppetlabs/puppetlabs-vcsrepo.git", 
        "other_remote" => "https://github.com/other_user/puppetlabs-vcsrepo.git"
      },
    }

It is important to note that you must specify a mapping for the remote that is specified in the 'remote' property - this is set to 'origin' by default.

#####Sources that use SSH

When your source uses SSH, such as 'username@server:…', you can manage your SSH keys with Puppet using the [require](http://docs.puppetlabs.com/references/stable/metaparameter.html#require) metaparameter in `vcsrepo` to ensure they are present.

For SSH keys associated with a user, enter the username in the `user` parameter. Doing so will use that user's keys.

    user => 'toto'  # will use toto's $HOME/.ssh setup

#####Further Examples

For more examples using Git, see `examples/git/`.

###Bazaar

#####Create a blank repository

To create a blank repository suitable for use as a central repository,
define `vcsrepo` without `source` or `revision`.

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => bzr,
    }

#####Branch from an existing repository

Provide the `source` location to branch from an existing repository.

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => bzr,
      source   => 'lp:myproj',
    }

For a specific revision, use `revision` with a valid revisionspec
(see `bzr help revisionspec` for more information on formatting a revision).

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => bzr,
      source   => 'lp:myproj',
      revision => 'menesis@pov.lt-20100309191856-4wmfqzc803fj300x',
    }

#####Sources that use SSH

When your source uses SSH, for instance 'bzr+ssh://...' or 'sftp://...,'
you can manage your SSH keys with Puppet using the [require](http://docs.puppetlabs.com/references/stable/metaparameter.html#require) metaparameter in `vcsrepo` to ensure they are present.
  
#####Further examples

For more examples using Bazaar, see `examples/bzr/`.

###CVS

#####To create a blank repository

To create a blank repository suitable for use as a central repository,
define `vcsrepo` without `source` or `revision`.

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => cvs,
    }

#####To checkout/update from a repository

To get the current mainline,

    vcsrepo { "/path/to/workspace":
      ensure   => present,
      provider => cvs,
      source   => ":pserver:anonymous@example.com:/sources/myproj",
    }
    
To get a specific module on the current mainline,

    vcsrepo {"/vagrant/lockss-daemon-source":
      ensure   => present,
      provider => cvs,
      source   => ":pserver:anonymous@lockss.cvs.sourceforge.net:/cvsroot/lockss",
      module   => "lockss-daemon",
    }


You can use the `compression` parameter to set the GZIP compression levels for your repository history.

    vcsrepo { "/path/to/workspace":
      ensure      => present,
      provider    => cvs,
      compression => 3,
      source      => ":pserver:anonymous@example.com:/sources/myproj",
    }

For a specific tag, use `revision`.

    vcsrepo { "/path/to/workspace":
      ensure      => present,
      provider    => cvs,
      compression => 3,
      source      => ":pserver:anonymous@example.com:/sources/myproj",
      revision    => "SOMETAG",
    }

#####Sources that use SSH

When your source uses SSH, you can manage your SSH keys with Puppet using the [require](http://docs.puppetlabs.com/references/stable/metaparameter.html#require) metaparameter in `vcsrepo` to ensure they are present.

#####Further examples

For for more examples using CVS, see `examples/cvs/`.

###Mercurial

#####To create a blank repository

To create a blank repository suitable for use as a central repository,
define `vcsrepo` without `source` or `revision`.

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => hg,
    }

#####To clone/pull & update a repository

To get the default branch tip,

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => hg,
      source   => "http://hg.example.com/myrepo",
    }

For a specific changeset, use `revision`.

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => hg,
      source   => "http://hg.example.com/myrepo",
      revision => '21ea4598c962',
    }

You can also set `revision` to a tag.

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => hg,
      source   => "http://hg.example.com/myrepo",
      revision => '1.1.2',
    }

To check out as a specific user,

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => hg,
      source   => "http://hg.example.com/myrepo",
      user     => 'user',
    }

To specify an SSH identity key,

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => hg,
      source   => "ssh://hg@hg.example.com/myrepo",
      identity => "/home/user/.ssh/id_dsa,
    }

To specify a username and password for HTTP Basic authentication,

    vcsrepo { "/path/to/repo":
      ensure   => latest,
      provider => hg,
      source   => 'http://hg.example.com/myrepo',
      basic_auth_username => 'hgusername',
      basic_auth_password => 'hgpassword',
    }

#####Sources that use SSH 

When your source uses SSH, such as 'ssh://...', you can manage your SSH keys with Puppet using the [require](http://docs.puppetlabs.com/references/stable/metaparameter.html#require) metaparameter in `vcsrepo` to ensure they are present.

#####Further Examples

For more examples using Mercurial, see `examples/hg/`.

###Perforce

#####To create an empty Workspace

To create an empty Workspace, define a `vcsrepo` without a `source` or `revision`.  The 
Environment variables P4PORT, P4USER, etc... are used to define the Perforce server
connection settings.

    vcsrepo { "/path/to/repo":
      ensure     => present,
      provider   => p4
    }

If no `P4CLIENT` environment name is provided a workspace generated name is calculated
based on the Digest of path and hostname.  For example:

    puppet-91bc00640c4e5a17787286acbe2c021c

A Perforce configuration file can be used by setting the `P4CONFIG` environment or
defining `p4config`.  If a configuration is defined, then the environment variable for 
`P4CLIENT` is replaced.
 
    vcsrepo { "/path/to/repo":
      ensure     => present,
      provider   => p4,
      p4config   => '.p4config'
    }

#####To create/update and sync a Perforce workspace

To sync a depot path to head, ensure `latest`:

    vcsrepo { "/path/to/repo":
        ensure   => latest,
        provider => p4,
        source   => '//depot/branch/...'
    }

For a specific changelist, ensure `present` and specify a `revision`:

    vcsrepo { "/path/to/repo":
        ensure   => present,
        provider => p4,
        source   => '//depot/branch/...',
        revision => '2341'
    }

You can also set `revision` to a label:

    vcsrepo { "/path/to/repo":
        ensure   => present,
        provider => p4,
        source   => '//depot/branch/...',
        revision => 'my_label'
    }

#####To authenticate against the Perforce server

Either set the environment variables `P4USER` and `P4PASSWD` or use a configuration file.
For secure servers set the `P4PASSWD` with a valid ticket generated using `p4 login -p`.

#####Further Examples

For examples you can run, see `examples/p4/`

###Subversion

#####To create a blank repository

To create a blank repository suitable for use as a central repository,
define `vcsrepo` without `source` or `revision`.

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => svn,
    }

#####To check out from a repository

Provide a `source` pointing to the branch/tag you want to check out from a repository.

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => svn,
      source   => "svn://svnrepo/hello/branches/foo",
    }

You can also provide a specific revision.

    vcsrepo { "/path/to/repo":
      ensure   => present,
      provider => svn,
      source   => "svn://svnrepo/hello/branches/foo",
      revision => '1234',
    }

#####Using a specific Subversion configuration directory 

To use a specific configuration directory, provide a `configuration` parameter which should be a directory path on the local system where your svn configuration files are.  Typically, it is '/path/to/.subversion'.

    vcsrepo { "/path/to/repo":
        ensure        => present,
        provider      => svn,
        source        => "svn://svnrepo/hello/branches/foo",
        configuration => "/path/to/.subversion",
    }

#####Sources that use SSH 

When your source uses SSH, such as 'svn+ssh://...', you can manage your SSH keys with Puppet using the [require](http://docs.puppetlabs.com/references/stable/metaparameter.html#require) metaparameter in `vcsrepo` to ensure they are present.

####Further examples

For more examples using Subversion, see `examples/svn/`.

##Reference

###Type: vcsrepo

The vcsrepo module is slightly unusual in that it is simply a type and providers. Each provider abstracts a different VCS, and a series of features are available to each provider based on its specific needs. 

####Providers

**Note**: Not all features are available with all providers.

* `git`   - Supports the Git VCS. (Contains features: `bare_repositories`, `depth`, `multiple_remotes`, `reference_tracking`, `ssh_identity`, `user`.)
* `bar`   - Supports the Bazaar VCS. (Contains features: `reference_tracking`.)
* `cvs`   - Supports the CVS VCS. (Contains features: `cvs_rsh`, `gzip_compression`, `modules`, `reference_tracking`, `user`.)
* `dummy` - 
* `hg`    - Supports the Mercurial VCS. (Contains features: `reference_tracking`, `ssh_identity`, `user`.)
* `p4`    - Supports the Perforce VCS. (Contains features: `reference_tracking`, `filesystem_types`, `p4config`.)
* `svn`   - Supports the Subversion VCS. (Contains features: `basic_auth`, `configuration`, `filesystem_types`, `reference_tracking`.)

####Features

**Note**: Not all features are available with all providers.

* `bare_repositories` - The provider differentiates between bare repositories and those with working copies. (Available with `git`.)
* `basic_auth` -  The provider supports HTTP Basic Authentication. (Available with `svn`.)
* `configuration` - The provider supports setting the configuration path.(Available with `svn`.)
* `cvs_rsh` - The provider understands the CVS_RSH environment variable. (Available with `cvs`.)
* `depth` - The provider can do shallow clones. (Available with `git`.)
* `filesystem_types` - The provider supports different filesystem types. (Available with `svn`.)
* `gzip_compression` - The provider supports explicit GZip compression levels. (Available with `cvs`.)
* `modules` - The provider allows specific repository modules to be chosen. (Available with `cvs`.)
* `multiple_remotes` - The repository tracks multiple remote repositories. (Available with `git`.)
* `reference_tracking` - The provider supports tracking revision references that can change over time (e.g. some VCS tags and branch names). (Available with `bar`, `cvs`, `git`, `hg`, `svn`.)
* `ssh_identity` - The provider supports a configurable SSH identity file. (Available with `git` and `hg`.)
* `user` - The provider can run as a different user. (Available with `git`, `hg` and `cvs`.)
* `p4config` - The provider support setting the P4CONFIG environment. (Available with `p4`.)
* `submodules` - The provider supports repository submodules which can be optionally initialized. (Available with `git`.)

####Parameters

* `basic_auth_password` - Specifies the HTTP Basic Authentication password. (Requires the `basic_auth` feature.)
* `basic_auth_username` - Specifies the HTTP Basic Authentication username. (Requires the `basic_auth` feature.)
* `compression` - Set the GZIP compression levels for your repository history. (Requires the `gzip_compression` feature.)
* `configuration` - Sets the configuration directory to use. (Requires the `configuration` feature.)
* `cvs_rsh` -  The value to be used for the CVS_RSH environment variable. (Requires the `cvs_rsh` feature.)
* `depth` - The value to be used to do a shallow clone. (Requires the `depth` feature.)
* `ensure` - Determines the state of the repository. Valid values are 'present', 'bare', 'absent', 'latest'.
* `excludes` - Lists any files to be excluded from being tracked by the repository (similiar to .gitignore). Can be an array or string.
* `force` - Forces repository creation. Valid values are 'true' and 'false'. **WARNING** Forcing will destroy any files in the path.
* `fstype` - Sets the filesystem type. (Requires the `filesystem_types` feature.)
* `group` - Determines the group/gid that owns the repository files.
* `identity` - Specifies the SSH identity file. (Requires the `ssh_identity` feature.)
* `module` - Specifies the repository module to manage. (Requires the `modules` feature.)
* `owner` - Specifies the user/uid that owns the repository files.
* `path` - Specifies the absolute path to the repository. If omitted, the value defaults to the resource's title.
* `provider` - Specifies the backend to use for this vcsrepo resource. 
* `remote` - Specifies the remote repository to track. (Requires the `multiple_remotes` feature.)
* `revision` - Sets the revision of the repository. Values can match /^\S+$/.
* `source` - Specifies the source URI for the repository.
* `user` - Specifies the user to run as for repository operations.
* `p4config` - Specifies the P4CONFIG environment used for Perforce connection configuration.

####Features and Parameters by Provider

#####`git`
**Features**: `bare_repositories`, `depth`, `multiple_remotes`, `reference_tracking`, `ssh_identity`, `user`, `submodules`

**Parameters**: `depth`, `ensure`, `excludes`, `force`, `group`, `identity`, `owner`, `path`, `provider`, `remote`, `revision`, `source`, `user`, `submodules`

#####`bzr`
**Features**: `reference_tracking`

**Parameters**: `ensure`, `excludes`, `force`, `group`, `owner`, `path`, `provider`, `revision`, `source`, `user`

#####`cvs`
**Features**: `cvs_rsh`, `gzip_compression`, `modules`, `reference_tracking`, `revision`

**Parameters**: `compression`, `cvs_rsh`, `ensure`, `excludes`, `force`, `group`, `module`, `owner`, `path`, `provider`, `revision`, `source`, `user`

#####`hg`
**Features**: `reference_tracking`, `ssh_identity`, `user`

**Parameters**: `ensure`, `excludes`, `force`, `group`, `identity`, `owner`, `path`, `provider`, `revision`, `source`, `user`

#####`p4`
**Features**: `reference_tracking`, `filesystem_types`, `p4config`

**Parameters**: `ensure`, `group`, `owner`, `path`, `provider`, `revision`, `source`, `p4config`

#####`svn`
**Features**: `basic_auth`, `configuration`, `filesystem_types`, `reference_tracking`

**Parameters**: `basic_auth_password`, `basic_auth_username`, `configuration`, `ensure`, `excludes`, `force`, `fstype`, `group`, `owner`, `path`, `provider`, `revision`, `source`, `user`
        
##Limitations

Git is the only VCS provider officially [supported](https://forge.puppetlabs.com/supported) by Puppet Labs.

This module has been built on and tested against Puppet 2.7 and higher.

The module has been tested on:

RedHat Enterprise Linux 5/6
Debian 6/7
CentOS 5/6
Ubuntu 12.04
Gentoo
Arch Linux
FreeBSD

Testing on other platforms has been light and cannot be guaranteed.

##Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide on the Puppet Labs wiki.
