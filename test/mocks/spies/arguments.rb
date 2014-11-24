class MinispecTest::Spies::Unit

  should 'pass when expected arguments matches given ones' do
    o.a(1, 2)
    expect(o).received(:a).with(1, 2)
  end

  should ':fail when wrong arguments given' do
    o.a(1, 2)
    expect(o).received(:a).with(4, 5)
  end

  should 'pass when proc validates arguments' do
    o.a(1)
    expect(o).received(:a).with {|a| a[0] == [1]}
  end

  should ':fail when proc does not validate arguments' do
    o.a(1)
    expect(o).received(:a).with {|a| false}
  end

  should 'pass when given multiple arguments matching expected ones' do
    o.a 1
    o.b 2
    o.c 3
    expect(o).received(:a, :b, :c).with(1, 2, 3)
  end

  it 'plays well with Array arguments' do
    o.a [1]
    o.b [4, 5, [6]]
    o.c :c
    expect(o).received(:a, :b, :c).with([1], [4, 5, [6]], :c)
  end

  should 'pass when proc validates passed arguments' do
    o.a 1
    o.b [2]
    o.c 3
    expect(o).received(:a, :b, :c).with {|a,b,c| a[0] == [1] && b[0] == [[2]] && c[0] == [3]}
  end

  should ':fail when at least one argument does not meet expectations' do
    o.a 1
    o.b 2
    o.c 3
    expect(o).received(:a, :b, :c).with(1, 2, 5)
  end

  should ':fail when proc does not validate passed arguments' do
    o.a 1
    o.b 2
    o.c 3
    expect(o).received(:a, :b, :c).with {|a| false}
  end
end
