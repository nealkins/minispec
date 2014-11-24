class MinispecTest::Spies::Unit

  should 'pass when messages received in expected order' do
    o.a
    o.b
    o.c
    assert(o).received(:a, :b, :c).ordered
  end

  should 'pass when middle messages missing' do
    o.a
    # b intentionally not called to make sure it iterates only through expected messages
    o.c
    assert(o).received(:a, :c).ordered
  end

  should ':fail when messages received in wrong order' do
    o.b
    o.c
    o.a
    assert(o).received(:a, :b).ordered
  end

  should 'pass when same sequence repeated n times' do
    o.a
    o.b
    o.a
    o.b
    assert(o).received(:a, :b).ordered(2)
  end

  should ':fail when expected sequence not respected' do
    o.a
    o.b
    o.a
    assert(o).received(:a, :b).ordered(2)
  end
end
