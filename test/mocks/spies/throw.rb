class MinispecTest::Spies::Unit

  should 'pass when throw expected and occurred' do
    o.t rescue nil
    expect(o).received(:t).and_throw :s
  end

  should ':fail when throw expected but not occurred' do
    o.a
    expect(o).received(:a).and_throw :s
  end

  should ':fail when throw occurred but not expected' do
    o.t rescue nil
    expect(o).received(:t).without_throw
  end

  should 'pass when throw not expected and not occurred' do
    o.a
    expect(o).received(:a).without_throw
  end

  should 'pass when an expected symbol thrown' do
    o.t rescue nil
    expect(o).received(:t).and_throw :s
  end

  should ':fail when thrown an unexpected symbol' do
    o.t rescue nil
    expect(o).received(:t).and_throw :x
  end

  should 'pass when given block validates thrown symbol' do
    o.t rescue nil
    expect(o).received(:t).and_throw {|t| t == [:s]}
  end

  should ':fail when given block does not validate thrown symbol' do
    o.t rescue nil
    expect(o).received(:t).and_throw {false}
  end

  should 'pass when given block validates thrown symbols' do
    o.t rescue nil
    o.w rescue nil
    expect(o).received(:t, :w).and_throw {|t,w| t == [:s] && w == [:s]}
  end

  should ':fail when given block does not validate thrown symbols' do
    o.t rescue nil
    o.w rescue nil
    expect(o).received(:t, :w).and_throw {false}
  end

  should 'pass when all messages uses same expectation' do
    o.t rescue nil
    o.w rescue nil
    expect(o).received(:t, :w).and_throw :s
  end

  should ':fail when all messages uses same expectation
    and at least one message throws a wrong symbol' do
    o.t rescue nil
    o.w rescue nil
    expect(o).received(:t, :w).and_throw :x
  end

  should ':fail when all messages uses same expectation
    ad at least one message does not throw any symbol' do
    o.t rescue nil
    o.z
    expect(o).received(:t, :z).and_throw :t
  end

  should 'pass when each message uses own expectation' do
    o.t rescue nil
    o.w rescue nil
    expect(o).received(:t, :w).and_throw :s, :s
  end

  should ':fail when each message uses own expectation
    and at least one message does not throw as expected' do
    o.t rescue nil
    o.w rescue nil
    expect(o).received(:t, :w).and_throw :s, :x
  end

  should ':fail when each message uses own expectation
    and at least one message does not throw at all' do
    o.t rescue nil
    o.z
    expect(o).received(:t, :z).and_throw :t, :z
  end

  should ':fail when at least one throw occurred but none expected' do
    o.a
    o.t rescue nil
    expect(o).received(:a, :t).without_throw
  end

  should ':fail when multiple thrown expected but none occurred' do
    o.a
    o.b
    expect(o).received(:a, :b).and_throw :s, :s
  end

  should 'pass when no thrown expected and none expected' do
    o.a
    o.b
    expect(o).received(:a, :b).without_throw
  end

end
