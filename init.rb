$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

require "vendor/gems/environment"
require "integrity"

# Uncomment as appropriate for the notifier you want to use
# = Email
# require "integrity/notifier/email"
# = IRC
# require "integrity/notifier/irc"
# = Campfire
# require "integrity/notifier/campfire"

Integrity.configure do |c|
  c.database     "sqlite3:integrity.db"
  c.directory    "builds"
  c.base_url     "http://ci.example.org"
  c.log          "integrity.log"
  c.github       "SECRET"
  c.build_all!
  c.builder      :resque
  c.keep_build_days 14
end
