require 'github_helper/commands/basic_command'
require 'github_helper/client'

module GithubHelper::Commands
  class HelpCommand < BasicCommand
    DESCRIPTION = 'Prints current help or command specific help'

    HELP = <<HERE
Usage: #{APP_NAME} help [command]

Description:
   This command prints help page of the application.

   General help is shown when no command is specified.
   Command specific help is shown otherwise.

HERE

    KEY_DESCRIPTION_DISTANCE = 10

    def process_argv(argv)
      command_name = argv.shift

      unless command_name
        puts "Usage: #{APP_NAME} <command> [<args>]"
        puts
        puts "Commands:"

        @@commands.each do |key, command|
          filler = ' ' * (KEY_DESCRIPTION_DISTANCE - key.length)
          puts "   #{key}#{filler}#{command::DESCRIPTION}"
        end
        return
      end

      command = @@commands[command_name.to_sym]
      unless command
        raise GithubHelper::CommandLineError, %Q|Invalid command name "#{command_name}"|
      end

      puts command::HELP
    end

    def run
    end

    def self.set_commands(commands)
      @@commands = commands
    end
  end
end
