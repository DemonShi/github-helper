module GithubHelper
  # Basic error for all other GithubHelper errors
  class Error < RuntimeError
  end

  class CommandLineError < GithubHelper::Error
  end
end