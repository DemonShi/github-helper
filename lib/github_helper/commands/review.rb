require 'github_helper/client'

class GithubHelper::Commands::Review
  # PROJECT = 'demonshi-test1/bigfile'
  PROJECT = 'puppetlabs/puppet'

  INTERESTING_FILES = %w(Gemfile .gemspec)
  INTERESTING_WHEN_NOT_CHANGED = 'spec'

  def initialize
    @client = GithubHelper::Client.get

    @review_results = {}
  end

  def run
    process_repo(PROJECT)
  end

  private

  def print_pull_report(number)
      pull_report = @review_results[number]
      print pull_report[:url], ' - '
      print pull_report[:interesting][:status] || !pull_report[:interesting][:spec_changed] ? 'interesting' : 'not interesting'
    puts
  end

  def process_repo(repo)
    @client.pull_requests(repo, :state => 'open').each do |pull_request|
      number = pull_request[:number]
      interesting_obj = { :status => false, :files => [], :words => [], :spec_changed => false }
      @review_results[number] = { :interesting => interesting_obj, :url => pull_request[:html_url] }

      load_pull_files(repo, number)
      print_pull_report(number)
    end
  end

  def load_pull_files(repo, pull_number)
    fetching_text = 'Fetching files...'
    print fetching_text

    process_files(pull_number, @client.pull_request_files(repo, pull_number, :auto_paginate => true))

    while @client.last_response.rels[:next]
      print "\r"
      fetching_text += '.'

      print fetching_text
      process_files(pull_number, @client.paginate(@client.last_response.rels[:next].href))
    end

    print "\r", ' ' * fetching_text.length, "\r"
  end

  def process_files(pull_number, files)
    files.each do |pull_file|
      path = pull_file[:filename]
      path_split = path.split('/')
      filename = path_split[-1]

      if INTERESTING_FILES.include?(filename)
        @review_results[pull_number][:interesting][:status] = true
      end

      if path_split[0...-1].include?(INTERESTING_WHEN_NOT_CHANGED)
        @review_results[pull_number][:interesting][:spec_changed] = true
      end
    end


  end

end

