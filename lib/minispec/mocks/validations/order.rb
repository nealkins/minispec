class MiniSpec::Mocks::Validations

  # checks whether expected messages was received in a specific order
  #
  # @note  this method will work only when multiple messages expected.
  #   that's it, unlike RSpec, it wont work like this:
  #   `expect(obj).to_receive(:a).ordered`
  #   `expect(obj).to_receive(:b).ordered`
  #
  #   instead it will work like this:
  #   `expect(obj).to_receive(:a, :b).ordered`
  #
  # @example
  #   expect(obj).to_receive(:a, :b, :c).ordered
  #
  # @example  expect for same sequence N times
  #   expect(obj).to_receive(:a, :b).ordered(2)
  #   # for this to pass `obj.a` and `obj.b` should be both called twice in same order
  #
  def ordered n = 1, &block
    block                    && raise(ArgumentError, '#ordered does not accept a block')
    n.is_a?(Integer)         || raise(ArgumentError, '#ordered expects a single Integer argument')
    single_message_expected? && raise(ArgumentError, '#ordered works only with multiple messages')
    received_in_expected_order?(n)
  end

  private
  def received_in_expected_order? n
    x = 0
    messages_in_received_order.each_cons(@expected_messages.size) {|c| x += 1 if c == @expected_messages}
    x == n || ordered_error!(n, x)
  end

  # returns an Array of all messages in the order they was received
  def messages_in_received_order
    @base.__ms__mocks__instance_messages(@context[:left_object]).map {|m| m[:method]}
  end

  def ordered_error! expected, received
    fail_with("Expected %s to receive %s sequence %s times.\nInstead it was received %s times." % [
      pp(@object),
      pp(@expected_messages),
      expected,
      received
    ])
  end
end
