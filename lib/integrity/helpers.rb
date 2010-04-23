require "integrity/helpers/authorization"
require "integrity/helpers/breadcrumbs"
require "integrity/helpers/pretty_output"
require "integrity/helpers/rendering"
require "integrity/helpers/resources"
require "integrity/helpers/urls"
require "integrity/helpers/push"
require "integrity/helpers/json"

module Integrity
  module Helpers
    include Authorization, Breadcrumbs, PrettyOutput,
      Rendering, Resources, Urls, Json

    include Rack::Utils
    alias :h :escape_html
  end
end
