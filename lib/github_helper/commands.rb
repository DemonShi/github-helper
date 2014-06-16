require 'github_helper/error'

module GithubHelper
  module Commands
    require 'github_helper/commands/review_command'
    require 'github_helper/commands/help_command'

    COMMANDS = {
        :review => ReviewCommand,
        :help => HelpCommand
    }.freeze
    HelpCommand.set_commands(COMMANDS)

    def self.run
      command_name = ARGV.shift

      unless command_name
        command_name = 'help'
      end

      command_class = COMMANDS[command_name.to_sym]
      unless command_class
        message = 'Invalid command. '
        message += 'Available commands: '
        message += COMMANDS.keys.collect { |k| k.to_s }.join(', ')

        raise GithubHelper::CommandLineError, message
      end

      command = command_class.new
      command.process_argv(ARGV)
      command.run
    end
  end
end