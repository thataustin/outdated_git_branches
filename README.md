outdated_git_branches
=====================

Emails you whenever a branch in your repo gets too out of date (helps keep stuff clean on large teams)

~~~
Usage: git_status.rb [options] ./folders ./separated/by ./spaces

Specific options:
    -v, --[no-]verbose               Run verbosely; defaults to --no-verbose
    -e, --exclude-branches [x,y,z]   List of branches to exclude in the comparison, default: ['develop', 'master']
    -t, --threshold [num]            Minimum number of commits a branch must be out-of-date to generate a message, default: 50
    -r, --remote [name]              Name of remote to check branches against, default: origin
    -b, --remote-branch [name]       Name of branch on the remote to check branches against, default: develop

Common options:
    -h, --help                       Show this message
        --version                    Show version
~~~

####What's it do?

Loops through directories you specify on the command line, checks out all the branches in each of those directories, compare them with the develop branch (or the -b option) and spits out a rudimentary report letting you know which branches in which directories are out of date (so long as they are out of date by more than or equal to the number of commits specified by the -t flag)

####Example
~~~
# Finds all folders that have a .git folder inside them (limiting to 3 directories deep), and comparing each branch in thos directories to origin/master in their remote refs list
find . -type d -name .git -maxdepth 3 | sed s/.git//g | xargs outdated_git_branches/git_status.rb -b master
~~~
