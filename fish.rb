#!/usr/bin/ruby
# require 'pry'

WORK_BRANCH_FILE = File.dirname(__FILE__) + '/work_branch' # path_to_work_branch_file

unless File.exists? WORK_BRANCH_FILE
  puts 'Please create a branch file'
  exit
end

development_branch =`git symbolic-ref refs/remotes/origin/HEAD`.strip.split('/')[-1]
current_branch = `git rev-parse --abbrev-ref HEAD`.strip

command        = ARGV[0]

def work_branch_name
  @work_branch_name ||= begin
                          f = File.new(WORK_BRANCH_FILE)
                          work_branch = f.read
                          f.close
                          work_branch
                        end
end

if command
  case command
    when 'pull'
      puts 'pulling'
      `git stash`
      `git pull origin #{current_branch}`
    when 'rebase'
      base_branch = ARGV[1] || development_branch
      puts "rebasing on #{base_branch} branch"
      `git stash`
      `git pull --rebase origin #{base_branch}`
      `git stash pop`
    when 'back' # back to work on your branch
      puts 'back home'
      if current_branch == work_branch_name
        puts "You're already on your working branch!"
        exit
      end
      `git stash`
      `git checkout #{work_branch_name}`
      `git stash pop`
    when 'new' # fish new int-999 "New \"feature\" branch" -> INT-999_New__feature__branch
      base_branch = ARGV[2] || development_branch
      puts "creating new feature branch from #{base_branch} branch"
      `git stash`
      unless current_branch == base_branch
        `git checkout #{base_branch}`
      end
      `git fetch`
      `git reset --hard origin/#{base_branch}`
      branch_name = ARGV[1] || 'new_feature'
      `git checkout -b #{branch_name}`
      f = File.new(WORK_BRANCH_FILE,'w+')
      f.write branch_name
      f.close
    when 'wb'
      puts "work branch: #{work_branch_name}"
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
