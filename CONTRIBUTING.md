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
rake lint     # Run puppet-lint
rake validate # Check syntax of Ruby files and call :syntax and :metadata
rake spec     # Run spec tests in a clean fixtures directory
```

### Beaker Tests

```bash
for node in $( rake beaker_nodes ); do
  export BEAKER_set=$node
  BEAKER_destroy=onpass rake beaker || break
done
```

## Preparing for a Release

* Ensure all tests pass as expected.  There should already be a branch named
  after the release (e.g. v1.2.3) so merge all relevant branches onto it
  beforehand.  To find out which branches require to be merged in, run the
  following ```git branch -a --no-merged```.

* Update the CHANGELOG.

* Edit the metadata with the new release number with one of the following:

  ```bash
  rake module:bump:major # Bump module version to the next MAJOR version
  rake module:bump:minor # Bump module version to the next MINOR version
  rake module:bump:patch # Bump module version to the next PATCH version
  ```

* Create a tag with the version number using ```rake module:tag```.

* Run `spec build` and upload the package to the forge.
