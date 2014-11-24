class MiniSpec::Mocks::Validations
  class AnyYield; end

  # extending expectation by expecting received message to yield
  #
  # @example
  #   class Apple
  #
  #     def color
  #       yield
  #     end
  #
  #     def taste
  #     end
  #   end
  #
  #   describe Apple do
  #     testing :color do
  #       apple = Apple.new
  #
  #       expect(apple).to_receive(:color).and_yield # => will pass
  #       expect(apple).to_receive(:taste).and_yield # => will fail
  #     end
  #   end
  #
  # @example
  #   class Apple
  #
  #     def color
  #       yield 1, 2
  #     end
  #   end
  #
  #   describe Apple do
  #     testing :color do
  #       apple = Apple.new
  #
  #       expect(apple).to_receive(:color).and_yield(1, 2)       # => will pass
  #       expect(apple).to_receive(:taste).and_yield(:something) # => will fail
  #     end
  #   end
  #
  def and_yield *expected, &block
    return self if @failed
    # `and_yield` can be called without arguments
    expected.empty? || assert_given_arguments_match_received_messages(*expected, &block)
    received = yielded_values

    if block
      return @base.instance_exec(*received.values, &block) ||
        yield_error!(@expected_messages, block, received)
    end

    single_message_expected? ?
      validate_yields(expected, received) :
      validate_yields_list(expected, received)
    self
  end
  alias and_yielded  and_yield
  alias and_yielded? and_yield

  # make sure received message wont yield
  #
  # @example
  #   expect(:obj).to_receive(:a).without_yield
  #
  def without_yield
    return self if @failed
    yielded_values.each_pair do |msg,calls|
      next if calls.all?(&:nil?)
      unexpected_yield_error!(msg, calls)
    end
    self
  end

  private
  def yielded_values
    @expected_messages.inject({}) do |map,msg|
      map.merge(msg => @messages[msg] ? @messages[msg].map {|m| m[:yielded]} : [])
    end
  end

  def validate_yields expected, received
    message = @expected_messages[0]
    calls   = received[message]
    return if validate_yields_calls(calls, expected)
    yield_error!(message, expected, message => calls)
  end

  def validate_yields_list expected, received
    expected = zipper(@expected_messages, expected)
    received.each_pair do |msg,calls|
      expect = Array(expected[msg]).flatten(1)
      next if validate_yields_calls(calls, expect)
      yield_error!(msg, expect, msg => calls)
    end
  end

  def validate_yields_calls calls, expected
    expected.nil? || expected.empty?  ?
      calls.any? {|c| c.is_a?(Array)} :
      calls.any? {|c| c == expected}
  end

  def unexpected_yield_error! message, received
    fail_with("%s received %s message and unexpectedly yielded.\nExpected: %s\nActual:   %s" % [
      pp(@object),
      pp(message),
      'nothing to be yielded',
      stringify_received_yields(message => received)
    ])
  end

  def yield_error! message, expected, received
    fail_with("%s received %s message(s) but did not yield accordingly.\nExpected: %s\nActual:   %s" % [
      pp(@object),
      pp(message),
      stringify_expected_yields(expected),
      stringify_received_yields(received)
    ])
  end

  def stringify_expected_yields expected
    return 'yielded values to pass validation at %s' % pp(source(expected)) if expected.is_a?(Proc)
    return 'something to be yielded' if expected.empty?
    pp(expected)
  end

  def stringify_received_yields received
    received.is_a?(Hash) || raise(ArgumentError, 'a Hash expected')
    received.map do |msg,calls|
      calls.each_with_index.map do |call,i|
        '%s call #%s yielded %s' % [
          pp(msg),
          i + 1,
          call ? pp(call) : 'nothing'
        ]
      end*"\n          "
    end*"\n          "
  end
end
