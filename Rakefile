#require 'init'
require "rake/testtask"
require "rake/clean"

begin
  require 'resque/tasks'
  require 'redis/raketasks'
rescue LoadError
  "Unable to load redis / resque tasks..."
end

desc "Default: run all tests"
task :default => :test

desc "Run tests"
task :test => %w[test:unit test:acceptance]
namespace :test do
  desc "Run unit tests"
  Rake::TestTask.new(:unit) do |t|
    t.libs << "test"
    t.test_files = FileList["test/unit/*_test.rb"]
  end

  desc "Run acceptance tests"
  Rake::TestTask.new(:acceptance) do |t|
    t.libs << "test"
    t.test_files = FileList["test/acceptance/*_test.rb"]
  end
end


namespace :integrity do
  desc "Check for new commits"
  task :check_for_commits do
    require "init"
    Integrity::Project.check_for_commits
  end

  task :watch_for_commits do
    require 'init'
    @shutdown = false
    trap('TERM') { @shutdown = true  }
    trap('INT')  { @shutdown = true  }
    trap('QUIT') { @shutdown = true  }

    puts 'Watching for commits...'
    loop do
      break if @shutdown
      puts Time.now
      Integrity::Project.check_for_commits
      sleep ENV['INTERVAL'].to_i || 15
    end
  end
end

task :db do
  require "init"
  DataMapper.auto_upgrade!
end

desc "Clean-up build directory"
task :cleanup do
  require "init"
  Integrity::Build.all(:completed_at.not => nil).each { |build|
    dir = Integrity.directory.join(build.id.to_s)
    dir.rmtree if dir.directory?
  }
end

namespace :jobs do
  desc "Clear the delayed_job queue."
  task :clear do
    require "init"
    require "integrity/builder/delayed"
    Delayed::Job.delete_all
  end

  desc "Start a delayed_job worker."
  task :work do
    require "init"
    require "integrity/builder/delayed"
    Delayed::Worker.new.start
  end
end

namespace :resque do

  def kill_threads(threads)
    threads.each { | thread | Thread.kill(thread) }
  end

  task :setup do
    require "init"
  end

  desc "Start a Resque worker for Integrity"
  task :work do
    require "init"
    ENV["QUEUE"] = "integrity"
    Rake::Task["resque:resque:work"].invoke
  end

  desc "Start a Resque worker per queue Integrity"
  task :worker_per_queue => :setup do
    threads = []

    Integrity.build_queues.each do |queue|
      ENV["QUEUE"] = "#{queue}"
      threads << Thread.new do
        system "rake resque:work"
      end
    end

    threads.each { |thread| thread.join }

  end

  desc "Kill all the workers"
  task  :kill_all_workers => :setup do
    rake_info = `ps -e | grep [r]esque:worker_per_queue`.split()
    unless rake_info.empty?
      parent_pid = rake_info[0]
      children = `ps -ef| awk '$3 == '#{parent_pid}' { print $2 }'`.split
      children.each do |pid|
        `kill #{pid}`
      end
    end
  end

end


desc "Generate HTML documentation."
file "doc/integrity.html" => ["doc/htmlize",
                              "doc/integrity.txt",
                              "doc/integrity.css"] do |f|
  sh "cat doc/integrity.txt | doc/htmlize > #{f.name}"
end

CLOBBER.include("doc/integrity.html")
