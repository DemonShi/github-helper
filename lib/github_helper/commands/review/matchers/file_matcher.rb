require 'github_helper/commands/review/matchers/basic_matcher'

module GithubHelper::Commands::Review::Matcher

  class FileMatcher < BasicMatcher
    def initialize(name, interesting_when_exist=true)
      @interesting_name = name

      super(interesting_when_exist)
    end

    def process_file(pull_file)
      path = pull_file[:filename]
      path_split = path.split('/')
      filename = path_split[-1]

      if @interesting_name == filename
        @matches.push(path)
      end
    end

    protected

    def report_matches
      puts 'File ' + @interesting_name + ' was modified'
    end

    def report_no_matches
      puts @interesting_name + ' file was not touched'
    end
  end

end