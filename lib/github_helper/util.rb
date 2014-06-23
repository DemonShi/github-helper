begin
  require 'io/console'
rescue LoadError
end

module GithubHelper
  class Util
    if STDIN.respond_to?(:noecho)
      def self.get_password(prompt="Password: ")
        print prompt
        pwd = STDIN.noecho(&:gets).chomp
        puts
        pwd
      end
    else
      def self.get_password(prompt="Password: ")
        pwd = `read -s -p "#{prompt}" password; echo $password`.chomp
        puts
        pwd
      end
    end
  end
end
