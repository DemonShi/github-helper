module GithubHelper
  module Commands
    require 'github_helper/commands/review'

    def self.run

      command = Review.new
      command.run
    end
  end
end