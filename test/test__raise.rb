class MinispecTest
  class Raise < self

    class Unit
      include Minispec
      continue_on_failures true

      begin
        should 'pass when error raised and expected' do
          does { blah }.raise_error?
        end

        should ':fail when error expected but NOT raised' do
          does { :blah }.raise_error?
        end

        should 'pass when NO error expected and NO error raised' do
          refute { }.raise_error
        end

        should ':fail when error raised but NOT expected' do
          refute { Blah }.raise_error
        end
        should ':fail when error raised but NOT expected - alternative syntax' do
          assure { Blah }.does_not.raise_error
        end
      end

      begin
        should 'pass when raised error type match expected error type' do
          expect { Blah }.to_raise_error NameError
        end

        should ':fail when raised error type match expected error type but negation used' do
          refute { Blah }.raise NameError
          assure { Blah }.does_not.raise NameError
        end

        should ':fail when raised error type DOES NOT match expected error type' do
          does { Blah }.raise_error? StandardError
        end
      end

      begin # error message as first argument
        should 'pass when raised error message is equal to expected one' do
          does { Blah }.raise_error? 'uninitialized constant MinispecTest::Raise::Unit::Blah'
        end

        should ':fail when raised error message is NOT equal to expected one' do
          does { Blah }.raise_error? 'Blah'
        end

        should 'pass when raised error message match expected error message' do
          does { Blah }.raise_error? /uninitialized constant/
        end

        should ':fail when raised error message match expected error message but negation used' do
          refute { Blah }.raise_error    /uninitialized constant/
          assure { Blah }.does_not.raise /uninitialized constant/
        end

        should ':fail when raised error message DOES NOT match expected error message' do
          does { Blah }.raise_error? 'something that Ruby would never throw'
        end
      end

      begin # error message as second argument
        should 'pass when raised error matches expected one' do
          does { Blah }.raise_error? NameError, /uninitialized constant/
        end

        should ':fail when raised error match expected error but negation used' do
          refute { Blah }.raise_error? NameError,   /uninitialized constant/
          assure { Blah }.does_not.raise NameError, /uninitialized constant/
        end

        should ':fail when type matching and message DOES NOT' do
          does { Blah }.raise_error? NameError, 'something that Ruby would never throw'
        end

        should ':fail when message matching and type DOES NOT' do
          does { Blah }.raise_error? ArgumentError, 'Blah'
        end
      end

      begin # using a block to validate raised error
        should 'pass when given block validates raised error' do
          e_class = NameError
          expect { Blah }.to_raise {|e| e.class == e_class }
        end

        should ':fail when given block does not validate raised error' do
          expect { Blah }.to_raise {false}
        end
      end

      should 'raise ArgumentError when both arguments and block given' do
        does { expect { }.to_raise(NameError) {} }.raise? ArgumentError
      end
    end

    define_tests(Unit)
  end
end
