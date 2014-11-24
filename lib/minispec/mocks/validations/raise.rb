class MiniSpec::Mocks::Validations

  # expect received message(s) to raise a exception.
  #
  # if no args given any raised exception accepted.
  # if a class given it checks whether raised exception is of given type.
  # if a string or regexp given it checks whether raised message matches it.
  #
  # @example  expect `a` to raise something
  #   expect(obj).to_receive(:a).and_raise
  #
  # @example  expect `a` to raise ArgumentError
  #   expect(obj).to_receive(:a).and_raise(ArgumentError)
  #
  # @example  raised exception should be of ArgumentError type and match /something/
  #   expect(obj).to_receive(:a).and_raise([ArgumentError, /something/])
  #
  # @example  expect `a` to raise ArgumentError and `b` to raise RuntimeError
  #   expect(obj).to_receive(:a, :b).and_raise(ArgumentError, RuntimeError)
  #
  # @example  expect `a` to raise ArgumentError matching /something/ and `b` to raise RuntimeError
  #   expect(obj).to_receive(:a, :b).and_raise([ArgumentError, /something/], RuntimeError)
  #
  def and_raise *expected, &block
    return self if @failed
    # `and_raise` can be called without arguments
    expected.empty? || assert_given_arguments_match_received_messages(*expected, &block)
    received = raised_exceptions

    if block
      return @base.instance_exec(*received.values, &block) ||
        exception_error!(@expected_messages, block, received)
    end

    expected = single_message_expected?   ?
      {@expected_messages[0] => expected} :
      zipper(@expected_messages, expected)
    context  = @context.merge(negation: nil, right_proc: nil) # do NOT alter @context
    received.each_pair do |msg,calls|
      # each message should raise as expected at least once
      calls.any? {|c| exception_raised?(c, context, *expected[msg]) == true} ||
        exception_error!(msg, expected[msg], msg => calls)
    end
    self
  end
  alias and_raised  and_raise
  alias and_raised? and_raise

  # make sure received message(s) does not raise any exception
  #
  # @example
  #   expect(obj).to_receive(:a).without_raise
  #
  def without_raise
    return self if @failed
    raised_exceptions.each_pair do |msg,calls|
      calls.any? {|r| r.is_a?(Exception)} && unexpected_exception_error!(msg, calls)
    end
    self
  end

  private
  def raised_exceptions
    @expected_messages.inject({}) do |map,msg|
      map.merge(msg => @messages[msg] ? @messages[msg].map {|m| m[:raised]} : [])
    end
  end

  def unexpected_exception_error! message, received
    fail_with("%s received %s message and raised an unexpected error.\nExpected: %s\nActual:   %s" % [
      pp(@object),
      pp(message),
      'nothing to be raised',
      stringify_received_exception(message => received)
    ])
  end

  def exception_error! message, expected, received
    fail_with("%s received %s message(s) but did not raise accordingly.\nExpected: %s\nActual:   %s" % [
      pp(@object),
      pp(message),
      stringify_expected_exception(expected),
      stringify_received_exception(received)
    ])
  end

  def stringify_expected_exception expected
    return 'any exception to be raised' unless expected
    return 'raised exception to be validated at %s' % pp(source(expected)) if expected.is_a?(Proc)
    Array(expected).map(&method(:pp))*':'
  end

  def stringify_received_exception received
    received.is_a?(Hash) || raise(ArgumentError, 'a Hash expected')
    received.map do |msg,calls|
      calls.each_with_index.map do |call,i|
        '%s call #%s raised %s' % [
          pp(msg),
          i + 1,
          call.is_a?(Exception) ?
            stringify_exception(call) :
            'nothing'
        ]
      end*"\n          "
    end*"\n          "
  end

  def stringify_exception exception
    [exception.class, exception.message].map(&method(:pp))*':'
  end
end
