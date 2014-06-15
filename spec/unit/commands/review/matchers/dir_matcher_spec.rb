#! /usr/bin/env ruby
require 'spec_helper'
require 'github_helper/commands/review/matchers/dir_matcher'

describe GithubHelper::Commands::ReviewCommand::DirMatcher do
  context "with interesting when matches" do
    INTERESTING_WHEN_MATCH = true
    it "should be non interesting by default" do
      matcher = GithubHelper::Commands::ReviewCommand::DirMatcher.new('', INTERESTING_WHEN_MATCH)

      matcher.should_not be_interesting
    end

    it "should be interesting when matches" do
      path = 'foo/bar'
      dirname = 'foo'
      matcher = GithubHelper::Commands::ReviewCommand::DirMatcher.new(dirname, INTERESTING_WHEN_MATCH)

      matcher.process_file(:filename => path)
      matcher.should be_interesting
    end

    it "should be non interesting when not matches" do
      path = 'foo/bar'
      dirname = 'bar'
      matcher = GithubHelper::Commands::ReviewCommand::DirMatcher.new(dirname, INTERESTING_WHEN_MATCH)

      matcher.process_file(:filename => path)
      matcher.should_not be_interesting
    end

    it "should be non interesting after clear" do
      path = 'foo/bar'
      dirname = 'foo'
      matcher = GithubHelper::Commands::ReviewCommand::DirMatcher.new(dirname, INTERESTING_WHEN_MATCH)

      matcher.process_file(:filename => path)

      matcher.clear
      matcher.should_not be_interesting
    end
  end

  context "with interesting when does not match" do
    INTERESTING_WHEN_NOT_MATCH = false
    it "should be non interesting by default" do
      matcher = GithubHelper::Commands::ReviewCommand::DirMatcher.new('', INTERESTING_WHEN_NOT_MATCH)

      matcher.should be_interesting
    end

    it "should be interesting when matches" do
      path = 'foo/bar'
      dirname = 'foo'
      matcher = GithubHelper::Commands::ReviewCommand::DirMatcher.new(dirname, INTERESTING_WHEN_NOT_MATCH)

      matcher.process_file(:filename => path)
      matcher.should_not be_interesting
    end

    it "should be non interesting when not matches" do
      path = 'foo/bar'
      dirname = 'bar'
      matcher = GithubHelper::Commands::ReviewCommand::DirMatcher.new(dirname, INTERESTING_WHEN_NOT_MATCH)

      matcher.process_file(:filename => path)
      matcher.should be_interesting
    end

    it "should be non interesting after clear" do
      path = 'foo/bar'
      dirname = 'foo'
      matcher = GithubHelper::Commands::ReviewCommand::DirMatcher.new(dirname, INTERESTING_WHEN_NOT_MATCH)

      matcher.process_file(:filename => path)

      matcher.clear
      matcher.should be_interesting
    end
  end

end