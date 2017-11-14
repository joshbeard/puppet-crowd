## 2017-11-14 - Testing
- Bump default Crowd version to 3.0.1
## 2017-03-12 - Release 1.1.0 (PENDING)

### Summary

- Update testing
  * Add beaker-rspec tests
  * Update rspec-puppet tests
  * Update module data (gemfile, rakefile, etc around testing/development)
- Add LICENSE file
- Bump default Crowd version to 2.11.1
- Stop Crowd service on updating
- Provide `crowd::facts` manifest to provide external fact that reports the
  installed version. This is used for handling updates.
- Add `logdir` parameter (PR #16 by @prikkeldraad)
- Allow IP address in download_url (PR #13 @BenjaminFarley)
- Allow dots in usernames (PR #9 @cyberious)
- Use `CATALINA_OPTS` instead of `JAVA_OPTS` in `setenv.sh` (issue #14 @galcorlo)

## 2016-06-10 - Release 1.0.5

### Summary

- Dependency metadata updated (s/nanliu-staging/puppet-staging) (issue #7)

## 2016-04-05 - Release 1.0.4

### Summary

- Update tests

## 2016-04-05 - Release 1.0.3 (deleted)

### Summary

- Fix default download_url to use https (issue #5)
- Bump default version to 2.8.4

## 2016-01-06 - Release 1.0.2

### Summary

- Fix default nologin path for Debian systems (issue #3)

## 2015-10-19 - Release 1.0.1

### Summary

- Fix PIDFile filename for systemd (resolves issue #2)

## 2015-10-15 - Release 1.0.0

### Summary

- Initial release (since forked)
- Complete refactoring
- Add testing
- Overhaul readme and documentation
