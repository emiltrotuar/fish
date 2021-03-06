#!/usr/bin/ruby
# require 'pry'

WORK_BRANCH_FILE = File.dirname(__FILE__) + '/work_branch' # path_to_work_branch_file

unless File.exists? WORK_BRANCH_FILE
  puts 'Please create a branch file'
  exit
end

master_branch = `git symbolic-ref refs/remotes/origin/HEAD`.strip.split('/')[-1]
current_branch = `git rev-parse --abbrev-ref HEAD`.strip

command        = ARGV[0]
base_branch    = ARGV[1]

if command
  case command
    when 'pull'
      puts 'pulling'
      `git stash`
      `git pull origin #{current_branch}`
    when 'rebase'
      base_branch ||= master_branch
      puts "rebasing on #{base_branch} branch"
      `git stash`
      `git pull --rebase origin #{base_branch}`
      `git stash pop`
    when 'back' # back to work on your branch
      puts 'back home'
      f = File.new(WORK_BRANCH_FILE)
      work_branch = f.read
      f.close
      if current_branch == work_branch
        puts "You're already on your working branch!"
        exit
      end
      `git stash`
      `git checkout #{work_branch}`
      `git stash pop`
    when 'new' # fish new int-999 "New \"feature\" branch" -> INT-999_New__feature__branch
      puts 'creating new feature branch'
      ticket_name = ARGV[1] && ARGV[1].strip.gsub(/(?:[^\w\/]|_)+/,'-')
      ticket_name.upcase!
      `git stash`
      unless current_branch == master_branch
        `git co #{master_branch}`
      end
      `git pull`
      branch_name = ticket_name || 'new_feature'
      `git checkout -b #{branch_name}`
      f = File.new(WORK_BRANCH_FILE,'w+')
      f.write branch_name
      f.close
    else # fish "fishing_branch_name"
      puts 'checkout'
      if current_branch == command
        puts "You're already on fish branch!"
        exit
      end
      `git stash`
      if `git branch --list #{command}`.size != 0
        `git checkout #{command}`
        `git pull origin #{command}`
      else
        `git fetch origin`
        `git checkout #{command}`
      end
      f = File.new(WORK_BRANCH_FILE,'w+')
      f.write current_branch
      f.close
  end
else
  puts 'Please provide some argument'
end
