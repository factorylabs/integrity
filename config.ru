require "init"
require "resque/server"
require "integrity/integritray"

map "/resque" do
  run Resque::Server
end

map "/tray" do
  run Integrity::Integritray::App
end

map "/" do
  run Integrity.app
end


