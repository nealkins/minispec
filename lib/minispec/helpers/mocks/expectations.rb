module Minispec

  # a helper to add expectations to objects.
  # expectations will be validated when current test evaluation finished.
  #
  # @example
  #
  #   expect(some_object).to_receive(:some_method)
  #
  # @example expecting multiple messages
  #
  #   expect(some_object).to_receive(:some, :method)
  #
  helper :receive, with_context: true do |object,*args|
    context = Hash[args.pop]
    args.any? || raise(ArgumentError, 'Please provide at least one message')

    args.size > 1 ?
      context.update(expected_messages: args) :
      context.update(expected_message:  args.first)

    expectation = MiniSpec::Mocks::Expectations.new(self, object, context, *args)
    @__ms__expectations.push(expectation)
    args.each {|m| proxy(object, m)}
    expectation
  end
  alias_helper :receive?,   :receive
  alias_helper :to_receive, :receive
end
