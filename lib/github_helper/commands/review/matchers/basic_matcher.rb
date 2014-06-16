require 'github_helper/error'

class GithubHelper::Commands::ReviewCommand

  class BasicMatcher

    attr_accessor :verbose

    def initialize(interesting_when_exist)
      @interesting_when_exist = interesting_when_exist
      @matches = []

      @verbose = 0
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
        raise GithubHelper::Error.new('Trying to print report when in illegal state - not supported')
      end

      if @verbose > 0
        print '* '
        if @matches.empty?
          report_no_matches
        else
          report_matches
          if @verbose > 1
            report_maches_list
          end
        end
      end
    end

    def clear
      @matches.clear
    end

    protected

    # Prints a message that matches were not found
    # Is called when @interesting_when_exist is set to false
    def report_no_matches
      raise NotImplementedError.new('This is an abstract base method. Implement in your subclass.')
    end

    # Prints a message that matches were found
    # Is called when @interesting_when_exist is set to true
    def report_matches
      raise NotImplementedError.new('This is an abstract base method. Implement in your subclass.')
    end

    # Prints a single match when @verbose is set to true
    # Can be overwritten in child class
    def report_single_match(match)
      puts match
    end

    private

    def report_maches_list
      @matches.each { |match| print "\t* "; report_single_match(match)  }
    end
  end

end