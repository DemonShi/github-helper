dir = File.expand_path(File.dirname(__FILE__) + '/..')
$LOAD_PATH.unshift File.join(dir, 'lib')

# Don't want github helper getting the command line arguments for tests
ARGV.clear

RSpec.configure do |config|
  config.mock_with :mocha
end

module GithubHelper
  module Commands

  end
end