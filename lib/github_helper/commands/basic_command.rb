module GithubHelper::Commands
  class BasicCommand
    def process_argv(argv)
    end

    def run
      raise NotImplementedError.new('This is an abstract base method. Implement in your subclass.')
    end
  end
end

