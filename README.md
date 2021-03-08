# lock_out

Redmine plugin that locks previous months time entry. Great for getting better control over billing and timesheets for users.

## Features

* Stop users from adding time to previous months
* Customise the date the previous month should be locked at
* Allow admin users to unlock previous months and then relock

## Requirements

* Redmine 2.x.x
* Ruby 1.9.3

## Installation

This is just a normal Redmine plugin so it can be installed by cloning the repo to the Redmine plugin directory.

Run `rake redmine:plugins:migrate` to migrate the required database table.

Restart the Redmine server.

The lock out is now in effect for any previous months. You can give users access to unlock a month by adding the permission. Go to the permissions section and add the view and alter lock dates permissions to the groups that you want to allow access. 

They can now unlock and lock previous month by going to the Lock date link in the top menu.
