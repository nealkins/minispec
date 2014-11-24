module MiniSpec
  module Mocks
    class Validations
      include MiniSpec::Utils

      def initialize base, object, context, *expected_messages
        expected_messages.empty? && raise(ArgumentError, 'Wrong number of arguments (3 for 4+)')
        expected_messages.all? {|m| m.is_a?(Symbol)} || raise(ArgumentError, 'Only symbols accepted')
        @base, @object, @context, @failed = base, object, context, false
        @expected_messages = expected_messages.freeze
        @messages = expected_and_received.freeze
        validate_received_messages!
      end

      private
      # selecting only expected messages in the order they was received.
      # @param expected_messages [Array]
      # @return [Hash]
      def expected_and_received
        @base.__ms__mocks__instance_messages(@context[:left_object]).inject({}) do |map,msg|
          @expected_messages.include?(msg[:method]) && (map[msg[:method]] ||= []).push(msg)
          map
        end
      end

      def validate_received_messages!
        @expected_messages.each do |m|
          @context[:negation] ?
            @messages.keys.include?(m) && message_validation_error!(m, true) :
            @messages.keys.include?(m) || message_validation_error!(m)
        end
      end

      def message_validation_error! message, negation = false
        fail_with('%sExpected %s to receive %s message' % [
          negation ? 'NOT ' : '',
          pp(@object),
          pp(message),
        ])
      end

      def single_message_expected?
        @expected_messages.size == 1
      end

      # checks whether correct number of arguments given.
      # in any situation, at least one argument required.
      # if multiple messages expected, number of arguments should be equal to one
      # or to the number of expected messages.
      def assert_given_arguments_match_received_messages *args, &block
        if block
          args.empty? || raise(ArgumentError, 'Both arguments and block given. Please use either one.')
          return true # if block given, no arguments accepted, so nothing to validate
        end

        # single argument acceptable for any number of expected messages
        return if args.size == 1

        # when a single message expected, any number of arguments accepted
        return if @expected_messages.size == 1

        # on multiple messages, number of arguments should match number of expected messages
        return if args.size == @expected_messages.size

        raise(ArgumentError, 'wrong number of arguments (%i for 1..%i)' % [
          args.size,
          @expected_messages.size
        ], caller[1..-1])
      end

      def fail_with message
        return unless @failed = message
        @base.fail(message)
        self
      end
    end
  end
end

Dir[File.expand_path('../validations/**/*.rb', __FILE__)].each {|f| require(f)}
