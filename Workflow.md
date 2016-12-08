# Workflow

## Development Workflow

### Types of builds

-   Development builds take place all the time during the normal development workflow of coding, building and running. Code changes are committed to the development branch, and the build number is not incremented in this process (however, the version number will look different after each commit, see below).

-   Test builds are intended for a larger audience, i.e. testers and other stakeholders, who’ll run the build on their registered devices. These builds are compiled from the test branch and tagged with the version number after the build number has been manually incremented.

-   App Store builds immediately follow a successfully tested Test build. App Store builds only differ from Test builds in that they’re committed on the master branch and submitted to the App Store.

### Test builds

1.  Check out test and merge development into it (--no-ff).

2.  Update the change log, targeted testers, describing new functionality, changes and bug fixes in the release. Turn off debug logging.

3.  Enter a new marketing version number in target->General->Identity->Version.

4.  Bump the build number: version.sh bump. This is basically the the same as running agvtool bump -all, but the script just generates a less noisy output.

5.  Commit the changes locally: git commit -a. Don’t push to a remote repository just yet as you may run into compilation quirks and need to fix those first.

6.  Tag the commit with the same version number you entered in target->General->Identity->Version, e.g.: git tag -a v1.2 -m "tag v1.2" 

7.  Archive (also builds) the target, using a distribution configuration, either from within Xcode or the command line with xcodebuild.

8.  Upload to AppStore, distribute using TestFlight. If upload fails: 1. Enter new marketing version; 2. Commit locally and tag with new version number; 3. Upload.

9.  Merge the test branch back into development (--no-ff).

### App Store builds

*   In addition to the Test Build procedure above, commit test branch on to master while ensuring the correct (re)tag.


