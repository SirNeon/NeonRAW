## 0.1.4

### Fixed

* submission.comments no longer raises ServiceUnavailable if the permalink has an accented character in it. 

## 0.1.3

* handle_ratelimit now checks if X-Ratelimit-Remaining is zero when deciding whether or not to sleep.

### Fixed

* MoreComments.expand now returns [] if there are no children.

## 0.1.2

### Added

* Comment and MoreComments objects now have methods to check whether or not they're a MoreComments object. They're often found intermixed in listings and this makes it easier to establish which is which.

### Fixed

* parse_errors now returns as intended when the data doesn't have an errors key.

## 0.1.1

* Forgot to include Ruby version in gemspec file.

## 0.1.0

Beta released.
