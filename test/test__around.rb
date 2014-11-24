class MinispecTest
  class Around < self

    X, Y = [], []
    class A
      include Minispec

      around do |test|
        X.clear
        X << 1
        test.call
        X << 2
      end

      test :around do
        X << :A
      end
    end

    def test_around
      msrun(A)
      assert_equal [1, :A, 2], X
    end

    module C
      include Minispec

      around /a/ do |test|
        X.clear
        test.call
        X << :a
      end
    end

    class D
      include C

      test(:a) {}
      test(:b) {}
    end

    def test_around_runs_only_on_matching_tests
      msrun(D)
      assert_equal [:a], X
    end

    class F < A
      around {raise}
      around {X.clear}
      test(:around) {}
    end

    def test_only_last_around_run
      msrun(F)
      assert_equal [], X
    end
  end
end
