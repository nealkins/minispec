class MinispecTest::Expectations::Unit

  should 'pass when caller matches given String' do
    expect(o).to_receive(:a).with_caller([__FILE__, __LINE__ + 1]*':')
    o.a
  end
  should ':fail when caller does NOT matches given String' do
    expect(o).to_receive(:a).with_caller('blah')
    o.a
  end

  should 'pass when caller validated by given Proc' do
    expect(o).to_receive(:a).with_caller {|callers| callers[0].find {|l| l =~ /#{__FILE__}/}}
    o.a
  end
  should ':fail when caller NOT validated by given Proc' do
    expect(o).to_receive(:a).with_caller { false }
    o.a
  end

  should 'pass when all callers matches given String' do
    expect(o).to_receive(:a, :b).with_caller(__FILE__)
    o.a
    o.b
  end
  should ':fail when at least one caller does NOT match given String' do
    expect(o).to_receive(:a, :b).with_caller('blah')
    o.a
    o.b
  end

  should 'pass when all callers validated by given Proc' do
    expect(o).to_receive(:a, :b).with_caller do |a,b|
      a[0].any? {|l| l =~ /#{__FILE__}/} && b[0].any? {|l| l =~ /#{__FILE__}/}
    end
    o.a
    o.b
  end
  should ':fail when at least one caller NOT validated by given Proc' do
    expect(o).to_receive(:a, :b).with_caller { false }
    o.a
    o.b
  end

  should 'pass when each caller matches its String' do
    expect(o).to_receive(:a, :b).with_caller(__FILE__, [__FILE__, __LINE__ + 2]*':')
    o.a
    o.b
  end
  should ':fail when at least one caller does NOT match its String' do
    expect(o).to_receive(:a, :b).with_caller(__FILE__, 'blah')
    o.a
    o.b
  end
end
