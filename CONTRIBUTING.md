# Contributing

Contributions will be gratefully accepted. Please go to the project page, fork
the project, make your changes locally and then raise a pull request. Details
on how to do this are available at
https://guides.github.com/activities/contributing-to-open-source.

## Testing

### Spec Tests

At the very least, before submitting your pull request or patch, the following
tests should pass with no errors or warnings:

```bash
bundle update             # Update/install your bundle
bundle exec rake lint     # Run puppet-lint
bundle exec rake validate # Check syntax of Ruby files and call :syntax and :metadata
bundle exec rake spec     # Run spec tests in a clean fixtures directory
```

### Beaker Tests

```bash
for node in $( bundle exec rake beaker_nodes ); do
  export BEAKER_set=$node
  BEAKER_destroy=onpass bundle exec rake beaker || break
done
```

## Preparing for a Release

The notes for preparing for a release have been moved to
https://github.com/locp/cassandra/wiki/Preparing-for-a-Release
