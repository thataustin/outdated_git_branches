#!/usr/bin/ruby

require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

VERSION = '0.1'

class GitStatusOptparser

    def self.parse(args)
        # The options specified on the command line will be collected in *options*.
        # We set default values here.
        options = OpenStruct.new
        options.verbose = false
        options.threshold = 50
        options.remote = 'origin'
        options.remote_branch = 'develops'
        options.branches_to_exclude = ['develop', 'master']

        opt_parser = OptionParser.new do |opts|
            opts.banner = "Usage: git_status.rb [options] ./folders ./separated/by ./spaces"

            opts.separator ""
            opts.separator "Specific options:"

            # Boolean switch.
            opts.on("-v", "--[no-]verbose", "Run verbosely; defaults to --no-verbose") do |v|
                options.verbose = v
            end

            opts.on("-e", "--exclude-branches [x,y,z]", Array, "List of branches to exclude in the comparison, default: ['develop', 'master']") do |list|
                options.branches_to_exclude = list
            end

            opts.on("-t", "--threshold [num]", Integer, "Minimum number of commits a branch must be out-of-date to generate a message, default: 50") do |threshold|
                options.threshold = threshold
            end

            opts.on("-r", "--remote [name]", "Name of remote to check branches against, default: origin") do |remote|
                options.remote = remote
            end

            opts.on("-b", "--remote-branch [name]", "Name of branch on the remote to check branches against, default: develop") do |branch|
                options.remote_branch = branch
            end

            opts.separator ""
            opts.separator "Common options:"

            # No argument, shows at tail.  This will print an options summary.
            # Try it and see!
            opts.on_tail("-h", "--help", "Show this message") do
                puts opts
                exit
            end

            # Another typical switch to print the version.
            opts.on_tail("--version", "Show version") do
                puts VERSION
                exit
            end
        end

        opt_parser.parse!(args)
        options
    end  # parse()

end