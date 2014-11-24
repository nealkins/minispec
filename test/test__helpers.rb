class MinispecTest
  class Helpers < self

    class TrueTest
      include Minispec

      testing :true? do
        is(true).true?
      end
      should ':fail' do
        is(:blah).true?
      end
    end
    define_tests(TrueTest)

    class PositiveTest
      include Minispec

      testing :positive? do
        is(true).positive?
        is(:something).positive?
        is('anything').positive?
      end
      should ':fail when nil' do
        is(nil).positive?
      end
      should ':fail when false' do
        is(false).positive?
      end
    end
    define_tests(PositiveTest)

    class FalseTest
      include Minispec

      testing :false? do
        is(false).false?
      end
      should ':fail' do
        is(:blah).false?
      end
    end
    define_tests(FalseTest)

    class FalsyTest
      include Minispec

      testing :nil do
        is(nil).falsy?
      end
      testing :false do
        is(false).falsy?
      end
      should ':fail' do
        is(:something).falsy?
      end
    end
    define_tests(FalsyTest)

    class ArrayTest
      include Minispec

      testing :same_elements do
        a1 = [1, 2, :a, :b, :c]
        a2 = [:b, 1, :c, 2, :a]
        assert(a1).has.same_elements_as a2
      end
      should 'raise if non-Array given' do
        does { assert('').has.same_elements '' }.raise? ArgumentError, /Array\?/
      end
      should 'raise if right array missing' do
        does { assert([]).has.same_elements }.raise? ArgumentError
      end
      should ':fail if arrays size vary' do
        assert([1]).has.same_elements [1,2]
      end
      should ':fail if arrays elements vary' do
        assert([:a, :b]).has.same_elements [:x, :y]
      end
    end
    define_tests(ArrayTest)

    class ContainTest
      include Minispec

      should 'work with integers' do
        does([1, 2, 5, 6]).contain? 1, 2
      end
      should 'work with floats' do
        does([1.2, 2]).contain? 1.2
      end
      should 'work with strings' do
        does([1.2, '2', 5, 4]).contain? '2', 4
      end
      should 'work with regexps' do
        does([1.2, 'abc', 8, 9]).contain? /b/, 9
      end
      should ':fail if no element found' do
        does([1, 2]).contain? :a
      end
      should ':fail if no element matched' do
        does([:a, :b]).contain? /x/
      end
      should 'raise if non-Array given' do
        does { assert(:blah).contain? :blah }.raise? ArgumentError
      end
    end
    define_tests(ContainTest)

    class ContainAnyTest
      include Minispec

      should 'work with integers' do
        does([1, 2, 5, 6]).contain_any? 1, 8
      end
      should 'work with floats' do
        does([4, 2]).contain_any? 2
      end
      should 'work with strings' do
        does([1.2, '2', 5, 4]).contain_any? '2', 4
      end
      should 'work with regexps' do
        does([1.2, 'abc', 8]).contain_any? /b/, 9
      end
      should ':fail if no element found' do
        does([1, 2]).contain_any? :a
      end
      should ':fail if no element matched' do
        does([:a, :b]).contain_any? /x/
      end
      should 'raise if non-Array given' do
        does { assert(:blah).contain_any? :blah }.raise? ArgumentError
      end
    end
    define_tests(ContainAnyTest)

    class SilentTest
      include Minispec

      should 'pass' do
        is { '' }.silent?
      end

      should ':fail because of stdout' do
        assert { puts 'something' }.is_silent
      end

      should ':fail because of stderr' do
        assert { warn 'something' }.is_silent
      end

      should 'pass when it is not silent and not expected to' do
        assert { puts 'something' }.is_not.silent
      end

      should ':fail when it is silent but not expected to' do
        assert {  }.is_not.silent
      end
    end
    define_tests(SilentTest)

    class LeftBlockTest
      include Minispec

      helper :blank? do |block|
        is(&block).empty?
      end

      should 'pass' do
        is { '' }.blank?
      end

      should ':fail' do
        is { '-' }.blank?
      end
    end
    define_tests(LeftBlockTest)

    class RightBlockTest
      include Minispec

      helper :any_value? do |obj, block|
        assert(obj).any?(&block)
      end

      should 'pass' do
        has([1, 2]).any_value? {|v| v > 1}
      end

      should ':fail' do
        has([1, 2]).any_value? {|v| v > 5}
      end
    end
    define_tests(RightBlockTest)

  end
end
