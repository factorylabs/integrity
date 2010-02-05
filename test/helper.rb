begin
  # Require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fallback on doing the resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
  Bundler.require(:default, :test)
end

require "test/unit"

require "integrity"
require "fixtures"

begin
  require "ruby-debug"
  require "redgreen"
rescue LoadError
end

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
  include Integrity

  before(:all) do
    Integrity.configure { |c|
      c.database  "sqlite3:test.db"
      c.directory File.expand_path(File.dirname(__FILE__) + "/../tmp")
      c.base_url "http://www.example.com"
      c.log  "/dev/null"
      c.user "admin"
      c.pass "test"
    }
  end

  before(:each) do DataMapper.auto_migrate! end

  def capture_stdout
    output = StringIO.new
    $stdout = output
    yield
    $stdout = STDOUT
    output
  end

  def assert_change(object, method, difference=1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method)
  end

  def assert_no_change(object, method, &block)
    assert_change(object, method, 0, &block)
  end
end
