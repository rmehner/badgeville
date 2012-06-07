0.4.0 (May XX, 2012)
====================

* BREAKS BACKWARDS COMPATIBILITY
* DOES NOT INCLUDE PROPER ERROR HANDLING YET!

* Activity now lazily loads its attributes
* Client now defaults to https
* Remove deprecated `grayscale_url` from Badgeville::Reward, use `image_url(:grayscale)` instead
* Badgeville::Player implemented with:
  * `find_by_email_and_site` to find a player by its user email and the site
  * `find_by_id` to find a player by its id
  * `create` to create a player at Badgeville (`email` and `site`)
  * `update` to update a player by the player_id
  * `delete` to delete a player by the player_id
* Badgeville::User implemented with:
  * `find` which takes the user id or his email and returns a Badgeville::User object
  * `create` to create a user on the Badgeville network
  * `delete` to delete a user on the Badgeville network
* Badgeville::Activity enhanced with:
  * `create` to create an activity for the player by the player_id or site and email
  * `deleted_at`, `internal?`, `id`
  * a mapper for units one got for the activity. For example if a custom unit "unit_xp" is
    defined for the Activity you'll have access to it via `activity.unit_xp`
* Deprecated `Badgeville::Client.log_activity` in favor of `Badgeville::Activity.create`
* Moved deprecated methods to a separate module `DeprecatedClientMethods`.
* Badgeville::Reward enhanced with:
  * `find_by_player_id` to get all the rewards for a player by the player_id (reads through pagination)
  * `find_by_email_and_site` to get all the rewards for a player by email and site (reads through pagination)
* Badgeville::RewardDefinition implemented with:
  * `find_by_site` to get all the reward definitions for a site (returned as Badgeville::Reward)
* Badgeville::Client now raises correct Errors when RestClient raises an error
* `Badgeville::Client.delete` now handles DELETE requests and forwards to `remove_reward` if called with an reward object
* Renamed `Badgeville::Client.delete` to `Badgeville::Client.remove_reward`
* Deprecated `Badgeville::Client.public_key=` as we don't need the public key anyway

0.1.1 (May 7, 2012)
===================

* Reward#image_url now returns nil if no image was defined in the parsed json

0.1.0 (May 6, 2012)
===================

* Fixed support for new response format in tags
* Added support for protocol relative image urls
* Tests are now run by TravisCI against 1.9.2 / 1.9.3
* Dropping support for 1.8.x if there every was one
* add debug flag
* create a user / player

0.0.8 (November 30, 2011)
=========================

* support pagination and get all pages for rewards and rewards definitions
* misc bug fixes

0.0.7 (November 30, 2011)
=========================

* HAS MAJOR BUG DO NOT USE

0.0.6 (November 15, 2011)
=========================

* change set player to use new players/info end point
* add delete method for earned rewards
* add definition_id to reward

0.0.5 (October 10, 2011)
========================

* set default timeout to 3s
* add timeout parameter

0.0.4 (September 18, 2011)
==========================

* count activities
* better error handling
* add tags to rewards

0.0.3 (September 12, 2011)
==========================

* Activity.rewards includes reward objects not reward definitions
* Reward has verb and threshold data for achievments type rewards
* Raise non json errors
