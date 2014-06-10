module GithubHelper
  module Commands
    require 'github_helper/commands/review_command'

    def self.run
      command_name = ARGV.shift

      command_class = COMMANDS.find { |command| command::NAME == command_name }
      unless command_class
        print 'Invalid command. '
        print 'Available commands: ', COMMANDS.collect { |command| command::NAME }.join(', ')
        puts
        return
      end

      command = command_class.new
      command.process_argv(ARGV)
      command.run
    end

    private

    COMMANDS = [ReviewCommand]
  end
end