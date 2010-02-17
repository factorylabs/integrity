$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

begin
  # Require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fallback on doing the resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup(:group, :names)
  Bundler.require(:default)
end


require "integrity"

# Uncomment as appropriate for the notifier you want to use
# = Email
# require "integrity/notifier/email"
# = IRC
# require "integrity/notifier/irc"
# = Campfire
# require "integrity/notifier/campfire"

Integrity.configure do |c|
  c.database     "mysql://root:fbisadc@localhost/integrity"
  c.directory    "builds"
  c.base_url     "http://ci.example.org"
  c.log          "integrity.log"
  c.github       "SECRET"
  c.user       "admin"
  c.pass       "admin"
  c.build_all!
  c.builder      :resque
  c.keep_build_days 14
end
