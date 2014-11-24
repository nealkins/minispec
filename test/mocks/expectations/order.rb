class MinispecTest::Expectations::Unit

  should 'pass when messages received in expected order' do
    expect(o).to_receive(:a, :b, :c).ordered
    o.a
    o.b
    o.c
  end

  should 'pass when middle messages missing' do
    expect(o).to_receive(:a, :c).ordered
    o.a
    # b intentionally not called to make sure it iterates only through expected messages
    o.c
  end

  should ':fail when messages received in wrong order' do
    expect(o).to_receive(:a, :b).ordered
    o.b
    o.c
    o.a
  end

  should 'pass when same sequence repeated n times' do
    expect(o).to_receive(:a, :b).ordered(2)
    o.a
    o.b
    o.a
    o.b
  end

  should ':fail when expected sequence not respected' do
    expect(o).to_receive(:a, :b).ordered(2)
    o.a
    o.b
    o.a
  end

  should ':fail when used with a single expected message' do
    expect { expect(o).to_receive(:a).ordered }.raise(ArgumentError, /multiple/i)
  end

  should ':fail when a non-Integer given' do
    expect { expect(o).to_receive(:a, :b).ordered('2') }.to_raise(ArgumentError, /integer/i)
  end
end
