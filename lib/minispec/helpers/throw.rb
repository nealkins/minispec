module Minispec

  # checks whether given block throws a symbol
  #
  # @example
  #   does { something }.throw? :some_symbol
  #   does { something }.throw? :some_symbol, 'with some value'
  #   does { something }.throw? :some_symbol, /with some value/
  helper :throw, with_context: true do |obj, *rest|
    context = Hash[rest.pop]

    # if a block passed to helper, it will be received as last but one argument,
    # just before context, so popping it out cause we will consume it from context.
    # normally we would pass no arguments if right block given,
    # but we need to pass them cause arguments validation happens next in the stream
    # and validator needs all data provided by user
    context[:right_proc] && rest.pop

    expected_symbol, expected_value = rest
    obj.is_a?(Proc) || raise(ArgumentError, '`throw` helper works only with blocks')
    status = MiniSpec::Utils.symbol_thrown?(expected_symbol, expected_value, context, &obj)
    status.is_a?(MiniSpec::ThrowError) && fail(status.message)
  end
  alias_helper :throw?,          :throw
  alias_helper :throw_symbol,    :throw
  alias_helper :throw_symbol?,   :throw
  alias_helper :to_throw,        :throw
  alias_helper :to_throw_symbol, :throw
end
