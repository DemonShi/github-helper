#! /usr/bin/env ruby
require 'spec_helper'
require 'github_helper/commands/review/matchers/basic_matcher'

class TestMatcher < GithubHelper::Commands::ReviewCommand::BasicMatcher
  def add_match(match)
    @matches.push(match)
  end

  protected
  def report_no_matches
  end

  def report_matches
  end
end

describe GithubHelper::Commands::ReviewCommand::BasicMatcher do
  context "with interesting_when_exist equals to true" do
    let(:matcher) { TestMatcher.new(true) }

    before(:each) do
      matcher.should_not receive(:report_no_matches)
    end

    context "without match" do
      it "should be non interesting" do
        matcher.should_not be_interesting
      end

      it "should throw error when trying to report" do
        lambda {matcher.report}.should raise_error
      end
    end

    context "with match" do
      before(:each) do
        matcher.add_match('')
      end

      it "should be interesting" do
        matcher.should be_interesting
      end

      it "should be non interesting after clear" do
        matcher.clear
        matcher.should_not be_interesting
      end

      context "with verbose 0" do
        before(:each) do
          matcher.verbose = 0
        end

        it "should not report" do
          matcher.should_not receive(:report_matches)
          matcher.report
        end
      end

      context "with verbose 1" do
        before(:each) do
          matcher.verbose = 1
        end

        it "should report" do
          matcher.should receive(:report_matches)
          matcher.report
        end

        it "should not report matches list" do
          matcher.should_not receive(:report_single_match)
          matcher.report
        end
      end

      context "with verbose 2" do
        before(:each) do
          matcher.verbose = 2
        end

        it "should report" do
          matcher.should receive(:report_matches)
          matcher.report
        end

        it "should report matches list" do
          matcher.should receive(:report_single_match)
          matcher.report
        end
      end
    end

  end

  context "with interesting_when_exist equals to false" do
    let(:matcher) { TestMatcher.new(false) }

    before(:each) do
      matcher.should_not receive(:report_single_match)
      matcher.should_not receive(:report_matches)
    end

    context "without match" do
      it "should be interesting" do
        matcher.should be_interesting
      end

      it "should be interesting after clear" do
        matcher.add_match('')
        matcher.clear
        matcher.should be_interesting
      end

      context "with verbose 0" do
        before(:each) do
          matcher.verbose = 0
        end

        it "should not report" do
          matcher.should_not receive(:report_no_matches)
          matcher.report
        end
      end

      context "with verbose 1" do
        before(:each) do
          matcher.verbose = 1
        end

        it "should report" do
          matcher.should receive(:report_no_matches)
          matcher.report
        end
      end

      context "with verbose 2" do
        before(:each) do
          matcher.verbose = 2
        end

        it "should report" do
          matcher.should receive(:report_no_matches)
          matcher.report
        end
      end
    end

    context "with match" do
      before(:each) do
        matcher.add_match('')
      end

      it "should be non interesting" do
        matcher.should_not be_interesting
      end

      it "should throw error when trying to report" do
        lambda {matcher.report}.should raise_error
      end
    end
  end
end