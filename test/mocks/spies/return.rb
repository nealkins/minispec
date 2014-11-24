class MinispecTest::Spies::Unit

  should 'pass when correct value returned' do
    o.a
    expect(o).received(:a).and_returned(:a)
  end

  should ':fail when wrong value returned' do
    o.a
    expect(o).received(:a).and_returned(:b)
  end

  should 'pass when proc validates returned value' do
    o.a
    expect(o).received(:a).and_returned {|r| r == [:a]}
  end

  should 'yield multiple returned values when message received multiple times' do
    o.a
    o.a
    expect(o).received(:a).and_returned {|r| r == [:a, :a]}
  end

  should ':fail when proc does not validate returned value' do
    o.a
    expect(o).received(:a).and_returned {|r| false}
  end

  should 'pass when returned values matches expected ones' do
    o.a
    o.b
    expect(o).received(:a, :b).and_returned(:a, :b)
  end

  should 'pass when all messages returns same value' do
    o.a
    o.z
    expect(o).received(:a, :z).and_returned(:a)
  end

  should ':fail when a single value expected and a at least one message does not return it' do
    o.a
    o.b
    expect(o).received(:a, :b).and_returned(:a)
  end

  should ':fail when at least one message does not return what expected' do
    o.a
    o.b
    expect(o).received(:a, :b).and_returned(:a, :x)
  end

  should 'pass when proc validates returned values' do
    o.a
    o.b
    expect(o).received(:a, :b).and_returned {|a,b| a == [:a] && b == [:b]}
  end

  should 'yield multiple returned values when multiple messages received multiple times' do
    o.a
    o.a
    o.b
    expect(o).received(:a, :b).and_returned {|a,b| a == [:a, :a] && b == [:b]}
  end

  should ':fail when proc does not validate returned values' do
    o.a
    o.b
    expect(o).received(:a, :b).and_returned {|a| false}
  end
end
