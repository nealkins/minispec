class MinispecTest::Spies::Unit

  should 'pass if message received' do
    o.a
    expect(o).received(:a)
  end

  should ':fail if message not received' do
    expect(o).received(:a)
  end

  should 'pass when no message expected and none received' do
    assert(o).not.received(:a)
  end

  should ':fail when message sent but not expected' do
    o.a
    assert(o).not.received(:a)
  end

  should 'pass when no messages expected and none received' do
    assert(o).not.received(:a, :b)
  end

  should ':fail when at least one message sent but none expected' do
    o.a
    assert(o).not.received(:a, :b)
  end

  should ':fail when all messages sent but none expected' do
    o.a
    o.b
    assert(o).not.received(:a, :b)
  end

  it 'spies on multiple messages' do
    o = Class.new do
      def a; __method__; end
      def b; __method__; end
      def c; __method__; end
    end.new
    spy(o, :a, :b, :c)
    o.a
    o.b
    o.c
    assert(o).received(:a, :b, :c).and_returned(:a, :b, :c)
  end

  it 'spies on multiple messages and :fail when at least one message not received' do
    o = Class.new do
      def a; __method__; end
      def b; __method__; end
      def c; __method__; end
    end.new
    spy(o, :a, :b, :c)
    o.a
    # o.b intentionally commented
    o.c
    assert(o).received(:a, :b, :c)
  end
end
