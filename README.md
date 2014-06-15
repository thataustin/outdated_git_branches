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

Loops through directories you specify on the command line, checks out all the branches in each of those directories, compare them with the develop branch (or the value of the -b option) on the remote ref named origin (or the value of the -r option) and spits out a rudimentary report letting you know which branches in which directories are out of date with that remote (so long as they are out of date by more than or equal to the number of commits specified by the -t flag)


####Getting Started
At the moment, you have to git clone this repo and manually run the outdated_git_branches/git_status.rb file.  Please suggest better ways to do this.  I'd consider packaging it as a ruby gem or a debian package [or something cooler] if anyone shows interest.

####Examples

In short, you list the git repo folders on the command line like this:
~~~
./outdated_git_branches/git_status.rb --remote origin --remote-branch develop ./ ./first_repo ./second_repo
~~~

But it's designed to make it easy to pipe folder names as arguments (using something like xargs) so that you can pipe the output somewhere helpful (in the util folder, there's an example script that can help you mail the results somewhere if you configure the SMTP settings).

~~~
# Finds all folders that have a .git folder inside them (limiting to 3 directories deep), and comparing each branch in those directories to origin/master in their remote refs list (master is specified, origin is the default remote)
find . -type d -name .git -maxdepth 3 | sed s/.git//g | xargs outdated_git_branches/git_status.rb -b master
~~~
