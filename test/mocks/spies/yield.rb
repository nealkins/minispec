class MinispecTest::Spies::Unit

  should 'pass when yield expected and occurred' do
    o.y {|a,b|}
    expect(o).received(:y).and_yield
  end

  should 'pass when yield not expected and not occurred' do
    o = Class.new { def y; end }.new
    proxy(o, :y)
    o.y
    expect(o).received(:y).without_yield
  end

  should ':fail when yield expected but not occurred' do
    o.a
    expect(o).received(:a).and_yield
  end

  should ':fail when yield occurred but not expected' do
    o.y {|a,b|}
    expect(o).received(:y).without_yield
  end

  should 'pass when yielded with expected arguments' do
    o.y {|a, b|}
    expect(o).received(:y).and_yield(1, 2)
  end

  should ':fail when yielded with wrong arguments' do
    o.y {|a, b|}
    expect(o).received(:y).and_yield(4, 5)
  end

  should 'pass when proc validates yielded arguments' do
    o.y {|a, b|}
    expect(o).received(:y).and_yield {|args| args == [[1, 2]]}
  end

  should ':fail when proc does not validate yielded arguments' do
    o.y {|a, b|}
    expect(o).received(:y).and_yield {|a,b| false}
  end

  should 'not raise when arity not respected and proc used' do
    refute { o.y {|a|} }.raise
    expect(o).received(:y)
  end

  should 'use same expectation for all messages' do
    o.y {|a,b|}
    o.x {|a,b|}
    expect(o).received(:y, :x).and_yield([1, 2])
  end

  should 'pass when multiple yielded arguments match expected ones' do
    o.y {|a,b|}
    o.x {|a,b|}
    expect(o).received(:y, :x).and_yield([1, 2], [1, 2])
  end

  should 'work well when multiple Array arguments yielded' do
    o.define_singleton_method(:Y) {|&b| b.call([1, [2]])}
    proxy(o, :Y)
    o.Y {|a,b|}
    o.x {|a,b|}
    expect(o).received(:Y, :x).and_yield([[[1, [2]]]], [1, 2])
  end

  should 'pass when proc validates multiple yielded arguments' do
    o.define_singleton_method(:Y) {|&b| b.call([1, [2]])}
    proxy(o, :Y)
    o.Y {|a,b|}
    o.x {|a,b|}
    expect(o).received(:Y, :x).and_yield {|y,x| y == [[[1, [2]]]] && x == [[1, 2]]}
  end

  should ':fail when multiple yielded arguments does not match expected ones' do
    o.y {|a,b|}
    o.x {|a,b|}
    expect(o).received(:y, :x).and_yield(1, 0)
  end

  should ':fail when proc does not validate multiple yielded arguments' do
    o.y {|a,b|}
    o.x {|a,b|}
    expect(o).received(:y, :x).and_yield {|*a| false}
  end

  should ':fail when multiple yields expected but none occurred' do
    o.a
    o.b
    expect(o).received(:a, :b).and_yield
  end

  should ':fail when at least one yield occurred but none expected' do
    o.a {}
    o.x {|a,b|}
    expect(o).received(:a, :x).without_yield
  end
end
