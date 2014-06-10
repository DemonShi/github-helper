require 'github_helper/commands/review/matchers/basic_matcher'

module GithubHelper::Commands::Review::Matcher

  class WordMatcher < BasicMatcher
    def initialize(word)
      @interesting_word = word
      @interesting_regex = get_regex_from_word(word)

      super(true)
    end

    def process_file(pull_file)
      patch = pull_file[:patch]

      return unless patch

      patch.each_line.each_with_index do |line, index|
        if %w(+ -).include?(line[0]) && @interesting_regex.match(line)
          @matches.push(:file => pull_file[:filename], :line => index)
        end
      end
    end

    protected

    def report_matches
      puts 'Word "' + @interesting_word + '" was found in a pull request file'
    end

    private
    NON_WORD_CHARS = []

    def get_regex_from_word(word)
      regex_word_str = ''

      unless NON_WORD_CHARS.include?(word[0])
        regex_word_str += '\b'
      end

      regex_word_str += '(' + Regexp.escape(word) + ')'

      unless NON_WORD_CHARS.include?(word[-1])
        regex_word_str += '\b'
      end

      Regexp.new('^.*' + regex_word_str + '.*$')
    end

    begin
      WORD_CHARS_REGEX = /[A-Za-z0-9_$]/
      TEXT_CHAR_CODE_RANGES = [9..13, 32..127]

      TEXT_CHAR_CODE_RANGES.each do |range|
        range.each do |code|
          unless WORD_CHARS_REGEX.match(code.chr)
            NON_WORD_CHARS << code.chr
          end
        end
      end
    end

  end

end