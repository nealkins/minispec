class MinispecTest
  class Hooks < self

    BEFORE, AFTER = {}, {}
    EXPECTED = {
      [:*] => [:jazz, :blues, :rhythm_and_blues],
      jazz: [[:*], [:jazz]],
      blues: [[:*], [/blues/], [/blues/, {:except=>/rhythm/}]],
      rhythm_and_blues: [[:*], [/blues/]]
    }.freeze

    class Before
      include Minispec

      before do |test, matcher|
        update_status(test, matcher)
        update_status(matcher, test)
      end

      before :jazz do |test, matcher|
        update_status(test, matcher)
      end

      before /blues/ do |test, matcher|
        update_status(test, matcher)
      end

      before /blues/, except: /rhythm/ do |test, matcher|
        update_status(test, matcher)
      end

      test :jazz do
      end

      test :blues do
      end

      test :rhythm_and_blues do
      end

      private
      def update_status test, matcher
        (BEFORE[test] ||= []).push(matcher)
      end
    end
    msrun(Before)

    class After
      include Minispec

      after do |test, matcher|
        update_status(test, matcher)
        update_status(matcher, test)
      end

      after :jazz do |test, matcher|
        update_status(test, matcher)
      end

      after /blues/ do |test, matcher|
        update_status(test, matcher)
      end

      after /blues/, except: /rhythm/ do |test, matcher|
        update_status(test, matcher)
      end

      test :jazz do
      end

      test :blues do
      end

      test :rhythm_and_blues do
      end

      private
      def update_status test, matcher
        (AFTER[test] ||= []).push(matcher)
      end
    end
    msrun(After)

    def test_before_any
      assert_equal BEFORE[[:*]], EXPECTED[[:*]]
    end

    def test_after_any
      assert_equal AFTER[[:*]], EXPECTED[[:*]]
    end

    def test_before_jazz
      assert_equal BEFORE[:jazz], EXPECTED[:jazz]
    end

    def test_after_jazz
      assert_equal AFTER[:jazz], EXPECTED[:jazz]
    end

    def test_before_blues
      assert_equal BEFORE[:blues], EXPECTED[:blues]
    end

    def test_after_blues
      assert_equal AFTER[:blues], EXPECTED[:blues]
    end

    def test_before_rhythm_and_blues
      assert_equal BEFORE[:rhythm_and_blues], EXPECTED[:rhythm_and_blues]
    end

    def test_after_rhythm_and_blues
      assert_equal AFTER[:rhythm_and_blues], EXPECTED[:rhythm_and_blues]
    end

  end
end
