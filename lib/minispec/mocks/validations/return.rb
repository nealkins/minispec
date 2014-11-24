class MiniSpec::Mocks::Validations

  # extending expectation by expecting a specific returned value
  #
  # @example
  #   expect(obj).to_receive(:a).and_return(1)
  #   # for this to pass `obj.a` should return 1
  #
  # @example
  #   expect(obj).to_receive(:a, :b).and_return(1, 2)
  #   # for this to pass `obj.a` should return 1 and `obj.b` should return 2
  #
  # @example using a block to validate returned value
  #   expect(obj).to_receive(:a).and_return {|v| v == 1}
  #   # for this to pass `obj.a` should return 1
  #
  def and_return *expected, &block
    return self if @failed
    assert_given_arguments_match_received_messages(*expected, &block)
    received = returned_values

    if block
      return @base.instance_exec(*received.values, &block) ||
        returned_value_error!(@expected_messages, block, received)
    end

    expected = zipper(@expected_messages, expected)
    received.each_pair do |msg,values|
      # each message should return expected value at least once
      values.any? {|v| validate_returned_value(expected[msg], v)} ||
        returned_value_error!(msg, expected[msg], msg => values)
    end
    self
  end
  alias and_returned and_return

  private
  def returned_values
    @expected_messages.inject({}) do |map,msg|
      map.merge(msg => @messages[msg] ? @messages[msg].map {|m| m[:returned]} : [])
    end
  end

  def validate_returned_value expected, returned
    if expected.is_a?(Regexp)
      return returned.is_a?(Regexp) ? expected == returned : returned.to_s =~ expected
    end
    expected == returned
  end

  def returned_value_error! message, expected, received
    fail_with("%s received %s message(s) and returned unexpected value(s).\nExpected: %s\nActual:   %s" % [
      pp(@object),
      pp(message),
      expected.is_a?(Proc) ?
        'to pass validation at %s' % pp(source(expected)) :
        pp(expected),
      stringify_returned_values(received)
    ])
  end

  def stringify_returned_values returned
    returned.is_a?(Hash) || raise(ArgumentError, 'a Hash expected')
    returned.map do |msg,values|
      values.each_with_index.map do |value,i|
        '%s call #%s returned %s' % [
          pp(msg),
          i + 1,
          pp(value)
        ]
      end*"\n          "
    end*"\n          "
  end
end
