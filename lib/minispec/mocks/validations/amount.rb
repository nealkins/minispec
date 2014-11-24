class MiniSpec::Mocks::Validations

  # assure expected message(s) was received a specific amount of times
  #
  # @example  expect `a` to be received exactly 2 times
  #   expect(obj).to_receive(:a).count(2)
  #
  # @example  expect `a` to be received 2 or more times
  #   expect(obj).to_receive(:a).count {|a| a >= 2}
  #
  # @example  expect `a` and `b` to be received 2 times each
  #   expect(obj).to_receive(:a, :b).count(2)
  #
  # @example  expect `a` to be received 2 times and `b` 3 times
  #   expect(obj).to_receive(:a, :b).count(2, 3)
  #
  # @example  expect both `a` and `b` to be received more than 2 times
  #   expect(obj).to_receive(:a, :b).count {|a,b| a > 2 && b > 2}
  #
  def count *expected, &block
    return self if @failed
    assert_given_arguments_match_received_messages(*expected, &block)
    received = received_amounts

    if block
      return @base.instance_exec(*received.values, &block) ||
        amount_error!(@expected_messages, block, received)
    end

    expected = zipper(@expected_messages, expected)
    received.each_pair do |message,amount|
      # each message should be received expected amount of times
      amount == expected[message] ||
        amount_error!(message, expected[message], amount)
    end
    self
  end
  alias times count

  def once;  count(1); end
  def twice; count(2); end

  private
  # returns a Hash of messages each with amount of times it was called.
  # basically it does the same as `@messages.values.map(&:size)`
  # except it returns the messages in the order they are expected.
  def received_amounts
    @expected_messages.inject({}) do |map,msg|
      map.merge(msg => (@messages[msg] || []).size)
    end
  end

  def amount_error! messages, expected, received
    fail_with("%s received %s message(s) wrong amount of times.\nExpected: %s\nActual:   %s" % [
      pp(@object),
      pp(messages),
      expected.is_a?(Proc) ?
        ('to be validated at %s' % pp(source(expected))) :
        Array(expected).map {|x| pp(x)}*', ',
      pp(received)
    ])
  end
end
