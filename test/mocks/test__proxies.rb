class MinispecTest
  class Proxies < self
    class Unit
      include Minispec

      def restore_originals
        __ms__mocks__restore_originals
      end

      class O
        def x; __method__; end

        protected
        def y; __method__; end

        private
        def z; __method__; end
      end

      let(:o) { O.new }

      it 'is proxying only once' do
        proxy(o, :x)
        position = @__ms__proxies[o].index(:x)
        assert(position).not.nil?
        proxy(o, :x)
        expect(o).to_receive(:x)
        o.x
        assert(@__ms__proxies[o][position]) == :x
      end

      it 'is proxying public methods' do
        proxy(o, :x)
        expect(o).to_receive(:x)
        assert(o.x) == :x
        assert(o).received(:x)
      end

      it 'is proxying protected methods' do
        proxy(o, :y)
        expect(o).to_receive(:y)
        assert(o.send(:y)) == :y
        assert(o).received(:y)
      end

      it 'is proxying private methods' do
        proxy(o, :z)
        expect(o).to_receive(:z)
        assert(o.send(:z)) == :z
        assert(o).received(:z)
      end

      should 'raise NoMethodError when trying to proxify an un-existing method' do
        does { proxy(o, :a) }.raise? NoMethodError
      end

    end

    define_tests(Unit)
  end
end
