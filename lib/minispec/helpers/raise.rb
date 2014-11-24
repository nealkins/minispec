module Minispec

  # checks whether given block raises an exception
  #
  # @example
  #   describe :Exceptions do
  #     let(:something_bad) { raise Something, 'bad' }
  #
  #     should 'raise something bad' do
  #       does { something_bad }.raise? Something, 'bad'
  #     end
  #   end
  #
  helper :raise, with_context: true do |obj, *rest|
    context = Hash[rest.pop]

    # if a block passed to helper, it will be received as last but one argument,
    # just before context, so popping it out cause we will consume it from context.
    # normally we would pass no arguments if right block given,
    # but we need to pass them cause arguments validation happens next in the stream
    # and validator needs all data provided by user
    context[:right_proc] && rest.pop

    subject = begin
      obj.is_a?(Proc) ? self.instance_exec(&obj) : obj
    rescue Exception => e
      e
    end

    result = MiniSpec::Utils.exception_raised?(subject, context, *rest, &context[:right_proc])
    result.is_a?(MiniSpec::ExceptionError) && fail(result.message)
    subject
  end
  alias_helper :raise?,             :raise
  alias_helper :raises,             :raise
  alias_helper :raises?,            :raise
  alias_helper :raise_error,        :raise
  alias_helper :raise_error?,       :raise
  alias_helper :raise_exception,    :raise
  alias_helper :raise_exception?,   :raise
  alias_helper :to_raise,           :raise
  alias_helper :to_raise_error,     :raise
  alias_helper :to_raise_exception, :raise
end
