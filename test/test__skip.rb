class MinispecTest
  class Skip < self
    class Generic
      include Minispec

      test :skip do
        is(1) == 1
        skip
        is(1) == 2
      end
    end

    def test_skip
      result = msrun(Generic)
      assert_equal -1, result.status[:skip]
    end

    class Conditionally
      include Minispec

      OPTS = {}
      test :skip do
        is(1) == 1
        skip if OPTS[:skipped?]
        is(1) == 2
      end
    end

    def test_conditional_skip_when_skipped
      Conditionally::OPTS[:skipped?] = true
      result = msrun(Conditionally)
      assert_equal -1, result.status[:skip]
    end

    def test_conditional_skip_when_not_skipped
      Conditionally::OPTS[:skipped?] = false
      result = msrun(Conditionally)
      assert_equal 1, result.status[:skip]
    end
  end
end
