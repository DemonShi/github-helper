require 'github_helper/commands/basic_command'
require 'github_helper/client'

module GithubHelper::Commands
  class ReviewCommand < BasicCommand
    require 'github_helper/commands/review/matchers/file_matcher'
    require 'github_helper/commands/review/matchers/dir_matcher'
    require 'github_helper/commands/review/matchers/too_big_to_analyze_matcher'
    require 'github_helper/commands/review/matchers/word_matcher'


    NAME = 'review'
    # PROJECT = 'demonshi-test1/bigfile'
    # PROJECT = 'puppetlabs/puppet'

    def initialize
      @client = GithubHelper::Client.get
    end

    def process_argv(argv)
      @project = argv.shift
    end

    def run
      # TODO think of better exception type
      unless @project && @project.split('/').length == 2
        puts 'Invalid project name. Should be in format "account/project"'
        return
      end

      # TODO check that project exist
      process_repo(@project)
    end

    private

    def create_matchers
      matchers = []
      matchers.push(Matcher::FileMatcher.new('Gemfile'))
      matchers.push(Matcher::FileMatcher.new('.gemspec'))
      matchers.push(Matcher::DirMatcher.new('spec', false))
      matchers.push(Matcher::WordMatcher.new('/dev/null'))
      matchers.push(Matcher::WordMatcher.new('raise'))
      matchers.push(Matcher::WordMatcher.new('.write'))
      matchers.push(Matcher::WordMatcher.new('%x'))
      matchers.push(Matcher::WordMatcher.new('exec'))
      matchers.push(Matcher::TooBigToAnalyzeMatcher.new)

      matchers
    end

    def print_pull_report(url, matchers)
      print url + ' - '

      positive_matchers = matchers.select { |matcher| matcher.interesting? }

      print !positive_matchers.empty? ? 'interesting' : 'not interesting', "\n"
      positive_matchers.each { |matcher| print '- '; matcher.report }
    end

    def process_repo(repo)
      # TODO implement pagination
      @client.pull_requests(repo, :state => 'open').each do |pull_request|
        number = pull_request[:number]

        matchers = create_matchers()

        load_pull_files(repo, number, matchers)
        print_pull_report(pull_request[:html_url], matchers)
      end
    end

    def load_pull_files(repo, pull_number, matchers)
      fetching_text = 'Fetching files...'
      print fetching_text

      process_files(@client.pull_request_files(repo, pull_number, :auto_paginate => true), matchers)

      while @client.last_response.rels[:next]
        print "\r"
        fetching_text += '.'

        print fetching_text
        process_files(@client.paginate(@client.last_response.rels[:next].href), matchers)
      end

      print "\r", ' ' * fetching_text.length, "\r"
    end

    def process_files(files, matchers)
      files.each do |pull_file|
        matchers.each do |matcher|
          matcher.process_file(pull_file)
        end
      end


    end

  end
end

