class MinispecTest
  class Stubs < self
    class Unit
      include Minispec
      continue_on_failures true

      def restore_originals
        __ms__mocks__restore_originals
      end

      let(:o) { Object.new }

      it 'creates stubs' do
        stub(o, :a)
        does(o).respond_to?(:a)
      end

      it 'uses hash value as return value' do
        stub(o, a: :x, b: :y)
        does(o).respond_to?(:a)
        is(o.a) == :x
        does(o).respond_to?(:b)
        is(o.b) == :y
      end

      it 'raise ArgumentError when using constraints on Hash stubs' do
        does { stub(o, a: :b).with(1) {1} }.raise?(ArgumentError, /can not be used/i)
        # though error raised, methods should be successfully stubbed
        assert(o.a) == :b
      end

      it 'calls given block' do
        stub(o, :a) {:x}
        does(o).respond_to?(:a)
        is(o.a) == :x
      end

      it 'calls the block associated with given args' do
        stub(o, :a).with(1, 2) {:ot}
        is(o.a(1, 2)) == :ot

        stub(o, :a).with(4, 5) {:ff}
        is(o.a(4, 5)) == :ff

        stub(o, :a).with(:x) {:x}
        is(o.a(:x))   == :x
      end

      it 'calls the main block if no block associated with given args' do
        stub(o, :a) {:main}
        stub(o, :a).with(1) {1}
        is(o.a) == :main
        is(o.a(1)) == 1
        is(o.a(2)) == :main
      end

      it 'returns nil if no main block nor block associated with given args' do
        o = Class.new do
          def a; :a; end
        end.new
        stub(o, :a).with(1) {1}
        is(o.a(1)) == 1
        is(o.a).nil?
      end

      it 'returns nil if no main block nor block associated with given args nor original defined' do
        stub(o, :a)
        is(o.a).nil?
      end

      it 'pass original as first argument' do
        o = Class.new do
          attr_reader :original_called
          def a; @original_called = true; end
        end.new
        stub(o, :a) do |original|
          is(o.original_called).nil?
          original.call
          is(o.original_called).true?
        end
        o.a
      end

      it 'pass args alongside original' do
        o = Class.new do
          attr_reader :original_called
          def a; @original_called = true; end
        end.new
        stub(o, :a).with(1, 2) do |original, *args|
          is(o.original_called).nil?
          assert(args) == [1, 2]
          original.call
          is(o.original_called).true?
        end
        o.a(1, 2)
      end

      it 'pass given block alongside original and args' do
        args = nil
        o = Class.new do
          def a(*a); yield(*a); end
        end.new
        stub(o, :a).with(1, 2) do |original, *a, &p|
          original.call(*a, &p)
        end
        o.a(1, 2) {|*a| args = a}
        assert(args) == [1, 2]
      end

      it 'creates public stubs' do
        stub(o, :a)
        does(o.public_methods).include?(:a)
      end

      it 'creates private stubs' do
        private_stub(o, :a)
        does(o.private_methods).include?(:a)
        does { o.a }.raise? NoMethodError, /private method\W+a/
      end

      it 'creates private stubs with a Hash' do
        private_stub(o, :a => :b)
        assert(o.send(:a)) == :b
      end

      it 'creates private stubs with a block' do
        private_stub(o, :a) {:b}
        assert(o.send(:a)) == :b
      end

      it 'adds arguments constraints on private stubs' do
        private_stub(o, :a).
          with(1) {:one}.
          with_any(:any)
        assert(o.send(:a)) == :any
        assert(o.send(:a, :blah)) == :any
        assert(o.send(:a, 1)) == :one
      end

      it 'creates protected stubs' do
        protected_stub(o, :a)
        does(o.protected_methods).include?(:a)
        does { o.a }.raise? NoMethodError, /protected method\W+a/
      end

      it 'creates protected stubs with a Hash' do
        protected_stub(o, :a => :b)
        assert(o.send(:a)) == :b
      end

      it 'creates protected stubs with a block' do
        protected_stub(o, :a) {:b}
        assert(o.send(:a)) == :b
      end

      it 'adds arguments constraints on protected stubs' do
        protected_stub(o, :a).
          with(1) {:one}.
          with_any(:any)
        assert(o.send(:a)) == :any
        assert(o.send(:a, :blah)) == :any
        assert(o.send(:a, 1)) == :one
      end

      if RUBY_VERSION.to_f >= 2
        it 'keeps the visibility of existing methods' do
          o = Class.new do
            def a; end
            protected
            def b; end
            private
            def c; end
          end.new

          stub(o, :a)
          does(o.public_methods).include?(:a)

          stub(o, :b)
          does(o.protected_methods).include?(:b)

          stub(o, :c)
          does(o.private_methods).include?(:c)
        end
      end

      it 'enforces public visibility on protected methods' do
        o = Class.new do
          protected
          def a; end
        end.new
        does { o.a }.raise? NoMethodError, /protected method\W+a/
        public_stub(o, :a) { :a }
        assert(o.a) == :a
      end

      it 'enforces public visibility on private methods' do
        o = Class.new do
          private
          def a; end
        end.new
        does { o.a }.raise? NoMethodError, /private method\W+a/
        public_stub(o, :a) { :a }
        assert(o.a) == :a
      end

      it 'stub :nil? method' do
        o = nil
        is(o.nil?) == true
        stub(o, :nil?) { :blah }
        is(o.nil?) == :blah
      end

      it 'defines chained stubs' do
        @a = nil
        stub(o, 'a.b.c') {|*a| @a = true; a}

        does(o).respond_to?(:a)
        o.a
        is(@a).nil?

        does(o.a).respond_to?(:b)
        o.a.b
        is(@a).nil?

        does(o.a.b).respond_to?(:c)
        expect(o.a.b.c(:x, :y)).to_contain :x, :y
        is(@a).true?
      end

      it 'defines chained stubs with a Hash' do
        stub(o, 'a.b.c' => 1, 'x.y.z' => 2)

        does(o).respond_to?(:a)
        does(o.a).respond_to?(:b)
        does(o.a.b).respond_to?(:c)
        assert(o.a.b.c) == 1

        does(o).respond_to?(:x)
        does(o.x).respond_to?(:y)
        does(o.x.y).respond_to?(:z)
        assert(o.x.y.z) == 2
      end

      test 'chained stubs works with arguments filters' do
        stub(o, 'a.b').
          with(1) {:one}.
          with(2) {:two}.
          with_any(:any)
        assert(o.a.b) == :any
        assert(o.a.b(:bl, :ah)) == :any
        assert(o.a.b(1)) == :one
        assert(o.a.b(2)) == :two
      end

      it 'passes the given block with last method in the chain' do
        stub(o, 'b.c') {|&b| b.call(2)}
        assert(o.b.c {|y| y ** 2}) == 4
      end

      it 'adds expectations on chained stubs' do
        stub(o, 'a.b.c')
        expect(o).to_receive(:a)
        expect(o.a).to_receive(:b)
        expect(o.a.b).to_receive(:c)
        o.a.b.c
      end

      it 'restore stubbed singleton methods' do
        o.define_singleton_method(:a) {:a}
        stub(o, :a) {:b}
        is(o.a) == :b
        restore_originals
        is(o.a) == :a
      end

      it 'restore stubbed public methods' do
        o = Class.new do
          def a; :a; end
        end.new
        stub(o, :a) {:b}
        is(o.a) == :b
        restore_originals
        is(o.a) == :a
      end

      it 'restore stubbed protected methods' do
        o = Class.new do
          protected
          def a; :a; end
        end.new
        stub(o, :a) {:b}
        is(o.__send__(:a)) == :b
        restore_originals
        is(o.__send__(:a)) == :a
      end

      it 'restore stubbed private methods' do
        o = Class.new do
          private
          def a; :a; end
        end.new
        stub(o, :a) {:b}
        is(o.__send__(:a)) == :b
        restore_originals
        is(o.__send__(:a)) == :a
      end

      it 'restore stubbed chained methods' do
        o.define_singleton_method(:a) {:a}
        stub(o, 'a.b.c') {:b}
        assert(o.a) != :a
        restore_originals
        is(o.a) == :a
      end

      it 'restore :nil? method' do
        o = nil
        is(o.nil?) == true
        stub(o, :nil?) { :blah }
        is(o.nil?) == :blah
        restore_originals
        is(o.nil?) == true
      end

      it 'undefines early unexisting public methods' do
        assure(o).does_not.respond_to? :a
        assert { o.a }.raise NoMethodError

        stub(o, :a) {:a}
        does(o).respond_to? :a
        is(o.a) == :a

        restore_originals

        assure(o).does_not.respond_to? :a
        assert { o.a }.raise NoMethodError
      end

      it 'undefines early unexisting protected methods' do
        assert(o.protected_methods).does_not.include? :a

        protected_stub(o, :a) {:a}
        does(o.protected_methods).include? :a

        restore_originals

        assert(o.protected_methods).does_not.include? :a
      end

      it 'undefines early unexisting private methods' do
        assert(o.private_methods).does_not.include? :a

        private_stub(o, :a) {:a}
        does(o.private_methods).include? :a

        restore_originals

        assert(o.private_methods).does_not.include? :a
      end

      it 'uses `returns` with a block to define a catchall return' do
        stub(o, :a).
          with_any { :A }.
          with(1) { :one }
        assert(o.a) == :A
        assert(o.a(:blah)) == :A
        assert(o.a(1)) == :one
      end

      it 'uses `returns` with a value to define a catchall return' do
        stub(o, :a).
          with_any(:A).
          with(1) { :one }
        assert(o.a) == :A
        assert(o.a(:blah)) == :A
        assert(o.a(1)) == :one
      end

      it 'defines multiple stubs at once' do
        stubs(o, :a, :b)
        does(o).respond_to?(:a)
        does(o).respond_to?(:b)
      end

      it 'uses the given block for all stubs' do
        stubs(o, :a, :b) {:x}
        assert(o.a) == :x
        assert(o.b) == :x
      end

      it 'uses same constraints for all stubs' do
        stubs(o, :a, :b).
          with(1) {:one}.
          with(2) {:two}.
          with_any(:any)

        assert(o.a) == :any
        assert(o.a(:what, :ever)) == :any

        assert(o.b) == :any
        assert(o.b(:blah)) == :any

        assert(o.a(1)) == :one
        assert(o.b(1)) == :one

        assert(o.a(2)) == :two
        assert(o.b(2)) == :two
      end

      it 'defines multiple private stubs' do
        private_stubs(o, :a, :b)
        does(o.private_methods).include?(:a)
        does(o.private_methods).include?(:b)
        does { o.a }.raise? NoMethodError, /private method\W+a/
        does { o.b }.raise? NoMethodError, /private method\W+b/
      end

      it 'defines multiple protected stubs' do
        protected_stubs(o, :a, :b)
        does(o.protected_methods).include?(:a)
        does(o.protected_methods).include?(:b)
        does { o.a }.raise? NoMethodError, /protected method\W+a/
        does { o.b }.raise? NoMethodError, /protected method\W+b/
      end
    end

    define_tests(Unit)
  end
end
