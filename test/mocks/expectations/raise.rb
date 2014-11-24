class MinispecTest::Expectations
  class Unit

    begin # single expectation
      should 'pass when raise expected and occurred' do
        expect(o).to_receive(:r).and_raise
        o.r rescue nil
      end

      should 'pass when raise not expected and not occurred' do
        expect(o).to_receive(:a).without_raise
        o.a
      end

      should ':fail when raise expected but not occurred' do
        expect(o).to_receive(:a).and_raise
        o.a
      end

      should ':fail when raise occurred but not expected' do
        expect(o).to_receive(:r).without_raise
        o.r rescue nil
      end

      should 'pass when raised an expected error' do
        expect(o).to_receive(:r).and_raise(ArgumentError)
        o.r rescue nil
      end

      should ':fail when raised an unexpected error' do
        expect(o).to_receive(:r).and_raise(RuntimeError)
        o.r rescue nil
        o.r rescue nil
      end

      should 'pass when raised an expected message' do
        expect(o).to_receive(:r).and_raise(ArgumentError, 'some blah')
        o.r rescue nil
      end

      should 'pass when raised message matches expected one' do
        expect(o).to_receive(:r).and_raise(ArgumentError, /blah/)
        o.r rescue nil
      end

      should ':fail when raised an unexpected message' do
        expect(o).to_receive(:r).and_raise(ArgumentError, 'another blah')
        o.r rescue nil
      end

      should ':fail when raised message does not match expected one' do
        expect(o).to_receive(:r).and_raise(ArgumentError, /x/)
        o.r rescue nil
      end

      should 'pass when given block validates raised exception' do
        expect(o).to_receive(:r).and_raise {|r| r.any? {|x| x.class == ArgumentError}}
        o.r rescue nil
      end

      should ':fail when given block does not validate raised exception' do
        expect(o).to_receive(:r).and_raise {false}
        o.r rescue nil
      end
    end

    begin # multiple expectations

      should 'pass when one expectation used for all messages' do
        expect(o).to_receive(:e, :r).and_raise(ArgumentError)
        o.e rescue nil
        o.r rescue nil
      end
      should 'pass when one expectation used for all messages and error matching used' do
        expect(o).to_receive(:e, :r).and_raise([ArgumentError, 'some blah'])
        o.e rescue nil
        o.r rescue nil
      end

      should ':fail when one expectation used for all messages and type does not match' do
        expect(o).to_receive(:e, :r).and_raise(Exception)
        o.e rescue nil
        o.r rescue nil
      end

      should ':fail when one expectation used for all messages, type matches but message does not' do
        expect(o).to_receive(:e, :r).and_raise([ArgumentError, 'some error'])
        o.e rescue nil
        o.r rescue nil
      end

      should ':fail when one expectation used for all messages
        and at least one message does not raise at all' do
        expect(o).to_receive(:a, :r).and_raise(ArgumentError)
        o.a
        o.r rescue nil
      end

      should 'pass when each message uses own expectation' do
        expect(o).to_receive(:e, :r).and_raise(ArgumentError, ArgumentError)
        o.e rescue nil
        o.r rescue nil
      end

      should ':fail when each message uses own expectation
        and at least message does not raise as expected' do
        expect(o).to_receive(:e, :r).and_raise(ArgumentError, Exception)
        o.e rescue nil
        o.r rescue nil
      end

      should ':fail when each message uses own expectation
        and at least message does not raise at all' do
        expect(o).to_receive(:a, :r).and_raise(ArgumentError, Exception)
        o.a
        o.r rescue nil
      end

      should 'pass when each message uses own expectation and error matching used' do
        expect(o).to_receive(:e, :r).and_raise([ArgumentError, /blah/], [ArgumentError, /blah/])
        o.e rescue nil
        o.r rescue nil
      end

      should ':fail when each message uses own expectation and error matching used
        and at least one message does not raise as expected' do
        expect(o).to_receive(:e, :r).and_raise([ArgumentError, /blah/], [ArgumentError, /doh/])
        o.e rescue nil
        o.r rescue nil
      end

      should ':fail when at least one raise occurred but none expected' do
        expect(o).to_receive(:a, :r).without_raise
        o.a
        o.r rescue nil
      end

      should ':fail when multiple raises expected but none occurred' do
        expect(o).to_receive(:a, :b).and_raise
        o.a
        o.b
      end

      should 'pass when no raises expected and none occurred' do
        expect(o).to_receive(:a, :b).without_raise
        o.a
        o.b
      end

      should 'pass when given block validates raised exceptions' do
        expect(o).to_receive(:r, :e).and_raise do |r,e|
          r.any? {|x| x.class == ArgumentError} &&
            e.any? {|x| x.class == ArgumentError}
        end
        o.r rescue nil
        o.e rescue nil
      end

      should ':fail when given block does not validate raised exceptions' do
        expect(o).to_receive(:r, :e).and_raise {false}
        o.r rescue nil
        o.e rescue nil
      end
    end
  end
end
