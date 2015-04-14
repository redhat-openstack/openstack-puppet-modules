# Contributing to the OpenDaylight Puppet Module

We work to make contributing easy. Please let us know if you spot something we can do better.

#### Table of Contents
1. [Overview](#overview)
1. [Communication](#communication)
    * [Issues](#issues)
    * [Gitter](#gitter)
1. [Patches](#patches)

## Overview

We use [GitHub Issues](https://github.com/dfarrell07/puppet-opendaylight/issues) for most communication, including bug reports, feature requests and questions.

We accept patches via [GitHub Pull Requests](https://github.com/dfarrell07/puppet-opendaylight/pulls). Please fork our repo, make your changes, commit them to a feature branch and *submit a PR to have it merged back into this project*. We'll give feedback and get it merged ASAP.

## Communication

Please use public, documented communication instead of reaching out to developers 1-1.

Open Source projects benefit from always communicating in the open. Other people may run into the same issue, search for a similar trace and find your question, already answered. More eyes may even get your question answered faster.

We prefer [Issues](https://github.com/dfarrell07/vagrant-opendaylight/issues) for most communication.

### Issues

Please use our [GitHub Issues freely](https://github.com/dfarrell07/vagrant-opendaylight/issues), even for small things! They are the primary method by which we track what's going on in the project.

The lables assigned to an issue can tell you important things about it.

For example, issues tagged `good-for-beginners` are likely to not require much background knowledge and be fairly self-contained, perfect for people new to the project who are looking to get involved.

The priority-related issue labels (`prio:high`, `piro:normal`...) are also important to note. They typically accurately reflect the next TODOs the community will complete.

The `info:progress` labels may not always be up-to-date, but will be used when appropriate (typically long-standing issues that take multiple commits).

Issues can be referenced and manipulated from git commit messages. Just referencing the issue's number (`#42`) will link the commit and issue. Issues can also be closed from commit messages with `closes #42` (and [a variety of other key words](https://help.github.com/articles/closing-issues-via-commit-messages/)).

### Gitter

We're experimenting with Gitter, a GitHub-driven chat service that works on a per-repo basis.

Feel free to hop in [our room](https://gitter.im/dfarrell07/vagrant-opendaylight) and test it out with us.

## Patches

Please use [Pull Requests](https://github.com/dfarrell07/vagrant-opendaylight/pulls) to submit patches.

Basics of a pull request:
* Use the GitHub web UI to fork our repo
* Clone your fork to your local system
* Make your changes
* Commit your changes, using a good commit message and referencing any applicable issues
* Push your commit
* Submit a pull request against the project, again using GitHub's web UI
* We'll give feedback and get your changed merged ASAP.
* You contributed! Thank you!

## Testing

### Dependencies

The testing and development tools have a bunch of dependencies,
all managed by [Bundler](http://bundler.io/) according to the
[Puppet support matrix](http://docs.puppetlabs.com/guides/platforms.html#ruby-versions).

By default the tests use a baseline version of Puppet.

If you have Ruby 2.x or want a specific version of Puppet,
you must set an environment variable such as:

    export PUPPET_VERSION="~> 3.2.0"

Install the dependencies like so...

    bundle install

### Syntax and style

The test suite will run [Puppet Lint](http://puppet-lint.com/) and
[Puppet Syntax](https://github.com/gds-operations/puppet-syntax) to
check various syntax and style things. You can run these locally with:

    bundle exec rake lint
    bundle exec rake syntax

### Running the unit tests

The unit test suite covers most of the code. As mentioned above, please
add tests if you're adding new functionality. Running the test suite is done
with:

    bundle exec rake spec

Note also you can run the syntax, style and unit tests in one go with:

    bundle exec rake test

#### Automatically run the tests

During development of your puppet module you might want to run your unit
tests a couple of times. You can use the following command to automate
running the unit tests on every change made in the manifests folder.

    bundle exec guard

### Integration tests

The unit tests just check the code runs, not that it does exactly what
we want on a real machine. For that we're using
[Beaker](https://github.com/puppetlabs/beaker).

Beaker fires up a new virtual machine (using Vagrant) and runs a series of
simple tests against it after applying the module. You can run our Beaker
tests with:

    bundle exec rake acceptance

This will use the host described in `spec/acceptance/nodeset/default.yml`
by default. To run against another host, set the `RS_SET` environment
variable to the name of a host described by a `.yml` file in the
`nodeset` directory. For example, to run against Fedora 20:

    RS_SET=fedora-20-x64 bundle exec rake acceptance

If you don't want to have to recreate the virtual machine every time you
can use `BEAKER_DESTROY=no` and `BEAKER_PROVISION=no`. On the first run you will
at least need `BEAKER_PROVISION` set to yes (the default). The Vagrantfile
for the created virtual machines will be in `.vagrant/beaker_vagrant_files`.
