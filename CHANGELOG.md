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
