# Contributing to the OpenDaylight Puppet Module

We work to make contributing easy. Please let us know if you spot something we can do better.

#### Table of Contents
1. [Overview](#overview)
1. [Communication](#communication)
    * [Issues](#issues)
    * [Gitter](#gitter)
1. [Patches](#patches)
1. [Testing](#testing)
    * [Test Dependencies](#test-dependencies)
    * [Syntax and Style Tests](#syntax-and-style-tests)
    * [Unit Tests](#unit-tests)
    * [System Tests](#system-tests)
    * [Tests in Continuous Integration](#tests-in-continuous-integration)

## Overview

We use [GitHub Issues][1] for most communication, including bug reports, feature requests and questions.

We accept patches via [GitHub Pull Requests][2]. Please fork our repo, make your changes, commit them to a feature branch and *submit a PR to have it merged back into this project*. We'll give feedback and get it merged ASAP.

## Communication

*Please use public, documented communication instead of reaching out to developers 1-1.*

Open Source projects benefit from always communicating in the open. Previously answered questions end up becoming documentation for other people hitting similar issues. More eyes may get your question answered faster. Doing everything in the open keeps community members on an equal playing field (`@<respected company>` email addresses don't get priority, good questions do).

We prefer [Issues][1] for most communication.

### Issues

Please use our [GitHub Issues][1] freely, even for small things! They are the primary method by which we track what's going on in the project.

The labels assigned to an issue can tell you important things about it.

For example, issues tagged [`good-for-beginners`][3] are likely to not require much background knowledge and be fairly self-contained, perfect for people new to the project who are looking to get involved.

The priority-related issue labels ([`prio:high`][4], [`piro:normal`][5]...) are also important to note. They typically accurately reflect the next TODOs the community will complete.

The `info:progress` labels may not always be up-to-date, but will be used when appropriate (typically long-standing issues that take multiple commits).

Issues can be referenced and manipulated from git commit messages. Just referencing the issue's number (`#42`) will link the commit and issue. Issues can also be closed from commit messages with `closes #42` (and [a variety of other key words][6]).

### Gitter

We're experimenting with Gitter, a GitHub-driven chat service that works on a per-repo basis.

Feel free to hop in [our room][7] and test it out with us.

## Patches

Please use [Pull Requests][2] to submit patches.

Basics of a pull request:
* Use the GitHub web UI to fork our repo.
* Clone your fork to your local system.
* Make your changes.
* Commit your changes, using a [good commit message][8] and referencing any applicable issues.
* Push your commit.
* Submit a pull request against the project, again using GitHub's web UI.
* We'll give feedback and get your changed merged ASAP.
* You contributed! [Thank you][9]!

Other tips for submitting excellent pull requests:
* If you'd like to make more than one logically distinct change, please submit them as different pull requests (if they don't depend on each other) or different commits in the same PR (if they do).
* If your PR contains a number of commits that provide one logical change, please squash them using `git rebase`.
* Please provide test coverage for your changes.
* If applicable, please provide documentation updates to reflect your changes.

## Testing

### Test Dependencies

The testing tools have a number of dependencies. We use [Bundler][10] to make installing them easy.

```
[~/puppet-opendaylight]$ bundle install
```

### Syntax and Style Tests

We use [Puppet Lint][11], [Puppet Syntax][12] and [metadata-json-lint][13] to validate the module's syntax and style.

```
[~/puppet-opendaylight]$ bundle exec rake lint
[~/puppet-opendaylight]$ bundle exec rake syntax
[~/puppet-opendaylight]$ bundle exec rake metadata
```

### Unit Tests

We use rspec-puppet to provide unit test coverage.

To run the unit tests and generate a coverage report, use:

```
[~/puppet-opendaylight]$ bundle exec rake spec
# Snip test output
Finished in 10.08 seconds (files took 0.50776 seconds to load)
537 examples, 0 failures


Total resources:   19
Touched resources: 19
Resource coverage: 100.00%
```

Note that we have a very large number of tests and 100% test coverage.

To run the syntax, style and unit tests in one rake task (recommended), use:

```
[~/puppet-opendaylight]$ bundle exec rake test
```

### System Tests

While the [unit tests](#unit-tests) are able to quickly find many errors, they don't do much more than checking that the code compiles to a given state. To verify that the Puppet module behaves as desired once applied to a real, running system, we use [Beaker][14].

Beaker stands up virtual machines using Vagrant, applies the OpenDaylight Puppet module with various combinations of params and uses [Serverspec][15] to validate the resulting system state.

To run our Beaker test against the primary target OS (CentOS 7) using the recommended RPM-based install method:

```
[~/puppet-opendaylight]$ bundle exec rake beaker
```

The `RS_SET` environment variable can be use to change Beaker's target OS (Fedora 20, Fedora 21, CentOS 7, Ubuntu 14.04). ODL's install method (RPM or tarball) can be configured via the `INSTALL_METHOD` environment variable.

```
[~/puppet-opendaylight]$ RS_SET=fedora-20 INSTALL_METHOD=tarball bundle exec rake beaker
```

There are a number of pre-defined rake tasks to simplify running common Beaker tests.

```
[~/puppet-opendaylight]$ bundle exec rake centos
[~/puppet-opendaylight]$ bundle exec rake centos_tarball
[~/puppet-opendaylight]$ bundle exec rake fedora_20
[~/puppet-opendaylight]$ bundle exec rake fedora_21
[~/puppet-opendaylight]$ bundle exec rake ubuntu
```

If you'd like to preserve the Beaker VM after a test run, perhaps for manual inspection or a quicker follow-up test run, use the `BEAKER_destroy` environment variable.

```
[~/puppet-opendaylight]$ BEAKER_destroy=no bundle exec rake centos
```

You can then connect to the VM by navigating to the directory that contains its Vagrantfile and using standard Vagrant commands.


```
[~/puppet-opendaylight]$ cd .vagrant/beaker_vagrant_files/centos-7.yml
[~/puppet-opendaylight/.vagrant/beaker_vagrant_files/centos-7.yml]$ vagrant status
Current machine states:

centos-7                  running (virtualbox)
[~/puppet-opendaylight/.vagrant/beaker_vagrant_files/centos-7.yml]$ vagrant ssh
[vagrant@centos-7 ~]$ sudo systemctl status opendaylight
opendaylight.service - OpenDaylight SDN Controller
   Loaded: loaded (/usr/lib/systemd/system/opendaylight.service; enabled)
   Active: active (running) since Fri 2015-04-24 16:34:07 UTC; 1min 1s ago
     Docs: https://wiki.opendaylight.org/view/Main_Page
           http://www.opendaylight.org/
[vagrant@centos-7 ~]$ logout
[~/puppet-opendaylight/.vagrant/beaker_vagrant_files/centos-7.yml]$ vagrant destroy -f
```

For more information about using Beaker, see [these docs][16].

### Tests in Continuous Integration

We use [Travis CI][17] to run our unit, syntax and style tests against a matrix of supported Ruby and Puppet versions at every commit. This currently results in >8500 automated tests per commit.


[1]: https://github.com/dfarrell07/puppet-opendaylight/issues
[2]: https://github.com/dfarrell07/puppet-opendaylight/pulls
[3]: https://github.com/dfarrell07/puppet-opendaylight/labels/good-for-beginners
[4]: https://github.com/dfarrell07/puppet-opendaylight/labels/prio%3Ahigh
[5]: https://github.com/dfarrell07/puppet-opendaylight/labels/prio%3Anormal
[6]: https://help.github.com/articles/closing-issues-via-commit-messages/
[7]: https://gitter.im/dfarrell07/puppet-opendaylight
[8]: http://chris.beams.io/posts/git-commit/
[9]: http://cdn3.volusion.com/74gtv.tjme9/v/vspfiles/photos/Delicious%20Dozen-1.jpg
[10]: http://bundler.io/
[11]: http://puppet-lint.com/
[12]: https://github.com/gds-operations/puppet-syntax
[13]: https://github.com/puppet-community/metadata-json-lint
[14]: https://github.com/puppetlabs/beaker
[15]: http://serverspec.org/resource_types.html
[16]: https://github.com/puppetlabs/beaker/wiki/How-to-Write-a-Beaker-Test-for-a-Module#typical-workflow
[17]: https://travis-ci.org/dfarrell07/puppet-opendaylight
