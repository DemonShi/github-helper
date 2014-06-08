module GithubHelper
  class Client
    @@client = nil

    def self.get
      unless @@client
        @@client = Octokit::Client.new(:login => 'DemonShi-test3', :password => 'f,f,fufkfvfuf1')
      end

      @@client
    end
  end
end