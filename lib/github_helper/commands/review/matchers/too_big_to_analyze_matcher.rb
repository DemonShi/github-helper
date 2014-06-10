require 'github_helper/commands/review/matchers/basic_matcher'

module GithubHelper::Commands::ReviewCommand::Matcher

  class TooBigToAnalyzeMatcher < BasicMatcher
    def initialize
      super(true)
    end

    def process_file(pull_file)
      path = pull_file[:filename]
      patch = pull_file[:patch]
      all_changes = pull_file[:additions] + pull_file[:deletions] + pull_file[:changes]
      if all_changes != 0 && patch == nil
        @matches.push(path)
      end
    end

    protected

    def report_matches
      puts 'Some changes are probably too long to analyze - please check manually'
    end
  end

end