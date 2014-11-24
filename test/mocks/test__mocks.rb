class MinispecTest
  class Mocks < self
    class Unit
      include Minispec

      let(:o) { Object.new }

      it 'creates a stub that returns nil' do
        mock(o, :a)
        is(o.a).nil?
      end

      it 'creates a stub that returns a value' do
        mock(o, :a) {:a}
        is(o.a) == :a
      end

      it 'is mocking using a Hash' do
        mock(o, a: :x, b: :y)
        does(o).respond_to?(:a)
        is(o.a) == :x
        does(o).respond_to?(:b)
        is(o.b) == :y
      end

      it 'raise ArgumentError when using constraints on Hash mocks' do
        does { mock(o, a: :b).with(1) {1} }.raise?(ArgumentError, /can not be used/i)
        # though error raised, methods should be successfully mocked
        assert(o.a) == :b
      end

      it ':fails if expectation not met' do
        mock(o, :a)
      end

      it 'calls various stubs depending on given args' do
        mock(o, :a){0}
        mock(o, :a).with(1) {1}
        mock(o, :a).with(2) {2}
        is(o.a) == 0
        is(o.a(1)) == 1
        is(o.a(2)) == 2
      end

      it 'is mocking private methods' do
        private_mock(o, :a)
        does(o.private_methods).include?(:a)
        does { o.a }.raise? NoMethodError, /private method\W+a/
        o.send(:a)
      end

      it 'mocking private methods using a Hash' do
        private_mock(o, a: :b)
        does(o.private_methods).include?(:a)
        does { o.a }.raise? NoMethodError, /private method\W+a/
        assert(o.send(:a)) == :b
      end

      it 'is mocking protected methods' do
        protected_mock(o, :a)
        does(o.protected_methods).include?(:a)
        does { o.a }.raise? NoMethodError, /protected method\W+a/
        o.send(:a)
      end

      it 'mocking protected methods using a Hash' do
        protected_mock(o, a: :b)
        does(o.protected_methods).include?(:a)
        does { o.a }.raise? NoMethodError, /protected method\W+a/
        assert(o.send(:a)) == :b
      end

      it 'keeps the visibility of existing methods' do
        o = Class.new do
          def a; end
          protected
          def b; p :blah; end
          private
          def c; end
        end.new

        mock(o, :a)
        o.send(:a)
        does(o.public_methods).include?(:a)

        mock(o, :b)
        o.send(:b)
        does(o.protected_methods).include?(:b)

        mock(o, :c)
        o.send(:c)
        does(o.private_methods).include?(:c)
      end

      it 'uses `with_any` with a block to define a catchall return' do
        mock(o, :a).
          with(1) { :one }.
          with_any { :A }
        assert(o.a) == :A
        assert(o.a(:blah)) == :A
        assert(o.a(1)) == :one
      end

      it 'uses `with_any` with a value to define a catchall return' do
        mock(o, :a).
          with(1) { :one }.
          with_any(:A)
        assert(o.a) == :A
        assert(o.a(:blah)) == :A
        assert(o.a(1)) == :one
      end

      it 'is mocking multiple methods at once' do
        mocks(o, :a, :b)
        does(o).respond_to?(:a)
        does(o).respond_to?(:b)
        o.a
        o.b
      end

      it 'is mocking multiple methods at once and :fail if a least one message not received' do
        mocks(o, :a, :b)
        o.a
        # o.b  intentionally commented
      end

      it 'uses given block for all mocks' do
        mocks(o, :a, :b) {:x}
        assert(o.a) == :x
        assert(o.b) == :x
      end

      it 'uses same constraints for all mocks' do
        mocks(o, :a, :b).
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
        o.a
        o.b
      end

      it 'defines multiple private stubs' do
        private_mocks(o, :a, :b)
        does(o.private_methods).include?(:a)
        does(o.private_methods).include?(:b)
        does { o.a }.raise? NoMethodError, /private method\W+a/
        does { o.b }.raise? NoMethodError, /private method\W+b/
        o.send(:a)
        o.send(:b)
      end

      it 'defines multiple protected stubs' do
        protected_mocks(o, :a, :b)
        does(o.protected_methods).include?(:a)
        does(o.protected_methods).include?(:b)
        does { o.a }.raise? NoMethodError, /protected method\W+a/
        does { o.b }.raise? NoMethodError, /protected method\W+b/
        o.send(:a)
        o.send(:b)
      end

      it 'enforces public visibility on protected methods' do
        o = Class.new do
          protected
          def a; end
        end.new
        does { o.a }.raise? NoMethodError, /protected method\W+a/
        public_mock(o, :a) { :a }
        assert(o.a) == :a
      end

      it 'enforces public visibility on private methods' do
        o = Class.new do
          private
          def a; end
        end.new
        does { o.a }.raise? NoMethodError, /private method\W+a/
        public_mock(o, :a) { :a }
        assert(o.a) == :a
      end
    end

    define_tests(Unit)
  end
end
