# Basics

This is really more of a 'prep for building' document, as the actual build is
automated with [delorean](https://github.com/openstack-packages/delorean) once 
the required steps have been taken.

## Step 1 - Tag

In order to generate a new release, the first step is to tag the upstream branch
(this is not needed for master), so for example:
```
    git checkout upstream-liberty
    git tag {release-number}
    git push origin {release-number}
```

## Step 2 - Rebase

Next, we need to rebase the patches branch that matches the target release,
so in the above example, stable/liberty:
```
    git checkout stable/liberty
    git fetch origin # assuming origin is the upstream repo location
    git rebase -i origin/upstream-liberty
```
This will give you a list of patches in stable to be applied on top of upstream,
and is where any can be dropped, if appropriate (the less, the better!).  

### Step 2a - Add new patches

In the case where there is some new patch which needs to be added (not upstream
yet, but deemed worth backporting instead of waiting), the patch needs to be
generated and edited to apply to the opm repo instead of its target project.
This can be done like so (outside of the current directory):
```
    git clone {upstream repo}
    git review -d {review number}
    git format-patch -1
```
Now we have the messy part (this will go away in the near future for upcoming
releases).  The paths in the patch all need to be munged to apply in the opm
repo - simply prepend the toplevel directory for the module here anywhere you
see 'a/' or 'b/', as well as the list of changed files.  Now `git am` the
patch.  Assuming it applies successfully, verify paths look correct and the
files you expect to be changed are actually changed.  Use extra caution that
the changes get into the right subdirectory, rather than at the root level of
the project.  

## Step 3 - Push changes

Once all looks correct, and the rebase is complete, we push the updated branch
via gerrit, often needing to force push, due to the patches in stable having
pointers changed in the rebase.
```
    git push gerrit stable/liberty # if needed, with --force
```

At this point, delorean will pick up the change and build an rpm to the matching
location for the Openstack version, as described in the [README](README.md).
