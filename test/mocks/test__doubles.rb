class MinispecTest
  class Stubs < self
    class Unit
      include Minispec

      it 'uses first argument as name' do
        d = double(:a, :b)
        is(d.inspect) == :a
      end

      it 'creates anonymous doubles when no args given' do
        d = double
        does(d.inspect) =~ /#<Object/
      end

      it 'uses first argument as name and rest as stubs' do
        d = double(:a, :b, :c)
        is(d.inspect) == :a
        refute(d).respond_to?(:a)
        does(d).respond_to?(:b)
        does(d).respond_to?(:c)
      end

      it 'uses hashes for stubs' do
        a = double(:a, b: :c)
        is(a.b) == :c
      end

      it 'uses given block for returned value' do
        a = double(:a, :b) {:c}
        is(a.b) == :c
      end

      it 'creates public stubs' do
        d = double(:a, :b)
        does(d.public_methods).include?(:b)
      end

      it 'creates private stubs' do
        d = double
        private_stub(d, :a)
        does(d.private_methods).include?(:a)
        does { d.a }.raise? NoMethodError, /private method\W+a/
      end

      it 'creates protected stubs' do
        d = double
        protected_stub(d, :a)
        does(d.protected_methods).include?(:a)
        does { d.a }.raise? NoMethodError, /protected method\W+a/
      end

      it 'defines chained stubs' do
        @a = nil
        d = double(:chained, 'a.b.c') {|*a| @a = true; a}

        does(d).respond_to?(:a)
        d.a
        is(@a).nil?

        does(d.a).respond_to?(:b)
        d.a.b
        is(@a).nil?

        does(d.a.b).respond_to?(:c)
        expect(d.a.b.c(:x, :y)).to_contain :x, :y
        is(@a).true?
      end

      it 'plays well with expectations' do
        d = double(:dbl, :a)
        expect(d).to_receive(:a)
        d.a
      end

      class SomeError < ArgumentError; end
      it 'plays well with raise expectations' do
        d = double(:dbl, :a) { raise SomeError }
        expect(d).to_receive(:a).and_raise SomeError
        d.a rescue nil
      end

      it 'plays well with throw expectations' do
        d = double(:dbl, :a) { throw :ArgumentError }
        expect(d).to_receive(:a).and_throw :ArgumentError
        d.a rescue nil
      end

      it 'plays well with yield expectations' do
        d = double(:dbl, :a) { |&b| b.call :x }
        expect(d).to_receive(:a).and_yield :x
        d.a {|a|}
      end
    end

    define_tests(Unit)
  end
end
