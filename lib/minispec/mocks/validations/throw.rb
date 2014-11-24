class MiniSpec::Mocks::Validations
  # checks whether received message throws expected symbol
  #
  # @note  you can match against thrown symbol but not against value.
  #         this is a WONTFIX limitation. though it is doable
  #         this would introduce a new layer of unproven complexity.
  #
  # @example
  #   expect(obj).to_receive(:a).and_throw(:something)
  #
  # @example
  #   expect(obj).to_receive(:a, :b).and_throw(:A, :B)
  #   # for this to pass `obj.a` should throw :A and `obj.b` :B
  #
  def and_throw *expected, &block
    return self if @failed
    expected.all? {|x| x.is_a?(Symbol)} || raise(ArgumentError, '`and_throw` accepts only symbols')
    # `and_throw` can be called without arguments
    expected.empty? || assert_given_arguments_match_received_messages(*expected, &block)
    received = thrown_symbols

    if block
      return @base.instance_exec(*received.values, &block) ||
        throw_error!(@expected_messages, block, received)
    end

    expected = zipper(@expected_messages, expected)
    received.each_pair do |msg,calls|
      # each message should throw expected symbol at least once.
      # if no specific symbol expected, check whether any symbol thrown.
      calls.any? {|s| expected[msg] ? s == expected[msg] : s.is_a?(Symbol)} ||
        throw_error!(msg, expected[msg], msg => calls)
    end
    self
  end
  alias and_thrown  and_throw
  alias and_thrown? and_throw

  # assure received message does not throw a symbol
  #
  # @example
  #   expect(obj).to_receive(:a).without_throw
  #
  def without_throw
    return self if @failed
    thrown_symbols.each_pair do |msg,calls|
      calls.any? {|x| x.is_a?(Symbol)} && unexpected_throw_error!(msg, calls)
    end
    self
  end

  private
  def thrown_symbols
    @expected_messages.inject({}) do |map,msg|
      map.merge(msg => @messages[msg] ? @messages[msg].map {|m| extract_thrown_symbol(m[:raised])} : [])
    end
  end

  def unexpected_throw_error! message, received
    fail_with("%s received %s message(s) and thrown an unexpected symbol.\nExpected: %s\nActual:   %s" % [
      pp(@object),
      pp(message),
      'nothing to be thrown',
      stringify_thrown_symbols(message => received)
    ])
  end

  def throw_error! message, expected, received
    fail_with("%s received %s message(s) but did not throw accordingly.\nExpected: %s\nActual:   %s" % [
      pp(@object),
      pp(message),
      expected.is_a?(Proc) ?
        'results to be validated at %s' % pp(source(expected)) :
        pp(expected),
      stringify_thrown_symbols(received)
    ])
  end

  def stringify_thrown_symbols received
    received.is_a?(Hash) || raise(ArgumentError, 'a Hash expected')
    received.map do |msg,calls|
      calls.each_with_index.map do |call,i|
        '%s call #%s thrown %s' % [
          pp(msg),
          i + 1,
          call.is_a?(Symbol) ? pp(call) : 'nothing'
        ]
      end*"\n          "
    end*"\n          "
  end
end
