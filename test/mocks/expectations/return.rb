class MinispecTest::Expectations::Unit

  should 'pass when correct value returned' do
    expect(o).to_receive(:a).and_return(:a)
    o.a
  end

  should ':fail when wrong value returned' do
    expect(o).to_receive(:a).and_return(:b)
    o.a
  end

  should 'pass when proc validates returned value' do
    expect(o).to_receive(:a).and_return {|r| r[0] == :a}
    o.a
  end

  should 'yield multiple returned values when message received multiple times' do
    expect(o).to_receive(:a).and_return {|r| r[0] == :a && r[1] == :a}
    o.a
    o.a
  end

  should ':fail when proc does not validate returned value' do
    expect(o).to_receive(:a).and_return {false}
    o.a
  end

  should 'pass when returned values matches expected ones' do
    expect(o).to_receive(:a, :b).and_return(:a, :b)
    o.a
    o.b
  end

  should 'pass when all messages returns same value' do
    expect(o).to_receive(:a, :z).and_return(:a)
    o.a
    o.z
  end

  should ':fail when a single value expected and a at least one message does not return it' do
    expect(o).to_receive(:a, :b).and_return(:a)
    o.a
    o.b
  end

  should ':fail when at least one message returns a unexpected value' do
    expect(o).to_receive(:a, :b).and_return(:a, :x)
    o.a
    o.b
  end

  should 'pass when proc validates returned values' do
    expect(o).to_receive(:a, :b).and_return {|a,b| a[0] == :a && b[0] == :b}
    o.a
    o.b
  end

  should 'yield multiple returned values when multiple messages received multiple times' do
    expect(o).to_receive(:a, :b).and_return {|a,b| a[0] == :a && a[1] == :a && b[0] == :b}
    o.a
    o.a
    o.b
  end

  should ':fail when proc does not validate returned values' do
    expect(o).to_receive(:a, :b).and_return {false}
    o.a
    o.b
  end
end
