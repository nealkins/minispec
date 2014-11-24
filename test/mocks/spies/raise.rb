class MinispecTest::Spies::Unit

  should 'pass when raise expected and occurred' do
    o.r rescue nil
    expect(o).received(:r).and_raise
  end

  should 'pass when raise not expected and not occurred' do
    o.a
    expect(o).received(:a).without_raise
  end

  should ':fail when raise expected but not occurred' do
    o.a
    expect(o).received(:r).and_raise
  end

  should ':fail when raise occurred but not expected' do
    o.r rescue nil
    expect(o).received(:r).without_raise
  end

  should 'pass when raised an expected error' do
    o.r rescue nil
    expect(o).received(:r).and_raise ArgumentError
  end

  should ':fail when raised an unexpected error' do
    o.a
    expect(o).received(:r).and_raise RuntimeError
  end

  should 'pass when raised an expected message' do
    o.r rescue nil
    expect(o).received(:r).and_raise ArgumentError, 'some blah'
  end

  should 'pass when raised message matches expected one' do
    o.r rescue nil
    expect(o).received(:r).and_raise ArgumentError, /blah/
  end

  should ':fail when raised an unexpected message' do
    o.r rescue nil
    expect(o).received(:r).and_raise [ArgumentError, 'another blah']
  end

  should ':fail when raised message does not match expected one' do
    o.r rescue nil
    expect(o).received(:r).and_raise [ArgumentError, /x/]
  end

  should 'pass when one expectation used for all messages' do
    o.e rescue nil
    o.r rescue nil
    expect(o).received(:e, :r).and_raise ArgumentError
  end

  should 'pass when one expectation used for all messages and error matching used' do
    o.e rescue nil
    o.r rescue nil
    expect(o).received(:e, :r).and_raise [ArgumentError, 'some blah']
  end

  should ':fail when one expectation used for all messages and type does not match' do
    o.e rescue nil
    o.r rescue nil
    expect(o).received(:e, :r).and_raise Exception
  end

  should ':fail when one expectation used for all messages, type matches but message does not' do
    o.e rescue nil
    o.r rescue nil
    expect(o).received(:e, :r).and_raise [ArgumentError, 'some error']
  end

  should ':fail when one expectation used for all messages
    and at least one message does not raise at all' do
    o.a
    o.r rescue nil
    expect(o).received(:a, :r).and_raise ArgumentError
  end

  should 'pass when each message uses own expectation' do
    o.e rescue nil
    o.r rescue nil
    expect(o).received(:e, :r).and_raise ArgumentError, ArgumentError
  end

  should ':fail when each message uses own expectation
    and at least message does not raise as expected' do
    o.e rescue nil
    o.r rescue nil
    expect(o).received(:e, :r).and_raise ArgumentError, Exception
  end

  should ':fail when each message uses own expectation
    and at least message does not raise at all' do
    o.a
    o.r rescue nil
    expect(o).received(:a, :r).and_raise ArgumentError, Exception
  end

  should 'pass when each message uses own expectation and error matching used' do
    o.e rescue nil
    o.r rescue nil
    expect(o).received(:e, :r).and_raise [ArgumentError, /blah/], [ArgumentError, /blah/]
  end

  should ':fail when each message uses own expectation and error matching used
    and at least one message does not raise as expected' do
    o.e rescue nil
    o.r rescue nil
    expect(o).received(:e, :r).and_raise [ArgumentError, /blah/], [ArgumentError, /doh/]
  end

  should ':fail when at least one raise occurred but none expected' do
    o.a
    o.r rescue nil
    expect(o).received(:a, :r).without_raise
  end

  should ':fail when multiple raises expected but none occurred' do
    o.a
    o.b
    expect(o).received(:a, :b).and_raise
  end

  should 'pass when no raises expected and none expected' do
    o.a
    o.b
    expect(o).received(:a, :b).without_raise
  end

  should 'pass when given block validates raised exception' do
    o.r rescue nil
    expect(o).received(:r).and_raised {|e| e[0].class == ArgumentError}
  end

  should ':fail when given block does not validate raised exception' do
    o.r rescue nil
    expect(o).received(:r).and_raised {false}
  end

  should 'pass when given block validates raised exceptions' do
    o.r rescue nil
    o.e rescue nil
    expect(o).received(:r, :e).and_raised do |r,e|
      r[0].class == ArgumentError && e[0].class == ArgumentError
    end
  end

  should ':fail when given block does not validate raised exceptions' do
    o.r rescue nil
    o.e rescue nil
    expect(o).received(:r, :e).and_raised {false}
  end
end
