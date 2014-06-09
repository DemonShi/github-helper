module GithubHelper::Commands::Review::Matcher

  class BasicMatcher

    def initialize(interesting_when_exist)
      @interesting_when_exist = interesting_when_exist
      @matches = []
    end

    def interesting?
      if @interesting_when_exist
        @matches.length != 0
      else
        @matches.length == 0
      end
    end

    def report
      if @matches.empty?
        report_no_matches
      else
        report_matches
      end
    end

    protected

    def report_no_matches
      raise NotImplementedError.new('This is an abstract base method. Implement in your subclass.')
    end

    def report_matches
      raise NotImplementedError.new('This is an abstract base method. Implement in your subclass.')
    end
  end

end