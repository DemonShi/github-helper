require 'github_helper/matchers/basic_matcher'

module GithubHelper::Matchers

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
          @matches.push(path)
        end
      end
    end

    protected

    def report_matches
      puts %Q|Directory "#{@interesting_name}" was changed|
    end

    def report_no_matches
      puts %Q|Directory "#{@interesting_name}" was not touched|
    end
  end

end