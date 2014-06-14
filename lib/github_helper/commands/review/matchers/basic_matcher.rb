module GithubHelper::Commands::ReviewCommand::Matcher

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
      unless @matches.empty? != @interesting_when_exist
        raise StandardError.new('Trying to print report when in illegal state - not supported')
      end

      if @matches.empty?
        report_no_matches
      else
        report_matches
      end
    end

    def clear
      @matches.clear
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