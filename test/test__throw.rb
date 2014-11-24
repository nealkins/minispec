class MinispecTest
  class Throw < self

    class Unit
      include Minispec
      continue_on_failures true

      begin
        should 'pass when symbol expected and thrown' do
          does { throw :something }.throw_symbol? :something
        end

        should ':fail when symbol expected but NOT thrown' do
          does { }.throw_symbol :something
        end

        should 'pass when NO symbol thrown though expected but negation used' do
          refute { }.throw_symbol :something
          assure { }.does_not.throw :something
        end

        should ':fail when symbol thrown but NOT expected' do
          refute { throw :something }.throw_symbol
        end
        should ':fail when symbol thrown but NOT expected - alternate syntax' do
          assure { throw :something }.does_not.throw_symbol
        end

        should 'pass when NO symbol expected and NO symbol thrown' do
          refute { }.throw_symbol
        end
      end

      begin
        should 'pass when thrown symbol match expected one' do
          does { throw :something }.throw :something
        end

        should ':fail when thrown symbol match expected one but negation used' do
          refute { throw :something }.throw :something
        end

        should ':fail when thrown symbol DOES NOT match expected one' do
          does { throw :something }.throw :something_else
        end

        should 'pass when thrown symbol DOES NOT match expected one and negation used' do
          refute { throw :a }.throw :b
          assure { throw :a }.does_not.throw :b
        end
      end

      begin
        should 'pass when thrown symbol and value matches expected ones' do
          does { throw :symbol, :value }.throw :symbol, :value
        end

        should ':fail when thrown symbol and value matches expected ones but negation used' do
          refute { throw :symbol, :value }.throw :symbol, :value
          assure { throw :symbol, :value }.does_not.throw :symbol, :value
        end

        should 'pass when symbol and value DOES NOT matches expected ones and negation used' do
          refute { throw :a, :b }.throw :x, :y
          assure { throw :a, :b }.does_not.throw :x, :y
        end
      end

      begin
        should ':fail when symbols matches but values DOES NOT' do
          does { throw :symbol, :value }.throw :symbol, :blah
        end
      end

      begin
        should ':fail when values matches but symbols DOES NOT' do
          does { throw :a, :b }.throw :c, :b
        end

        should 'pass when values matches but symbols DOES NOT and negation used' do
          refute { throw :a, :b }.throw :c, :b
          assure { throw :a, :b }.does_not.throw :c, :b
        end
      end

      begin
        should 'pass when given block validates thrown symbol' do
          does { throw :a }.throw? {|s| s == :a}
        end

        should ':fail when given block does not validate thrown symbol' do
          does { throw :a }.throw? {false}
        end
      end

      should 'raise ArgumentError when both arguments and block given' do
        does { expect { }.to_throw(:blah) {} }.raise? ArgumentError
      end
    end

    define_tests(Unit)
  end
end
