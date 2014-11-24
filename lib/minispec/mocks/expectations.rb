module MiniSpec
  module Mocks
    class Expectations

      def initialize base, object, context, *args
        @base, @object, @context, @args = base, object, context, args
        @expectations = []
      end

      def validate!
        validator = Validations.new(@base, @object, @context, *@args)
        @expectations.each {|e| e.call(validator)}
      end

      def with *args, &proc
        push {|v| proc ? v.with(&proc) : v.with(*args)}
      end

      def without_arguments
        push {|v| v.without_arguments}
      end
      alias without_any_arguments without_arguments

      def with_caller *args, &proc
        push {|v| proc ? v.with_caller(&proc) : v.with_caller(*args)}
      end

      def and_return *args, &proc
        push {|v| proc ? v.and_return(&proc) : v.and_return(*args)}
      end
      alias and_returned and_return

      def and_yield *args, &proc
        push {|v| proc ? v.and_yield(&proc) : v.and_yield(*args)}
      end

      def without_yield
        push {|v| v.without_yield}
      end

      def and_raise *args, &proc
        push {|v| v.and_raise(*args, &proc)}
      end

      def without_raise
        push {|v| v.without_raise}
      end

      def and_throw *args, &proc
        push {|v| v.and_throw(*args, &proc)}
      end

      def without_throw
        push {|v| v.without_throw}
      end

      def count *expected, &proc
        push {|v| proc ? v.count(&proc) : v.count(*expected)}
      end
      alias times count

      def once;  count(1); end
      def twice; count(2); end

      def ordered n = 1
        push {|v| v.ordered(n)}
      end

      private
      def push &proc
        @expectations << proc
        self
      end

    end
  end
end
