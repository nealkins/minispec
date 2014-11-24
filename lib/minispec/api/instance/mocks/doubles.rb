module MiniSpec
  module InstanceAPI

    # creates a double object.
    # if one or more arguments given, first argument will be used as name, unless it is a Hash.
    # arguments that goes after first one are treated as stubs.
    #
    # @example create a double that will respond to `color` and reported as :apple
    #   apple = double(:apple, :color) { 'Red' }
    #   apple.color # => Red
    #
    # @example injecting a double into a real battle and expecting it to receive some messages
    #   user = double(:user, :name, :address)
    #   expect(user).to_receive(:name, :address)
    #   Shipping.new.get_address_for(user)
    #
    # @example spy on a double
    #   user = double(:user, :name, :address)
    #   Shipping.new.get_address_for(user)
    #   assert(user).received(:name, :address)
    #
    def double *args, &proc
      name = args.first.is_a?(Hash) ? nil : args.shift

      object = Object.new
      object.define_singleton_method(:__ms__double_instance) {true}
      object.define_singleton_method(:inspect) {name} if name

      hashes, rest = args.partition {|s| s.is_a?(Hash)}
      hashes.each {|h| stub(object, h)}
      rest.each   {|s| stub(object, s, &proc)}

      object
    end
  end
end
