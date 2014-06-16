require 'github_helper/commands/review/matchers/basic_matcher'

class GithubHelper::Commands::ReviewCommand

  class WordMatcher < BasicMatcher
    REPORT_MAX_TEXT_LENGTH = 80

    def initialize(word)
      @interesting_word = word
      @interesting_regex = get_regex_from_word(word)

      super(true)
    end

    def process_file(pull_file)
      patch = pull_file[:patch]

      return unless patch

      file_matches = []

      patch.each_line.each_with_index do |line, index|
        if %w(+ -).include?(line[0])
          line_text = line[1..-1]
          line_text.scan(@interesting_regex) do |match|
            side_text_length = (REPORT_MAX_TEXT_LENGTH - match.length) / 2

            offset = Regexp.last_match.offset(0)
            first_offset = [0, offset[0] - side_text_length].max
            last_offset = [offset[1] + side_text_length, line_text.length].min

            text = ''
            unless first_offset == 0
              text += '...'
            end
            text += line_text[first_offset..last_offset].strip
            unless last_offset == line_text.length
              text += '...'
            end

            file_matches.push(line[0] + text)
          end
        end
      end

      if file_matches.length > 0
        @matches.push(:file => pull_file[:filename], :matches => file_matches)
      end

    end

    protected

    def report_matches
      puts %Q|Word "#{@interesting_word}" was found in a pull request file|
    end

    def report_single_match(match)
      puts "#{match[:file]}"
      if @verbose > 2
        puts match[:matches].join("\n"), ''
      end
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

      Regexp.new(regex_word_str)
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