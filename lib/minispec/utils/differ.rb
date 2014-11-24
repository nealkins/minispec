# borrowed from RSpec - https://github.com/rspec/rspec-support

# Copyright (c) 2013 David Chelimsky, Myron Marston, Jon Rowe, Sam Phippen, Xavier Shay, Bradley Schaefer
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module MiniSpec
  class Differ
    class EncodedString

      MRI_UNICODE_UNKNOWN_CHARACTER = "\xEF\xBF\xBD".freeze

      def initialize(string, encoding = nil)
        @encoding = encoding
        @source_encoding = detect_source_encoding(string)
        @string = matching_encoding(string)
      end
      attr_reader :source_encoding

      delegated_methods = String.instance_methods.map(&:to_s) & %w[eql? lines == encoding empty?]
      delegated_methods.each do |name|
        define_method(name) { |*args, &block| @string.__send__(name, *args, &block) }
      end

      def <<(string)
        @string << matching_encoding(string)
      end

      def split(regex_or_string)
        @string.split(matching_encoding(regex_or_string))
      end

      def to_s
        @string
      end
      alias :to_str :to_s

      private

      if String.method_defined?(:encoding)
        def matching_encoding(string)
          string.encode(@encoding)
        rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
          normalize_missing(string.encode(@encoding, :invalid => :replace, :undef => :replace))
        rescue Encoding::ConverterNotFoundError
          normalize_missing(string.force_encoding(@encoding).encode(:invalid => :replace))
        end

        def normalize_missing(string)
          if @encoding.to_s == "UTF-8"
            string.gsub(MRI_UNICODE_UNKNOWN_CHARACTER.force_encoding(@encoding), "?")
          else
            string
          end
        end

        def detect_source_encoding(string)
          string.encoding
        end
      else
        def matching_encoding(string)
          string
        end

        def detect_source_encoding(string)
          'US-ASCII'
        end
      end
    end

    class HunkGenerator
      def initialize(actual, expected)
        @actual = actual
        @expected = expected
      end

      def hunks
        @file_length_difference = 0
        @hunks ||= diffs.map do |piece|
          build_hunk(piece)
        end
      end

      private

      def diffs
        Diff::LCS.diff(expected_lines, actual_lines)
      end

      def expected_lines
        @expected.split("\n").map! { |e| e.chomp }
      end

      def actual_lines
        @actual.split("\n").map! { |e| e.chomp }
      end

      def build_hunk(piece)
        Diff::LCS::Hunk.new(
          expected_lines, actual_lines, piece, context_lines, @file_length_difference
        ).tap do |h|
          @file_length_difference = h.file_length_difference
        end
      end

      def context_lines
        3
      end
    end

    def diff(actual, expected)
      diff = ""

      if actual && expected
        if all_strings?(actual, expected)
          if any_multiline_strings?(actual, expected)
            diff = diff_as_string(coerce_to_string(actual), coerce_to_string(expected))
          end
        elsif no_procs?(actual, expected) && no_numbers?(actual, expected)
          diff = diff_as_object(actual, expected)
        end
      end

      diff.to_s
    end

    def diff_as_string(actual, expected)
      @encoding = pick_encoding actual, expected

      @actual   = EncodedString.new(actual, @encoding)
      @expected = EncodedString.new(expected, @encoding)

      output = EncodedString.new("\n", @encoding)

      hunks.each_cons(2) do |prev_hunk, current_hunk|
        begin
          if current_hunk.overlaps?(prev_hunk)
            add_old_hunk_to_hunk(current_hunk, prev_hunk)
          else
            add_to_output(output, prev_hunk.diff(format).to_s)
          end
        ensure
          add_to_output(output, "\n")
        end
      end

      if hunks.last
        finalize_output(output, hunks.last.diff(format).to_s)
      end

      color_diff output
    rescue Encoding::CompatibilityError
      handle_encoding_errors
    end

    def diff_as_object(actual, expected)
      actual_as_string = object_to_string(actual)
      expected_as_string = object_to_string(expected)
      diff_as_string(actual_as_string, expected_as_string)
    end

    attr_reader :color
    alias_method :color?, :color

    def initialize(opts={})
      @color = opts.fetch(:color, false)
      @object_preparer = opts.fetch(:object_preparer, lambda { |string| string })
    end

    private

    def no_procs?(*args)
      args.flatten.none? { |a| Proc === a}
    end

    def all_strings?(*args)
      args.flatten.all? { |a| String === a}
    end

    def any_multiline_strings?(*args)
      all_strings?(*args) && args.flatten.any? { |a| multiline?(a) }
    end

    def no_numbers?(*args)
      args.flatten.none? { |a| Numeric === a}
    end

    def coerce_to_string(string_or_array)
      return string_or_array unless Array === string_or_array
      diffably_stringify(string_or_array).join("\n")
    end

    def diffably_stringify(array)
      array.map do |entry|
        if Array === entry
          entry.inspect
        else
          entry.to_s.gsub("\n", "\\n")
        end
      end
    end

    if String.method_defined?(:encoding)
      def multiline?(string)
        string.include?("\n".encode(string.encoding))
      end
    else
      def multiline?(string)
        string.include?("\n")
      end
    end

    def hunks
      @hunks ||= HunkGenerator.new(@actual, @expected).hunks
    end

    def finalize_output(output, final_line)
      add_to_output(output, final_line)
      add_to_output(output, "\n")
    end

    def add_to_output(output, string)
      output << string
    end

    def add_old_hunk_to_hunk(hunk, oldhunk)
      hunk.merge(oldhunk)
    end

    def format
      :unified
    end

    def color(text, color_code)
      "\e[#{color_code}m#{text}\e[0m"
    end

    def red(text)
      color(text, 31)
    end

    def green(text)
      color(text, 32)
    end

    def blue(text)
      color(text, 34)
    end

    def normal(text)
      color(text, 0)
    end

    def color_diff(diff)
      return diff unless color?

      diff.lines.map { |line|
        case line[0].chr
        when "+"
          green line
        when "-"
          red line
        when "@"
          line[1].chr == "@" ? blue(line) : normal(line)
        else
          normal(line)
        end
      }.join
    end

    def object_to_string(object)
      object = @object_preparer.call(object)
      case object
      when Hash
        object.keys.sort_by { |k| k.to_s }.map do |key|
          pp_key   = PP.singleline_pp(key, "")
          pp_value = PP.singleline_pp(object[key], "")

          "#{pp_key} => #{pp_value},"
        end.join("\n")
      when String
        object =~ /\n/ ? object : object.inspect
      else
        PP.pp(object,"")
      end
    end

    if String.method_defined?(:encoding)
      def pick_encoding(source_a, source_b)
        Encoding.compatible?(source_a, source_b) || Encoding.default_external
      end
    else
      def pick_encoding(source_a, source_b)
      end
    end

    def handle_encoding_errors
      if @actual.source_encoding != @expected.source_encoding
        "Could not produce a diff because the encoding of the actual string (#{@actual.source_encoding}) "+
          "differs from the encoding of the expected string (#{@expected.source_encoding})"
      else
        "Could not produce a diff because of the encoding of the string (#{@expected.source_encoding})"
      end
    end
  end
end
