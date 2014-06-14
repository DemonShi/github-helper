require 'github_helper/commands/basic_command'
require 'github_helper/client'

module GithubHelper::Commands
  class ReviewCommand < BasicCommand
    NAME = 'review'

    require 'github_helper/commands/review/matchers/file_matcher'
    require 'github_helper/commands/review/matchers/dir_matcher'
    require 'github_helper/commands/review/matchers/too_big_to_analyze_matcher'
    require 'github_helper/commands/review/matchers/word_matcher'

    def initialize
      @matchers = [
          FileMatcher.new('Gemfile'),
          FileMatcher.new('.gemspec'),
          DirMatcher.new('spec', false),
          WordMatcher.new('/dev/null'),
          WordMatcher.new('raise'),
          WordMatcher.new('.write'),
          WordMatcher.new('%x'),
          WordMatcher.new('exec'),
          TooBigToAnalyzeMatcher.new
      ]

      @client = GithubHelper::Client.get
    end

    def process_argv(argv)
      @repository = argv.shift
    end

    def run
      # TODO think of better exception type
      unless @repository && @repository.split('/').length == 2
        puts 'Invalid repository name. Should be in format "account/project"'
        return
      end

      unless @client.repository?(@repository)
        puts 'Repository ' + @repository + ' does not exits'
        return
      end

      process_repo()
    end

    private

    def print_pull_report(url)
      print url + ' - '

      positive_matchers = @matchers.select { |matcher| matcher.interesting? }

      print !positive_matchers.empty? ? 'interesting' : 'not interesting', "\n"
      positive_matchers.each { |matcher| print '- '; matcher.report }
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

