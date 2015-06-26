# Contributing

Contributions will be greatfully accepted. Please go to the project page, fork
the project, make your changes locally and then raise a pull request. Details
on how to do this are available at
https://guides.github.com/activities/contributing-to-open-source.

## Testing

At the very least, before submitting your pull request or patch, the following
tests should pass with no errors or warnings:

```rake lint              # Run puppet-lint
rake spec              # Run spec tests in a clean fixtures directory
rake syntax            # Syntax check Puppet manifests and templates
```

## Beaker Tests

```export BEAKER_destroy=onpass

for node in $( rake beaker_nodes ); do
  export BEAKER_set=$node
  rake beaker || break
done
```
