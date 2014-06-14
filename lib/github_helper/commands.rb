require 'github_helper/error'

module GithubHelper
  module Commands
    require 'github_helper/commands/review_command'

    COMMANDS = [
        ReviewCommand
    ].freeze

    def self.run
      command_name = ARGV.shift

      command_class = COMMANDS.find { |command| command::NAME == command_name }
      unless command_class
        message = 'Invalid command. '
        message += 'Available commands: '
        message += COMMANDS.collect { |command| command::NAME }.join(', ')

        raise GithubHelper::CommandLineError, message
      end

      command = command_class.new
      command.process_argv(ARGV)
      command.run
    end
  end
end