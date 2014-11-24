class MinispecTest::Expectations::Unit

  should 'pass if message received' do
    expect(o).to_receive(:a)
    o.a
  end

  should ':fail if message not received' do
    expect(o).to_receive(:a)
  end

  should 'pass when no message expected and none received' do
    expect(o).to_not.receive(:a)
  end

  should ':fail when message received but not expected' do
    expect(o).to_not.receive(:a)
    o.a
  end

  should 'pass when no messages expected and none received' do
    expect(o).to_not.receive(:a, :b)
  end

  should ':fail when at least one message received but not expected' do
    expect(o).to_not.receive(:a, :b)
    o.a
  end

  should ':fail when all messages received but not expected' do
    expect(o).to_not.receive(:a, :b)
    o.a
    o.b
  end
end
