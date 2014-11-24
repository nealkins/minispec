module Minispec

  # ensure given object received expected message.
  # expectations will be validated straight away
  # so the object should be proxied before this helper used.
  #
  # @example  spying on a explicitly "proxified" method
  #   spy(obj, :a)
  #   # ...
  #   assert(obj).received(:a)
  #
  # @example  spying on a double
  #   user = double(:user, :new)
  #   # ...
  #   assert(user).received(:new)
  #
  # @note  `received` helper works exactly as `to_receive` one,
  #         that's it, all validations available for expectations
  #         will work for spies too.
  #
  # @example  ensure message received with specific arguments
  #   # ...
  #   assert(obj).received(:m).with(:x, :y)
  #
  # @example  ensure specific value returned
  #   # ...
  #   assert(obj).received(:m).and_returned(:x)
  #
  helper :received, with_context: true do |object,*args|
    context = Hash[args.pop]
    args.any? || raise(ArgumentError, 'Please provide at least one message')
    MiniSpec::Mocks::Validations.new(self, object, context, *args)
  end
  alias_helper :received?, :received

end
