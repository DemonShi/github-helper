$LOAD_PATH << File.expand_path('../', __FILE__)

require 'octokit'

require 'github_helper/commands'

begin
  GithubHelper::Commands.run
rescue Faraday::SSLError => e
  puts 'Failed to open HTTPS connection. You probably forgot to set SSL_CERT_FILE env variable.'
  raise e
end
