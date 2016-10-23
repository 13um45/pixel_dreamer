require 'simplecov'

SimpleCov.minimum_coverage 80
SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter
]
SimpleCov.start do
  add_filter "/spec/"
  add_group "Libraries", "../lib"
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "pixel_dreamer"
