require 'github_helper/commands/review/matchers/basic_matcher'

module GithubHelper::Commands::Review::Matcher

  class DirMatcher < BasicMatcher
    def initialize(name, interesting_when_exist=true)
      @interesting_name = name

      super(interesting_when_exist)
    end

    def process_file(pull_file)
      path = pull_file[:filename]
      path_split = path.split('/')

      path_split[0...-1].each do |dirname|
        if @interesting_name.include?(dirname)
          @matches.push(dirname)
        end
      end
    end

    protected

    def report_matches
      puts 'Dir ' + @interesting_name + ' was changed'
    end

    def report_no_matches
      puts @interesting_name + ' dir was not touched'
    end
  end

end