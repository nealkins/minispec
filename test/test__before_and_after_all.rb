class MinispecTest
  class BeforeAllTest < self

    X, Y = [], []
    module BeforeAll
      include Minispec

      before_all do
        X << self.class
      end
    end

    class BeforeAllInherited
      include BeforeAll
    end

    def test_inherited_boot
      msrun(BeforeAllInherited)
      assert X.include?(BeforeAllInherited)
    end

    class BeforeAllInheritedAndOverriden
      include BeforeAll

      before_all do
        Y << self.class
      end
    end

    def test_override_inherited_boot
      msrun(BeforeAllInheritedAndOverriden)
      refute X.include?(BeforeAllInheritedAndOverriden)
      assert Y.include?(BeforeAllInheritedAndOverriden)
    end
  end

  class AfterAllTest < self

    X, Y = [], []
    module AfterAll
      include Minispec

      after_all do
        X << self.class
      end
    end

    class AfterAllInherited
      include AfterAll
    end

    def test_inherited_after_all
      msrun(AfterAllInherited)
      assert X.include?(AfterAllInherited)
    end

    class AfterAllInheritedAndOverriden
      include AfterAll

      after_all do
        Y << self.class
      end
    end

    def test_override_inherited_after_all
      msrun(AfterAllInheritedAndOverriden)
      refute X.include?(AfterAllInheritedAndOverriden)
      assert Y.include?(AfterAllInheritedAndOverriden)
    end
  end
end
