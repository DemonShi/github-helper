require 'github_helper/matchers/basic_matcher'

module GithubHelper::Matchers

  class FileMatcher < BasicMatcher
    def initialize(name)
      @interesting_name = name

      super(true)
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
      puts %Q|File "#{@interesting_name}" was modified|
    end
  end

end