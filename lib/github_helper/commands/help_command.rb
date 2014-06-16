require 'github_helper/commands/basic_command'
require 'github_helper/client'

module GithubHelper::Commands
  class HelpCommand < BasicCommand
    DESCRIPTION = 'Prints current help or command specific help'

    KEY_DESCRIPTION_DISTANCE = 10

    def process_argv(argv)
    end

    def run
      puts "Usage: #{APP_NAME} <command> [<args>]"
      puts
      puts "Commands:"

      @@commands.each do |key, command|
        filler = ' ' * (KEY_DESCRIPTION_DISTANCE - key.length)
        puts "   #{key}#{filler}#{command::DESCRIPTION}"
      end
    end

    def self.set_commands(commands)
      @@commands = commands
    end
  end
end
