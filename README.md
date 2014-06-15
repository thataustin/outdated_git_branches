outdated_git_branches
=====================

Emails you whenever a branch in your repo gets too out of date (helps keep stuff clean on large teams)

###Usage:
ruby git_status.rb [-v|--debug|--help]

####What's it do?
Nothing useful unless you configure it.  Open it up and configure the SMTP settings so it can send emails.

If you run this script from within a git directory, it will check out all branches, compare them with the develop branch and email you if a branch is over 50 (or the number you've configured at the top of the script) commits out of date.