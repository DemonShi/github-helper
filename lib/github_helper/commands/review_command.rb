require 'github_helper/commands/basic_command'
require 'github_helper/client'

require 'github_helper/matchers/file_matcher'
require 'github_helper/matchers/dir_matcher'
require 'github_helper/matchers/too_big_to_analyze_matcher'
require 'github_helper/matchers/word_matcher'

module GithubHelper::Commands
  class ReviewCommand < BasicCommand
    DESCRIPTION = 'Processes open review for the repo and shows if they are interesting'

    def initialize
      @matchers = [
          GithubHelper::Matchers::FileMatcher.new('Gemfile'),
          GithubHelper::Matchers::FileMatcher.new('.gemspec'),
          GithubHelper::Matchers::DirMatcher.new('spec', false),
          GithubHelper::Matchers::WordMatcher.new('/dev/null'),
          GithubHelper::Matchers::WordMatcher.new('raise'),
          GithubHelper::Matchers::WordMatcher.new('.write'),
          GithubHelper::Matchers::WordMatcher.new('%x'),
          GithubHelper::Matchers::WordMatcher.new('exec'),
          GithubHelper::Matchers::TooBigToAnalyzeMatcher.new
      ]

      @client = GithubHelper::Client.get
      @verbose = 0
    end

    def process_argv(argv)
      while argv.length > 0
        arg = argv.shift
        if arg[0] == '-'
          case arg
          when '-v', '-vv', '-vvv'
            @verbose = arg.count 'v'
          else
            raise GithubHelper::CommandLineError, "Unknown argument #{arg}"
          end
        elsif !@repository
          @repository = arg
        else
          raise GithubHelper::CommandLineError, "Unknown argument #{arg}"
        end
      end

      @matchers.each { |matcher| matcher.verbose = @verbose }
    end

    def run
      unless @repository && @repository.split('/').length == 2
        raise GithubHelper::CommandLineError, 'Invalid repository name. Should be in format "account/project"'
      end

      unless @client.repository?(@repository)
        raise GithubHelper::CommandLineError, "Repository #{@repository} does not exits"
      end

      process_repo()
    end

    private

    def print_pull_report(url)
      print url + ' - '

      positive_matchers = @matchers.select { |matcher| matcher.interesting? }

      print !positive_matchers.empty? ? 'interesting' : 'not interesting', "\n"
      positive_matchers.each { |matcher| matcher.report }
    end

    def process_repo
      pulls = @client.pull_requests(@repository, :state => 'open')
      last_response = @client.last_response
      process_pulls(pulls)
      while last_response.rels[:next]

        pulls = @client.paginate(last_response.rels[:next].href)
        last_response = @client.last_response
        process_pulls(pulls)
      end
    end

    def load_pull_files(pull_number)
      fetching_text = 'Fetching files...'
      print fetching_text

      process_files(@client.pull_request_files(@repository, pull_number, :auto_paginate => true))

      while @client.last_response.rels[:next]
        print "\r"
        fetching_text += '.'
        print fetching_text

        process_files(@client.paginate(@client.last_response.rels[:next].href))
      end

      print "\r", ' ' * fetching_text.length, "\r"
    end

    def process_pulls(pulls)
      pulls.each do |pull_request|
        number = pull_request[:number]

        @matchers.each { |matcher| matcher.clear }

        load_pull_files(number)
        print_pull_report(pull_request[:html_url])
      end
    end

    def process_files(files)
      files.each do |pull_file|
        @matchers.each do |matcher|
          matcher.process_file(pull_file)
        end
      end
    end

  end
end

