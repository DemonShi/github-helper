#! /usr/bin/env ruby
require 'spec_helper'
require 'github_helper/commands/review_command'

require 'stringio'

class TestClient
  def initialize(repo)
    @repo = repo
    @pull_requests = []
    @pull_request_files = {}
  end

  #
  # mock API
  #

  def repository?(repo)
    @repo == repo
  end

  def pull_requests(repo, options)
    @repo.should == repo
    options[:state].should == 'open'

    @pull_requests
  end

  def pull_request_files(repo, pull_request_number, options={})
    @repo.should == repo

    @pull_request_files[pull_request_number]
  end

  def last_response
    Struct.new(:rels).new({:next => nil})
  end

  #
  # Test API
  #

  def add_pull_request(pull_request)
    @pull_requests.index { |p| p[:number] == pull_request[:number] }.should == nil

    @pull_requests.push(pull_request)
    @pull_request_files[pull_request[:number]] = []
  end

  def add_pull_request_file(pull_request_number, pull_request_file)
    @pull_requests.index { |p| p[:number] == pull_request_number }.should_not == nil

    @pull_request_files[pull_request_number].push(pull_request_file)
  end
end

describe GithubHelper::Commands::ReviewCommand do
  mock_fn = lambda do |repo|
    client = TestClient.new(repo)
    GithubHelper::Client.stub(:get) { client }
    client
  end

  run_fn = lambda do |repo, verbosity|
    command = GithubHelper::Commands::ReviewCommand.new()
    command.process_argv([repo, verbosity])
    command.run
    nil
  end

  before do
    $stdout = StringIO.new
  end

  after(:all) do
    $stdout = STDOUT
  end

  context "with valid repo" do
    let(:repo) { 'some/repo' }
    let(:pull_url) { 'http://foo.bar/pull/number/1' }
    let(:another_pull_url) { 'http://foo.bar/pull/number/2' }
    let(:pull_request) { { :number => 1, :html_url => pull_url } }
    let(:pull_request_file) do
      {
        :filename => '',
        :status => 'added',
        :additions => 1,
        :deletions => 0,
        :changes => 1,
        :patch => "@@ -0,0 +1 @@\n+7"
      }
    end

    let(:client) do
      mock_fn.call(repo)
    end

    context "with single pull request" do
      before(:each) do
        client.add_pull_request(pull_request)
      end

      it "should mark empty pull request as interesting" do
        run_fn.call(repo, '-v')

        $stdout.string.should include(pull_url + ' - interesting')
        $stdout.string.should include(%Q|Directory "spec" was not touched|)
        $stdout.string.count('*').should == 1
      end

      context "with spec folder" do
        before(:each) do
          spec_file = pull_request_file.dup
          spec_file[:filename] = 'spec/file'
          client.add_pull_request_file(pull_request[:number], spec_file)
        end

        it "should mark pull request as not interesting" do
          run_fn.call(repo, '-v')

          $stdout.string.should include(pull_url + ' - not interesting')
          $stdout.string.count('*').should == 0
        end

        it "should match against filenames" do
          filenames = ['Gemfile', '.gemspec']

          filenames.each do |filename|
            file = pull_request_file.dup
            file[:filename] = filename
            client.add_pull_request_file(pull_request[:number], file)
          end

          run_fn.call(repo, '-v')

          $stdout.string.should include(pull_url + ' - interesting')
          filenames.each do |filename|
            $stdout.string.should include(%Q|File "#{filename}" was modified|)
          end
          $stdout.string.count('*').should == filenames.length
        end

        it "should match against reserved words" do
          words = ['/dev/null', 'raise', '.write', '%x', 'exec']

          file = pull_request_file.dup
          words.each do |word|
            file[:patch] += "+ #{word}"
          end
          client.add_pull_request_file(pull_request[:number], file)


          run_fn.call(repo, '-v')

          $stdout.string.should include(pull_url + ' - interesting')
          words.each do |word|
            $stdout.string.should include(%Q|Word "#{word}" was found|)
          end
          $stdout.string.count('*').should == words.length
        end

        it "should match agains too big file" do
          file = pull_request_file.dup
          file[:patch] = nil

          client.add_pull_request_file(pull_request[:number], file)

          run_fn.call(repo, '-v')

          $stdout.string.should include(pull_url + ' - interesting')
          $stdout.string.should include(%Q|too long to analyze|)
          $stdout.string.count('*').should == 1
        end
      end
    end

    context "with several pull requests" do
      before(:each) do
        client.add_pull_request(pull_request)
        another_pull_request = pull_request.dup
        another_pull_request[:number] = 2
        another_pull_request[:html_url] = another_pull_url
        client.add_pull_request(another_pull_request)
      end

      it "should contain all pull requests" do
        run_fn.call(repo, '-v')

        $stdout.string.should include(pull_url + ' - interesting')
        $stdout.string.should include(another_pull_url + ' - interesting')
        $stdout.string.should include(%Q|Directory "spec" was not touched|)
        $stdout.string.count('*').should == 2
      end
    end

  end

  context "with invalid repo" do
    let(:repo) { 'invalidrepo' }

    it "should show error" do
      mock_fn.call(repo)

      lambda { run_fn.call(repo, '-v') }.should raise_error do |e|
        e.message.should include("Invalid repository name.")
      end
    end
  end

  context "with non-existing repo" do
    let(:repo) { 'some/repo' }

    it "should show error" do
      mock_fn.call(repo)

      lambda { run_fn.call(repo + '1', '-v') }.should raise_error do |e|
        e.message.should include("does not exists")
      end
    end
  end
end