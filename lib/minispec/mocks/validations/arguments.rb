class MiniSpec::Mocks::Validations

  # validates received arguments against expected ones
  #
  # @example
  #   expect(obj).to_receive(:a).with(1)
  #   obj.a(1)
  #
  # @example
  #   expect(obj).to_receive(:a).with(1, 2)
  #   obj.a(1, 2)
  #
  # @example
  #   expect(obj).to_receive(:a).with(1, [:a, :b, :c])
  #   obj.a(1, [:a, :b, :c])
  #
  # @example
  #   expect(obj).to_receive(:a).with {|x| x[0] == [1, 2, 3] && x[1] == [:x, [:y], 'z']}
  #   obj.a(1, 2, 3)
  #   obj.a(:x, [:y], 'z')
  #
  # @example
  #   expect(obj).to_receive(:a, :b, :c).with(1)
  #   obj.a(1)
  #   obj.b(1)
  #   obj.c(1)
  #
  # @example
  #   expect(obj).to_receive(:a, :b, :c).with(1, 2, 3)
  #   obj.a(1)
  #   obj.b(2)
  #   obj.c(3)
  #
  # @example
  #   expect(obj).to_receive(:a, :b, :c).with([1, 2, 3])
  #   obj.a(1, 2, 3)
  #   obj.b(1, 2, 3)
  #   obj.c(1, 2, 3)
  #
  # @example
  #   expect(obj).to_receive(:a, :b, :c).with([1, 2], [:x, :y], :z)
  #   obj.a(1, 2)
  #   obj.b(:x, :y)
  #   obj.c(:z)
  #
  # @example
  #   expect(obj).to_receive(:a, :b, :c).with([[1, 2]], [[:x, :y]], [:z])
  #   obj.a([1, 2])
  #   obj.b([:x, :y])
  #   obj.c([:z])
  #
  # @example
  #   expect(obj).to_receive(:a, :b, :c).with do |a,b,c|
  #     a == [[1, 2]] &&
  #       b == [[:x, :y]] &&
  #       c == [:z]
  #   end
  #   obj.a(1, 2)
  #   obj.b(:x, :y)
  #   obj.c(:z)
  #
  # @example
  #   expect(obj).to_receive(:a, :b, :c).with do |a,b,c|
  #     a == [[1, 2], [3, 4]] &&
  #       b == [[:x, :y], [2]] &&
  #       c == [[:z], [[:a, :b], :c]]
  #   end
  #   obj.a(1, 2)
  #   obj.a(3, 4)
  #   obj.b(:x, :y)
  #   obj.b(2)
  #   obj.c(:z)
  #   obj.c([:a, :b], :c)
  #
  def with *expected, &block
    return self if @failed
    assert_given_arguments_match_received_messages(*expected, &block)
    received = received_arguments

    if block
      return @base.instance_exec(*received.values, &block) ||
        arguments_error!(@expected_messages, block, received)
    end

    single_message_expected? ?
      validate_arguments(expected, received) :
      validate_arguments_list(expected, received)
    self
  end

  def without_arguments
    return self if @failed
    received_arguments.each_pair do |msg,args|
      # each message should be called without arguments at least once
      args.any?(&:empty?) || arguments_error!(msg, [], msg => args)
    end
    self
  end
  alias without_any_arguments without_arguments

  private
  # returns a Hash of received messages,
  # each with a list of arguments it was called with.
  #
  # @example
  #   obj.a(:x)
  #   obj.a([:x])
  #   obj.a(:y, [:z])
  #   => { a: [ [:x], [[:x]], [:y, [:z]] ] }
  #
  def received_arguments
    @expected_messages.inject({}) do |map,msg|
      map.merge(msg => @messages[msg] ? @messages[msg].map {|m| m[:arguments]} : [])
    end
  end

  def validate_arguments expected, received
    message   = @expected_messages[0]
    arguments = received[message]
    return if arguments.any? {|x| x == expected}
    arguments_error!(message, expected, message => arguments)
  end

  def validate_arguments_list expected, received
    expected = zipper(@expected_messages, expected)
    received.each_pair do |msg,args|
      next if args.any? {|x| x == [expected[msg]]}
      arguments_error!(msg, expected[msg], msg => args)
    end
  end

  def stringify_expected_arguments expected
    return 'to be validated at %s' % pp(source(expected)) if expected.is_a?(Proc)
    expected = Array(expected)
    return 'to be called without arguments' if expected.empty?
    expected.map {|a| pp(a)}*', '
  end

  def stringify_received_arguments received
    received.is_a?(Hash) || raise(ArgumentError, 'expected a Hash')
    received.map do |msg,args|
      '%s called %s' % [
        pp(msg),
        args.map do |arr|
          arr.empty? ?
            'without arguments' :
            'with %s' % arr.map {|a| pp(a)}.join(', ')
        end*' then '
      ]
    end*"\n          "
  end

  def arguments_error! message, expected, received
    fail_with("%s received %s message(s) with unexpected arguments.\nExpected: %s\nActual:   %s" % [
      pp(@object),
      pp(message),
      stringify_expected_arguments(expected),
      stringify_received_arguments(received)
    ])
  end
end
