#! /usr/bin/env ruby
require 'spec_helper'
require 'github_helper/matchers/too_big_to_analyze_matcher'

describe GithubHelper::Matchers::TooBigToAnalyzeMatcher do
  FILE_PATH = 'some/path'

  let(:matcher) { GithubHelper::Matchers::TooBigToAnalyzeMatcher.new() }

  it "should be non interesting by default" do
    matcher.should_not be_interesting
  end

  context "with patch" do
    it "should be non interesting when changes exist" do
      matcher.process_file(:filename => FILE_PATH, :additions => 1, :deletions => 0, :changes => 0, :patch => 'text')
      matcher.should_not be_interesting
    end

    it "should be non interesting when changes are zero" do
      matcher.process_file(:filename => FILE_PATH, :additions => 0, :deletions => 0, :changes => 0, :patch => 'text')
      matcher.should_not be_interesting
    end
  end

  context "without patch" do
    it "should be interesting when changes exist" do
      matcher.process_file(:filename => FILE_PATH, :additions => 1, :deletions => 0, :changes => 0, :patch => nil)
      matcher.should be_interesting
    end

    it "should be non interesting when changes are zero" do
      matcher.process_file(:filename => FILE_PATH, :additions => 0, :deletions => 0, :changes => 0, :patch => nil)
      matcher.should_not be_interesting
    end
  end
end