require 'rspec'
require 'motion-require'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
  config.color = true
  config.formatter     = 'documentation'
end
