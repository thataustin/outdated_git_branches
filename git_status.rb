#!/usr/bin/ruby
require 'net/smtp'

#SMTP Settings
SMTP_PORT = ''      # eg,'587'
SMTP_DOMAIN = ''    # eg,'gmail.com'
SMTP_SERVER = ''    # eg,'smtp.gmail.com'
SMTP_USER = ''      # eg 'you@gmail.com'
SMTP_PASSWORD = '', # eg 'popsiclesaretasty'

# Mail settings
MAIL_FROM = '',     # eg 'dev@yourcompany.com'
MAIL_TO = '',       # eg 'dev@yourcompany.com'

# Setup some branch terminology so the script knows what you're trying to compare each potentially outdated branch to
REMOTE_TO_COMPARE_TO = '' # eg 'origin'
REMOTE_BRANCH_TO_COMPARE_TO = '' # eg 'develop'
BRANCHES_TO_EXCLUDE = ['develop', 'master']

# Email will only be sent when a branch is more out of date than this number of commits
COMMITS_BEHIND_BEFORE_SENDING_EMAIL = 50

# Don't override this, holds the compiled messages
OUTDATED_BRANCH_MESSAGES = []


def deal_with_args(args)
    if args.include? '--help'
        puts "Usage:\n" +
            "\t--help\t\tShow this help text\n" +
            "\t--debug\t\tOutput debug text\n" +
            "\t-v\t\tAlias for --debug\n"
        exit
    end
end

def debug?
    ARGV.include? '--debug' or ARGV.include? '-v'
end

def get_all_branches
    puts "Fetching all branches" if debug?
    fetch_output = `git fetch --all`
    branches = `git branch`
        .split("\n")
        .map { |x| x.gsub(/\*/, '').strip }
        .reject { |branch| BRANCHES_TO_EXCLUDE.include? branch }

    puts "Found the following branches: " + branches.join(', ') + "\n\n\n" if debug?
    branches
end

def checkout_branch(branch)
    checkout_output = "\t" + `git checkout #{branch}`
    puts checkout_output if debug?
end

def change_upstream(upstream)
    upstream_output = "\t" + `git branch --set-upstream-to=#{upstream}`
    puts upstream_output if debug?
end

def add_outdated_branch(branch, num_commits_behind)
    if num_commits_behind.to_i > COMMITS_BEHIND_BEFORE_SENDING_EMAIL
        OUTDATED_BRANCH_MESSAGES.push("#{branch}: #{num_commits_behind} commits behind develop")
    end
end

def deal_with_diverged_branch (branch, git_status_output)
    if git_status_output.index('diverged')
        num_out_of_date = git_status_output.gsub(/.*and have (\d+) and (\d+) different.*/, '\2')
        add_outdated_branch(branch, num_out_of_date)
        puts "\t#{num_out_of_date} commits out of date" if debug?
    end
end

def deal_with_behind_branch (branch, git_status_output)
    if git_status_output.index('behind')
        num_out_of_date = git_status_output.gsub(/.*by *(\d+) commits.*/, '\1')
        add_outdated_branch(branch, num_out_of_date)
        puts "\t#{num_out_of_date} commits out of date" if debug?
    end
end

def send_outdated_branches_email

    # Dont send an email if we don't have any outdated branches
    if OUTDATED_BRANCH_MESSAGES.size == 0
        puts "Not sending any emails"
        return
    end
    puts "Sending out email about the following:\n" + OUTDATED_BRANCH_MESSAGES.join("\n") if debug?

    message = "From: Branch Monitor <#{MAIL_FROM}>\n" +
        "To: #{MAIL_TO} <#{MAIL_TO}>\n" +
        "Subject: Branch[es] are 50+ commits behind develop\n" +
        "\n" +
        "Don't be lazy, and fix the following outdated branches: \n" +
        "\t" + OUTDATED_BRANCH_MESSAGES.join("\n\t")

    smtp = Net::SMTP.new SMTP_SERVER, SMTP_PORT
    smtp.enable_starttls

    smtp.start(SMTP_DOMAIN, SMTP_USER, SMTP_PASSWORD, :login) do |started_smtp|
        started_smtp.send_message message, MAIL_FROM, MAIL_TO
    end
end

def deal_with_branch(branch, compare_to, reset_to)
    puts "Investigating branch: #{branch}" if debug?

    checkout_branch(branch)
    change_upstream(reset_to)

    pull_output = "\t" + `git pull`
    puts pull_output if debug?

    change_upstream(compare_to)

    git_status_output = `git status`.gsub("\n", ' ')

    puts "\tComputing behind-ness" if debug?
    deal_with_diverged_branch(branch, git_status_output)
    deal_with_behind_branch(branch, git_status_output)

    change_upstream(reset_to)
end

def deal_with_git_repository
    deal_with_args(ARGV)

    branch_to_compare_to = "#{REMOTE_TO_COMPARE_TO}/#{REMOTE_BRANCH_TO_COMPARE_TO}"

    get_all_branches.each do |branch|
        branch_to_reset_to = "#{REMOTE_TO_COMPARE_TO}/#{branch}"
        deal_with_branch(branch, branch_to_compare_to, branch_to_reset_to)
        puts "\n" if debug?
    end

    send_outdated_branches_email
end

deal_with_git_repository
