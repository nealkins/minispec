class MinispecTest
  class Spies < self

    class O
      def a(*a); :a; end
      def b(*a); :b; end
      def c(*a); :c; end
      def d; :d; end
      def e; raise(ArgumentError, 'some blah'); end
      def r; raise(ArgumentError, 'some blah'); end
      def t; throw(:s); end
      def w; throw(:s); end
      def x(&b); yield(1, 2); end
      def y(&b); yield(1, 2); end
      def z; :a; end
    end

    class Unit
      include Minispec
      continue_on_failures true
      let(:o) { O.new }
      before do
        %w[
          a
          b
          c
          d
          e
          r
          t
          w
          x
          y
          z
        ].each {|m| proxy(o, m.to_sym)}
      end
    end

    Dir[File.expand_path('../spies/*.rb', __FILE__)].each {|f| require(f)}

    define_tests(Unit)
  end
end
