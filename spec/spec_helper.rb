dir = File.expand_path(File.dirname(__FILE__) + '/..')
$LOAD_PATH.unshift File.join(dir, 'lib')

# Don't want github helper getting the command line arguments for tests
ARGV.clear

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should]
  end
end

module GithubHelper
  module Commands

  end
end