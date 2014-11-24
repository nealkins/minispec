module MiniSpec
  module Mocks
    class MultipleStubsProxy
      def initialize stubs
        @stubs = stubs.freeze
      end

      def with *a, &b
        @stubs.each {|s| s.with(*a, &b)}
        self
      end

      def with_any *a, &b
        @stubs.each {|s| s.with_any(*a, &b)}
        self
      end
    end

    class Stub

      def initialize object, messages, stubs = {}
        @object, @messages, @stubs, @blocks = object, messages, stubs, {}
      end

      # makes a stub to behave differently depending on given arguments
      #
      # @example
      #   stub(a, :b).
      #     with(1) { :one }. # `a.b(1)` will return :one
      #     with(2) { :two }  # `a.b(2)` will return :two
      #
      def with *args, &block
        @blocks[args] = block || proc {}
        self
      end

      # defines a catchall block
      #
      # @example with a block
      #   stub(a, :b).
      #     with(1)  { :one }. # `a.b(1)` will return :one
      #     with_any { :any }  # `a.b(:any_args, :or_no_args)` will return :any
      #
      # @example with a value
      #   stub(a, :b).
      #     with(1) { :one }.
      #     with_any(:any)
      #
      def with_any *args, &block
        # this args mangling needed to be able to accept nil or false as value
        (value_given = args.size == 1) || args.size == 0 ||
          raise(ArgumentError, 'Wrong number of arguments, %i instead of 0..1' % args.size)
        value_given && block && raise(ArgumentError, 'Both a value and a block used. Please use either one')
        value_given || block || raise(ArgumentError, 'No value nor block provided')
        @catchall_block = value_given ? proc { args.first } : block
        self
      end
      alias any with_any

      # defines given stub of given visibility on `@object`
      #
      # @param stub
      #   - when stub is a symbol it defines a method.
      #     if `@object` has a singleton method with stub name or the stub name is :nil?,
      #     the method are defined using `define_singleton_method`.
      #     otherwise `@object` are extended with a module containing needed methods(@see #mixin)
      #   - when given stub contain dots, a chained stub defined(@see #define_chained_stub)
      #
      # @param visibility stub visibility, :public(default), :protected, :private
      # @param [Proc] &proc  block to be yielded when stub called
      # @raise ArgumentError  if given stub is not a Symbol, String, Hash or Array
      def stubify stub, visibility, &block
        stub.is_a?(Symbol) || raise('stubs names should be provided as symbols')

        @catchall_block = block if block # IMPORTANT! update catchall block only if another block given

        @object.singleton_methods.include?(stub) || stub == :nil? ?
          define_singleton_stub(stub) :
          define_regular_stub(stub, visibility)
      end

      def most_relevant_block_for args
        @blocks[args] || @catchall_block || proc {}
      end

      private
      def define_regular_stub stub, visibility
        @object.extend(mixin(stub, visibility))
        # defining a singleton if stub can not be inserted via mixin
        define_singleton_stub(stub) unless MiniSpec::Utils.method_defined?(@object, stub)
      end

      def define_singleton_stub stub
        @object.define_singleton_method(stub, &proxy(stub))
      end

      # defines a new Module that contains given stub method of given visibility
      #
      # @param stub  method to be defined
      # @param visibility  method visibility. default - public
      # @param &block  block to be yielded when method called
      # @return [Module]
      def mixin stub, visibility = nil
        method = proxy(stub)
        Module.new do
          define_method(stub, &method)
          protected stub.to_sym if visibility == :protected
          private   stub.to_sym if visibility == :private
        end
      end

      # builds a block that will be yielded when given method called.
      # when yielded,  the block will collect received messages stat.
      #
      # the block will receive original method as first argument
      # and any passed params as rest arguments.
      #
      # @param method_name
      # @param &block
      # @return [Proc]
      def proxy method_name
        method_name.is_a?(Symbol) || raise(ArgumentError, 'method name should be a Symbol')
        register_stub(method_name)
        base, object, messages, original = self, @object, @messages, original(method_name)

        Proc.new do |*args,&block|
          message = {
            object:    object,
            method:    method_name,
            arguments: args,
            caller:    Array(caller)
          }
          messages.push(message)

          method = base.most_relevant_block_for(args)

          proc = block ? Proc.new do |*a,&b|
            message[:yielded] = a
            block.call(*a, &b)
          end : nil

          begin
            message[:returned] = method.call(original, *args, &proc)
          rescue Exception => e
            message[:raised] = e
          end
          message.freeze
          message[:raised] ? raise(message[:raised]) : message[:returned]
        end
      end

      # tracking what methods was stubbed on what objects
      # so they can be unstubbed when current test evaluation finished.
      #
      # @param stub  method to be stubbed
      def register_stub stub
        stub.is_a?(Symbol) || raise(ArgumentError, 'stub should be a symbol')

        return if originals.has_key?(stub)
        if stub == :nil? || @object.singleton_methods.include?(stub)
          return originals.update(stub => [@object.method(stub), :singleton])
        end
        if visibility = MiniSpec::Utils.method_visibility(@object, stub)
          return originals.update(stub => [@object.method(stub), visibility])
        end
        originals.update(stub => [])
      end

      def originals
        @stubs[@object] ||= {}
      end

      def original method
        originals[method] && originals[method].first
      end
    end
  end
end
