require 'octokit'

module GithubHelper
  class Client
    DEFAULT_LOGIN = 'DemonShi-test3'
    DEFAULT_PASSWORD = 'f,f,fufkfvfuf1'

    @@client = nil

    def self.get
      unless @@client
        @@client = ::Octokit::Client.new(:login => DEFAULT_LOGIN, :password => DEFAULT_PASSWORD)
      end

      @@client
    end
  end
end
