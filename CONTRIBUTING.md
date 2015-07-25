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
rake lint              # Run puppet-lint
rake syntax            # Syntax check Puppet manifests and templates
rake spec              # Run spec tests in a clean fixtures directory
```

### Beaker Tests

```bash
export BEAKER_destroy=onpass

for node in $( rake beaker_nodes ); do
  export BEAKER_set=$node
  rake beaker || break
done
```

## Preparing for a Release

* Ensure all tests pass as expected.  There should already be a branch named
  after the release (e.g. v1.2.3) so merge all relevant branches onto it
  beforehand.  To find out which branches require to be merged in, run the
  following ```git branch -a --no-merged```.

* Update the CHANGELOG.

* Edit the metadata with the new release number.

* Create a tag with the version number (e.g. 1.2.3).

* Run `spec build` and upload the package to the forge.
