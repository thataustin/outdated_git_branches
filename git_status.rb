#!/usr/bin/ruby

# native libraries
require 'json'

# local files
require __dir__ + '/util/git_status_opt_parser'

class GitStatus

    def initialize(opts)

        # incoming options
        @verbose = opts.verbose
        @branches_to_exclude = opts.branches_to_exclude
        @threshold = opts.threshold
        @remote = opts.remote
        @remote_branch = opts.remote_branch

        # instance defaults
        @dirs = []
        @original_dir = Dir.getwd
        @outdated_branches = {}
    end

    def get_all_branches
        puts "Fetching all branches" if @verbose
        fetch_output = `git fetch --all`
        branches = `git branch`
            .split("\n")
            .map { |x| x.gsub(/\*/, '').strip }
            .reject { |branch| @branches_to_exclude.include? branch }

        puts "Found the following branches: " + branches.join(', ') + "\n\n\n" if @verbose
        branches
    end

    def checkout_branch(branch)
        checkout_output = "\t" + `git checkout #{branch} 2>&1`
        puts checkout_output if @verbose
    end

    def change_upstream(upstream)
        upstream_output = "\t" + `git branch --set-upstream-to=#{upstream}`
        puts upstream_output if @verbose
    end

    def add_outdated_branch(branch, num_commits_behind)
        return if num_commits_behind.to_i < @threshold.to_i

        current_repo = get_current_git_repo_name
        @outdated_branches[current_repo] = [] if !@outdated_branches.has_key?(current_repo)

        @outdated_branches[current_repo].push({
            :branch => branch,
            :commits_behind => num_commits_behind
        })
    end

    def deal_with_diverged_branch (branch, git_status_output)
        if git_status_output.index('diverged')
            num_out_of_date = git_status_output.gsub(/.*and have (\d+) and (\d+) different.*/, '\2')
            add_outdated_branch(branch, num_out_of_date)
            puts "\t#{num_out_of_date} commits out of date" if @verbose
        end
    end

    def deal_with_behind_branch (branch, git_status_output)
        if git_status_output.index('behind')
            num_out_of_date = git_status_output.gsub(/.*by *(\d+) commits.*/, '\1')
            add_outdated_branch(branch, num_out_of_date)
            puts "\t#{num_out_of_date} commits out of date" if @verbose
        end
    end

    def deal_with_branch(branch, compare_to, reset_to)
        puts "Investigating branch: #{branch}" if @verbose

        checkout_branch(branch)
        change_upstream(reset_to)

        pull_output = "\t" + `git pull`
        puts pull_output if @verbose

        change_upstream(compare_to)

        git_status_output = `git status`.gsub("\n", ' ')

        puts "\tComputing behind-ness" if @verbose
        deal_with_diverged_branch(branch, git_status_output)
        deal_with_behind_branch(branch, git_status_output)

        change_upstream(reset_to)
    end

    def deal_with_git_repository(directory)
        branch_to_compare_to = "#{@remote}/#{@remote_branch}"
        get_all_branches.each do |branch|
            branch_to_reset_to = "#{@remote}/#{branch}"
            deal_with_branch(branch, branch_to_compare_to, branch_to_reset_to)
            puts "\n" if @verbose
        end
    end

    def get_current_git_repo_name
        File.basename `git rev-parse --show-toplevel`.chomp
    end

    def get_status
        # at this point, everything in ARGV should be a git directory
        # that was specified on the command line
        ARGV.each do |dir|

            # Change into new directory so git commands can be run from there
            puts "cd'ing into #{dir}" if @verbose
            Dir.chdir(dir)

            deal_with_git_repository(dir)

            #Change back to original dir in case command-line paths are relative
            puts "cd'ing into original #{@original_dir}" if @verbose
            Dir.chdir(@original_dir)
        end
        # return the accrued messages
        @outdated_branches.to_json
    end

end

options = GitStatusOptparser.parse(ARGV)
status_obj = GitStatus.new(options)
puts status_obj.get_status