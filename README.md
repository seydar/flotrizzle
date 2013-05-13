flotrizzle
==========

flocast screening project

= Requirements
* The system shall poll 4 CDNs for a JSON configuration file.
* The system shall poll every CDN in 5 minute intervals.
* The system shall save the JSON configuration file in a meaningful way in a
  Reddis.io data store upon successful poll.
* The system shall invoke a post script on every server specified in the JSON
  configuration upon successful poll (simulate this, but show code to SSH into
  a server).
* The system shall show an automated and verbose log of its activity on a web
  page (the more interactive -- the better).
* The system shall email the CDN, time of failure, and a link to view the activity
  log to the system administrators specified in last successful JSON configuration
  upon a poll failure.

= CDNs
* http://cdn.flotrack.org/config.json
* http://cdn.flowrestling.org/config.json
* http://cdn.gymnastike.org/config.json
* http://cdn.cyclingdirt.org/config.json

= JSON Configuration File:

{
  "servers"       :  [ ],  // array of server hosts/IP's
  "server_admins" :  [ ],  // array of emails to be notified for any new activity
  "post_script"   :  ""    // a script to run on the list of servers above
}

