class MinispecTest::Expectations::Unit

  should 'pass when throw expected and occurred' do
    expect(o).to_receive(:t).and_throw(:s)
    o.t rescue nil
  end

  should ':fail when throw expected but not occurred' do
    expect(o).to_receive(:a).and_throw(:s)
    o.a
  end

  should ':fail when throw occurred but not expected' do
    expect(o).to_receive(:t).without_throw
    o.t rescue nil
  end

  should 'pass when throw not expected and not occurred' do
    expect(o).to_receive(:a).without_throw
    o.a
  end

  should 'pass when an expected symbol thrown' do
    expect(o).to_receive(:t).and_throw :s
    o.t rescue nil
  end

  should ':fail when thrown an unexpected symbol' do
    expect(o).to_receive(:t).and_throw :x
    o.t rescue nil
  end

  should 'pass when given block validates thrown symbol' do
    expect(o).to_receive(:t).and_throw {|t| t[0] == :s}
    o.t rescue nil
  end

  should ':fail when given block does not validate thrown symbol' do
    expect(o).to_receive(:t).and_throw {false}
    o.t rescue nil
  end

  should 'pass when given block validates thrown symbols' do
    expect(o).to_receive(:t, :w).and_throw {|t,w| t[0] == :s && w[0] == :s}
    o.t rescue nil
    o.w rescue nil
  end

  should ':fail when given block does not validate thrown symbols' do
    expect(o).to_receive(:t, :w).and_throw {false}
    o.t rescue nil
    o.w rescue nil
    o.w rescue nil
  end

  should 'pass when all messages uses same expectation' do
    expect(o).to_receive(:t, :w).and_throw :s
    o.t rescue nil
    o.w rescue nil
  end

  should ':fail when all messages uses same expectation
    and at least one message throws a wrong symbol' do
    expect(o).to_receive(:t, :w).and_throw :x
    o.t rescue nil
    o.w rescue nil
  end

  should ':fail when all messages uses same expectation
    ad at least one message does not throw any symbol' do
    expect(o).to_receive(:t, :z).and_throw :t
    o.t rescue nil
    o.z rescue nil
  end

  should 'pass when each message uses own expectation' do
    expect(o).to_receive(:t, :w).and_throw :s, :s
    o.t rescue nil
    o.w rescue nil
  end

  should ':fail when each message uses own expectation
    and at least one message does not throw as expected' do
    expect(o).to_receive(:t, :w).and_throw :s, :x
    o.t rescue nil
    o.w rescue nil
  end

  should ':fail when each message uses own expectation
    and at least one message does not throw at all' do
    expect(o).to_receive(:t, :z).and_throw :s, :z
    o.t rescue nil
    o.z
  end

  should ':fail when at least one throw occurred but none expected' do
    expect(o).to_receive(:a, :t).without_throw
    o.a
    o.t rescue nil
  end

  should ':fail when multiple thrown expected but none occurred' do
    expect(o).to_receive(:a, :b).and_throw :s, :s
    o.a
    o.b
  end

  should 'pass when no thrown expected and none expected' do
    expect(o).to_receive(:a, :b).without_throw
    o.a
    o.b
  end
end
