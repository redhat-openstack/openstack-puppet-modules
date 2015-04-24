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

We use [GitHub Issues](https://github.com/dfarrell07/puppet-opendaylight/issues) for most communication, including bug reports, feature requests and questions.

We accept patches via [GitHub Pull Requests](https://github.com/dfarrell07/puppet-opendaylight/pulls). Please fork our repo, make your changes, commit them to a feature branch and *submit a PR to have it merged back into this project*. We'll give feedback and get it merged ASAP.

## Communication

*Please use public, documented communication instead of reaching out to developers 1-1.*

Open Source projects benefit from always communicating in the open. Previously answered questions end up becoming documentation for other people hitting similar issues. More eyes may get your question answered faster. Doing everything in the open keeps community members on an equal playing field (`@<respected company>` email addresses don't get priority, good questions do).

We prefer [Issues](https://github.com/dfarrell07/puppet-opendaylight/issues) for most communication.

### Issues

Please use our [GitHub Issues](https://github.com/dfarrell07/puppet-opendaylight/issues) freely, even for small things! They are the primary method by which we track what's going on in the project.

The labels assigned to an issue can tell you important things about it.

For example, issues tagged [`good-for-beginners`](https://github.com/dfarrell07/puppet-opendaylight/labels/good-for-beginners) are likely to not require much background knowledge and be fairly self-contained, perfect for people new to the project who are looking to get involved.

The priority-related issue labels ([`prio:high`](https://github.com/dfarrell07/puppet-opendaylight/labels/prio%3Ahigh), [`piro:normal`](https://github.com/dfarrell07/puppet-opendaylight/labels/prio%3Anormal)...) are also important to note. They typically accurately reflect the next TODOs the community will complete.

The `info:progress` labels may not always be up-to-date, but will be used when appropriate (typically long-standing issues that take multiple commits).

Issues can be referenced and manipulated from git commit messages. Just referencing the issue's number (`#42`) will link the commit and issue. Issues can also be closed from commit messages with `closes #42` (and [a variety of other key words](https://help.github.com/articles/closing-issues-via-commit-messages/)).

### Gitter

We're experimenting with Gitter, a GitHub-driven chat service that works on a per-repo basis.

Feel free to hop in [our room](https://gitter.im/dfarrell07/puppet-opendaylight) and test it out with us.

## Patches

Please use [Pull Requests](https://github.com/dfarrell07/puppet-opendaylight/pulls) to submit patches.

Basics of a pull request:
* Use the GitHub web UI to fork our repo.
* Clone your fork to your local system.
* Make your changes.
* Commit your changes, using a good commit message and referencing any applicable issues.
* Push your commit.
* Submit a pull request against the project, again using GitHub's web UI.
* We'll give feedback and get your changed merged ASAP.
* You contributed! Thank you!

Other tips for submitting excellent pull requests:
* If you'd like to make more than one logically distinct change, please submit them as different pull requests (if they don't depend on each other) or different commits in the same PR (if they do).
* If your PR contains a number of commits that provide one logical change, please squash them using `git rebase`.
* Please provide test coverage for your changes.
* If applicable, please provide documentation updates to reflect your changes.

## Testing

### Test Dependencies

The testing tools have a number of dependencies. We use [Bundler](http://bundler.io/) to make installing them easy.

```ShellSession
[~/puppet-opendaylight]$ bundle install
```

### Syntax and Style Tests

We use [Puppet Lint](http://puppet-lint.com/) and [Puppet Syntax](https://github.com/gds-operations/puppet-syntax) to validate the module's syntax and style.

```ShellSession
[~/puppet-opendaylight]$ bundle exec rake lint
[~/puppet-opendaylight]$ bundle exec rake syntax
```

### Unit Tests

We use rspec-puppet to provide unit test coverage.

To run the unit tests and generate a coverage report, use:

```ShellSession
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

```ShellSession
[~/puppet-opendaylight]$ bundle exec rake test
```

### System Tests

While the [unit tests](#unit-tests) are able to quickly find many errors, they don't do much more than checking that the code compiles to a given state. To verify that the Puppet module behaves as desired once applied to a real, running system, we use [Beaker](https://github.com/puppetlabs/beaker).

Beaker stands up virtual machines using Vagrant, applies the OpenDaylight Puppet module with various combinations of params and uses [Serverspec](http://serverspec.org/resource_types.html) to validate the resulting system state.

To run our Beaker test against the primary target OS (CentOS 7) using the recommended RPM-based install method:

```ShellSession
[~/puppet-opendaylight]$ bundle exec rake beaker
```

The `RS_SET` environment variable can be use to change Beaker's target OS (Fedora 20, Fedora 21, CentOS 7, Ubuntu 14.04). ODL's install method (RPM or tarball) can be configured via the `INSTALL_METHOD` environment variable.

```ShellSession
[~/puppet-opendaylight]$ RS_SET=fedora-20 INSTALL_METHOD=tarball bundle exec rake beaker
```

There are a number of pre-defined rake tasks to simplify running common Beaker tests.

```ShellSession
[~/puppet-opendaylight]$ bundle exec rake centos
[~/puppet-opendaylight]$ bundle exec rake centos_tarball
[~/puppet-opendaylight]$ bundle exec rake fedora_20
[~/puppet-opendaylight]$ bundle exec rake fedora_21
[~/puppet-opendaylight]$ bundle exec rake ubuntu
```

If you'd like to preserve the Beaker VM after a test run, perhaps for manual inspection or a quicker follow-up test run, use the `BEAKER_DESTROY` environment variable.

```ShellSession
[~/puppet-opendaylight]$ BEAKER_DESTROY=no bundle exec rake centos
```

For more information about using Beaker, see [these docs](https://github.com/puppetlabs/beaker/wiki/How-to-Write-a-Beaker-Test-for-a-Module#typical-workflow).

### Tests in Continuous Integration

We use [Travis CI](https://travis-ci.org/dfarrell07/puppet-opendaylight) to run our unit, syntax and style tests against a matrix of supported Ruby and Puppet versions at every commit. This currently results in >8500 automated tests per commit.
