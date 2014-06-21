#! /usr/bin/env ruby
require 'spec_helper'
require 'github_helper/matchers/file_matcher'

describe GithubHelper::Matchers::FileMatcher do
  it "should be non interesting by default" do
    matcher = GithubHelper::Matchers::FileMatcher.new('')

    matcher.should_not be_interesting
  end

  it "should be interesting when matches" do
    path = filename = 'foo'
    matcher = GithubHelper::Matchers::FileMatcher.new(filename)

    matcher.process_file(:filename => path)
    matcher.should be_interesting
  end

  it "should be non interesting when not matches" do
    path = 'foo'
    filename = 'bar'
    matcher = GithubHelper::Matchers::FileMatcher.new(filename)

    matcher.process_file(:filename => path)
    matcher.should_not be_interesting
  end

  it "should be non interesting when folder in path matches but filename is different" do
    path = 'bar/foo'
    filename = 'bar'
    matcher = GithubHelper::Matchers::FileMatcher.new(filename)

    matcher.process_file(:filename => path)
    matcher.should_not be_interesting
  end

  it "should be non interesting after clear" do
    filename = 'foo'
    matcher = GithubHelper::Matchers::FileMatcher.new(filename)

    matcher.process_file(:filename => filename)

    matcher.clear
    matcher.should_not be_interesting
  end
end