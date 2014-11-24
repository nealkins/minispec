class MinispecTest
  class ProxifiedAsserts < self
    include MinispecTest::Asserts::Mixin

    unit = Unit.new
    unit.__ms__prepare_test
    proxied_methods = [
      [STRING, [:==, :===, :eql?, :equal?, :empty?, :!=, :=~, :<=, :include?, :start_with?, :frozen?]],
      [TAINTED_STRING, [:tainted?]],
      [UNTRUSTED_STRING, [:untrusted?]],
      [ARRAY,  [:!=, :any?, :all?, :empty?, :instance_of?, :respond_to?, :include?, :frozen?, :kind_of?]],
      [HASH,   [:any?, :all?, :is_a?, :empty?, :respond_to?]],
      [NIL,    [:nil?]]
    ]

    proxied_methods.each do |(object, methods)|
      methods.each do |method|
        unit.proxy(object, method)

        test = 'test_ %s#%s received through proxy' % [object.inspect, method]
        define_method test do
          messages = Messages.select do |m|
            m[:object] == object && m[:method] == method
          end
          assert_operator messages.size, :>, 0
        end
      end
    end

    result = msrun(Unit)
    Status = result.status
    Messages = unit.__ms__mocks__messages_copy
  end
end
