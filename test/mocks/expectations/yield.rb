class MinispecTest::Expectations::Unit

  should 'pass when yield expected and occurred' do
    expect(o).to_receive(:y).and_yield
    o.y {|a,b|}
  end

  should 'pass when yield not expected and not occurred' do
    o = Class.new { def y; end }.new
    expect(o).to_receive(:y).without_yield
    o.y
  end

  should ':fail when yield expected but not occurred' do
    expect(o).to_receive(:a).and_yield
    o.a
  end

  should ':fail when yield occurred but not expected' do
    expect(o).to_receive(:y).without_yield
    o.y {|a,b|}
  end

  should 'pass when yielded with expected arguments' do
    expect(o).to_receive(:y).and_yield(1, 2)
    o.y {|a, b|}
  end

  should 'flatten arguments when single value expected' do
    o.define_singleton_method(:y) {|&b| b.call(1)}
    expect(o).to_receive(:y).and_yield(1)
    o.y {|a, b|}
  end

  should ':fail when yielded with wrong arguments' do
    expect(o).to_receive(:y).and_yield(4, 5)
    o.y {|a, b|}
  end

  should 'pass when proc validates yielded arguments' do
    expect(o).to_receive(:y).and_yield {|args| args[0] == [1, 2]}
    o.y {|a, b|}
  end

  should ':fail when proc does not validate yielded arguments' do
    expect(o).to_receive(:y).and_yield {false}
    o.y {|a, b|}
  end

  should 'not raise when arity not respected and proc used' do
    expect(o).to_receive(:y)
    assure { o.y {|a|} }.does_not.raise
  end

  should 'raise when arity not respected and lambda used' do
    expect(o).to_receive(:y)
    does { o.y(&lambda {|a|}) }.raise? ArgumentError, /2.+1/
  end

  should 'use same expectation for all messages' do
    expect(o).to_receive(:y, :x).and_yield([1, 2])
    o.y {|a,b|}
    o.x {|a,b|}
  end

  should 'pass when multiple yielded arguments match expected ones' do
    expect(o).to_receive(:y, :x).and_yield([1, 2], [1, 2])
    o.y {|a,b|}
    o.x {|a,b|}
  end

  should 'flatten arguments when some message expects a single value' do
    o.define_singleton_method(:y) {|&b| b.call(1)}
    expect(o).to_receive(:y, :x).and_yield(1, [1, 2])
    o.y {|a,b|}
    o.x {|a,b|}
  end

  should 'NOT flatten arguments when validated by a block' do
    o.define_singleton_method(:y) {|&b| b.call(1)}
    expect(o).to_receive(:y, :x).and_yield {|y,x| y[0] == [1] && x[0] == [1, 2]}
    o.y {|a,b|}
    o.x {|a,b|}
  end

  should ':fail when at least one message does not yield as expected' do
    expect(o).to_receive(:y, :x).and_yield([1, 2], 0)
    o.y {|a,b|}
    o.x {|a,b|}
  end

  should ':fail when proc does not validate multiple yielded arguments' do
    expect(o).to_receive(:y, :x).and_yield {false}
    o.y {|a,b|}
    o.x {|a,b|}
  end

  should ':fail when multiple yields expected but none occurred' do
    expect(o).to_receive(:a, :b).and_yield
    o.a
    o.b
  end

  should ':fail when at least one yield occurred but none expected' do
    expect(o).to_receive(:a, :x).without_yield
    o.a {}
    o.x {|a,b|}
  end
end
