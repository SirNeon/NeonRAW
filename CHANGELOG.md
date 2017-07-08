## 0.1.7

* Changed Me#purge! so you can now edit archived posts.
* Error handling has been refactored a bit.
* Refactored how subreddit#submit buildings submission objects.
* Renamed Comment#link_id and Comment#parent_id to link_name and parent_name.
* \#distinguished renamed to distinguished!
* Subreddit#info was moved to client#info and returns a listing now.
* User/Me objects now have a \#username attribute and \#name returns the object's fullname now.

### Added

* Content streams have been added to user and subreddit objects.
* Added support for /r/popular.
* You can now sticky distinguished comments.
* MoreComments object has a comment? method now to make sifting through listings easier.
* Hashie is now a runtime dependency.
* You can now fetch duplicates of submissions.
* Comments now have a permalink method.
* User objects have a \#suspended? attribute now.
* Subreddits have a \#moderators method now.

## 0.1.6

### Added

* Comment and Submission objects now have methods to help determine which is which when iterating through a listing. The two are often intermixed when fetching a user's overview.

## 0.1.5

* Changed conditional statement in the ratelimiting so that the client will sleep if requests_remaining is <= 0.
* Changed Subreddit#info parameter from :id to :name since it takes a fullname instead of the ID.

## 0.1.4

* Renamed flatten_comments to flatten_tree and moved it to the client utilities rather than being a submission method.

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
