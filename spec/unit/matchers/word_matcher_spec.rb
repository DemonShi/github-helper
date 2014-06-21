#! /usr/bin/env ruby
require 'spec_helper'
require 'github_helper/matchers/word_matcher'

describe GithubHelper::Matchers::WordMatcher do
  it "should be non interesting by default" do
    matcher = GithubHelper::Matchers::WordMatcher.new('')

    matcher.should_not be_interesting
  end

  it "should be interesting when matches" do
    word = 'foo'
    patch = '+  foo bar'
    matcher = GithubHelper::Matchers::WordMatcher.new(word)

    matcher.process_file(:patch => patch)
    matcher.should be_interesting
  end

  it "should be non interesting when not matches" do
    word = 'foo'
    patch = '+  bar'
    matcher = GithubHelper::Matchers::WordMatcher.new(word)

    matcher.process_file(:patch => patch)
    matcher.should_not be_interesting
  end

  it "should be non interesting when word exists but followed by word symbol" do
    word = 'foo'
    patch = '+  fooo'
    matcher = GithubHelper::Matchers::WordMatcher.new(word)

    matcher.process_file(:patch => patch)
    matcher.should_not be_interesting
  end

  it "should be non interesting after clear" do
    word = 'foo'
    patch = '+  foo'
    matcher = GithubHelper::Matchers::WordMatcher.new(word)

    matcher.process_file(:patch => patch)

    matcher.clear
    matcher.should_not be_interesting
  end

  context "with special symbols" do
    it "should pass tests" do
      tests = [
          {:word => '.foo', :patch => '+  .foo bar', :should => true},
          {:word => '%foo', :patch => '+  .foo bar', :should => false},
          {:word => '.f.o.o.', :patch => '+  .f.o.o.', :should => true},
          {:word => '.foo', :patch => '+  .foo.', :should => true},
          {:word => '.foo.', :patch => '+  .foo..', :should => true},
          {:word => '.foo.', :patch => '+  .foo.f', :should => true},
          {:word => '.foo.', :patch => '+  .foo', :should => false},
      ]

      tests.each do |params|
        matcher = GithubHelper::Matchers::WordMatcher.new(params[:word])
        matcher.process_file(:patch => params[:patch])

        if params[:should]
          matcher.should be_interesting
        else
          matcher.should_not be_interesting
        end
      end
    end
  end
end