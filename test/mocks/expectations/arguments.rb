class MinispecTest::Expectations::Unit

  should 'pass when expected arguments matches given ones' do
    expect(o).to_receive(:a).with(1, 2)
    o.a(1, 2)
    o.a(4, 5)
  end

  should ':fail when wrong arguments given' do
    expect(o).to_receive(:a).with(4, 5)
    o.a(1, 2)
    o.a(:a, 'b', [:z])
    o.a([:x], {y: :z})
  end

  should 'pass when proc validates arguments' do
    expect(o).to_receive(:a).with {|x| x[0] == [1] && x[1] == [:b]}
    o.a(1)
    o.a(:b)
    expect(o).to_receive(:b).with {|x| x[0] == [:x, [:y]] && x[1] == [9]}
    o.b(:x, [:y])
    o.b(9)
    expect(o).to_receive(:c).with {|x| x[0] == [ [1], {2 => 3} ]}
    o.c([1], {2 => 3})
  end

  should ':fail when proc does not validate arguments' do
    expect(o).to_receive(:a).with {false}
    o.a(1)
    o.a(:x)
    o.a({a: :b}, [:x, [:y]])
  end

  should 'pass when no arguments expected and no arguments given' do
    expect(o).to_receive(:a).without_arguments
    o.a
  end

  should 'pass when no arguments expected and message called at least once without arguments' do
    expect(o).to_receive(:a).without_arguments
    o.a(:x)
    o.a(:y)
    o.a
  end

  should ':fail when no arguments expected and message never called without arguments' do
    expect(o).to_receive(:a).without_arguments
    o.a(:x)
    o.a(:y)
  end

  should 'pass when given multiple arguments matching expected ones' do
    expect(o).to_receive(:a, :b, :c).with(1, 2, 3)
    o.a 1
    o.b 2
    o.c 3
  end

  it 'plays well with Array arguments' do
    expect(o).to_receive(:a, :b, :c).with([1], [4, 5, [6]], :c)
    o.a [1]
    o.a ['1']
    o.b [4, 5, [6]]
    o.b ['a', 'b', :c]
    o.c :c
  end

  should 'pass when proc validates passed arguments' do
    expect(o).to_receive(:a, :b, :c).with do |a, b, c|
      a[0]   == [1] &&
        a[1] == [:z] &&
        b[0] == [[1], [2, 3]] &&
        b[1] == [:x] &&
        c[0] == [3, [:x], {y: :z}] &&
        c[1] == [:o]
    end
    o.a 1
    o.a :z
    o.b [1], [2, 3]
    o.b :x
    o.c 3, [:x], {y: :z}
    o.c :o
  end

  should ':fail when at least one argument does not meet expectations' do
    expect(o).to_receive(:a, :b, :c).with(1, 2, [:x, "y", [:z]])
    o.a 1
    o.b [2]
    o.c 3
    o.c :x
    o.c [:x, :y, {z: 'z'}]
  end

  should ':fail when proc does not validate passed arguments' do
    expect(o).to_receive(:a, :b, :c).with { false }
    o.a 1
    o.a [1, 2]
    o.b 2
    o.b :x, [:y]
    o.c ['3']
  end

  should 'pass when no arguments expected and all messages called without arguments' do
    expect(o).to_receive(:a, :b, :c).without_arguments
    o.a
    o.b
    o.c
  end

  should 'pass when no arguments expected and each message called at least once without arguments' do
    expect(o).to_receive(:a, :b, :c).without_arguments
    o.a
    o.a(:x)
    o.b
    o.b(:y)
    o.c
    o.c(:z)
  end

  should ':fail when no arguments expected and at least one message never called without arguments' do
    expect(o).to_receive(:a, :b, :c).without_arguments
    o.a
    o.b
    o.c(:x)
  end
end
