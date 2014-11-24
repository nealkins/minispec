class MinispecTest::Expectations::Unit

  should 'pass when received expected amount' do
    expect(o).to_receive(:a).count(2)
    o.a
    o.a
  end

  should ':fail when received wrong amount of times' do
    expect(o).to_receive(:a).count(2)
    o.a
  end

  should 'pass when proc validates received amount' do
    expect(o).to_receive(:a).count {|r| r == 2}
    o.a
    o.a
  end

  should ':fail when proc does not validate received amount' do
    expect(o).to_receive(:a).count { false }
    o.a
  end

  should 'pass when multiple messages uses one expectation' do
    expect(o).to_receive(:a, :b).count(2)
    o.a
    o.b
    o.b
    o.a
  end

  should ':fail when received multiple messages amount are wrong' do
    expect(o).to_receive(:a, :b).count(2)
    o.a
    o.b
    o.b
  end

  should 'pass when each of multiple messages uses its own expectation' do
    expect(o).to_receive(:a, :b).count(1, 2)
    o.a
    o.b
    o.b
  end

  should ':fail when at least one message does not match its expectation' do
    expect(o).to_receive(:a, :b).count(1, 1)
    o.a
    o.b
    o.b
  end

  should 'pass when proc validates received multiple messages amount' do
    expect(o).to_receive(:a, :b).count {|a, b| a == 2 && b == 2}
    o.a
    o.b
    o.b
    o.a
  end

  should ':fail when proc does not validate received multiple messages amount' do
    expect(o).to_receive(:a, :b).count { false }
    o.a
    o.b
  end
end
