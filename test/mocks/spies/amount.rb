class MinispecTest::Spies::Unit

  should 'pass when received expected amount' do
    o.a
    o.a
    expect(o).received(:a).count(2)
  end

  should ':fail when wrong amount expected' do
    o.a
    expect(o).received(:a).count(2)
  end

  should 'pass when proc validates received amount' do
    o.a
    o.a
    expect(o).received(:a).count {|received| received == 2}
  end

  should ':fail when proc does not validate received amount' do
    o.a
    expect(o).received(:a).count {|received| false}
  end

  should 'pass when multiple messages uses one expectation' do
    o.a
    o.b
    o.b
    o.a
    expect(o).received(:a, :b).count(2)
  end

  should ':fail when received multiple messages amount are wrong' do
    o.a
    o.b
    o.b
    expect(o).received(:a, :b).count(2)
  end

  should 'pass when each of multiple messages uses its own expectation' do
    o.a
    o.b
    o.b
    expect(o).received(:a, :b).count(1, 2)
  end

  should ':fail when at least one messages does not match its expectation' do
    o.a
    o.b
    o.b
    expect(o).received(:a, :b).count(1, 1)
  end

  should 'pass when proc validates received multiple messages amount' do
    o.a
    o.b
    o.b
    o.a
    expect(o).received(:a, :b).count {|*r| r == [2, 2]}
  end

  should ':fail when proc does not validate received multiple messages amount' do
    o.a
    o.b
    expect(o).received(:a, :b).count {|*r| false}
  end

end
