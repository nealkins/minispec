module MiniSpec
  module InstanceAPI

    # stubbing given method and keeps original visibility
    #
    # if a block given, it will receive original method as first argument
    # and any passed parameters as rest arguments.
    #
    # @example make Some::Remote::API.call to return success
    #   stub(Some::Remote::API, :call) { :success }
    #
    # @example call original
    #   stub(obj, :a) {|orig| orig.call}
    #
    # @param object object to define stub on
    # @param stub  method to be stubbed.
    #     if a Hash given, keys will be stubbed methods and values return values
    # @param [Proc] &proc  block to be yielded when stub called
    # @return MiniSpec::Mocks::Stub instance
    #
    def stub object, stub, visibility = nil, &proc
      [Symbol, String, Hash].include?(stub.class) ||
        raise(ArgumentError, 'a Symbol, String or Hash expected')

      if stub.is_a?(Hash)
        return hash_stub(object, stub, visibility, &proc)
      elsif stub =~ /\./
        return chained_stub(object, stub, visibility, &proc)
      end

      visibility ||= MiniSpec::Utils.method_visibility(object, stub) || :public
      stubs = (@__ms__stubs[object.__id__] ||= {})
      stubs[stub] ||= MiniSpec::Mocks::Stub.new(object, @__ms__messages, @__ms__stubs__originals)
      stubs[stub].stubify(stub, visibility, &proc)
      stubs[stub]
    end

    # @example  make `obj.a` to return :x and `obj.b` to return :y
    #   stub(obj, :a => :x, :b => :y)
    #
    def hash_stub object, hash, visibility = nil, &proc
      proc && raise(ArgumentError, 'Both Hash and block given. Please use either one.')
      hash.each_pair do |s,v|
        stub(object, s, visibility, &proc {v})
      end
      return MiniSpec::Mocks::HashedStub
    end

    # @example  define a chained stub
    #   stub(obj, 'a.b.c')
    #
    def chained_stub object, chain, visibility = nil, &block
      chain = chain.split('.').map(&:to_sym)
      base, last_index = self, chain.size - 1
      chain.each_with_index do |m,i|
        next_object = (i == last_index ? nil : Struct.new(chain[i+1]).new)
        return stub(object, m, visibility, &block) unless next_object
        stub(object, m, visibility) { next_object }
        object = next_object
      end
    end

    # same as `stub` except it defines multiple stubs at once
    #
    # @param object
    # @param *stubs
    # @param &proc
    # @return MiniSpec::Mocks::MultipleStubsProxy instance
    #
    def stubs object, *stubs, &proc
      MiniSpec::Mocks::MultipleStubsProxy.new(stubs.map {|s| stub(object, s, &proc)})
    end

    # stubbing a method and enforce public visibility on it.
    # that's it, even if method exists and it is not public,
    # after stubbing it will become public.
    def public_stub object, stub, &proc
      stub(object, stub, :public, &proc)
    end

    def public_stubs object, *stubs, &proc
      MiniSpec::Mocks::MultipleStubsProxy.new(stubs.map {|s| public_stub(object, s, &proc)})
    end

    # same as stub except it defines protected stubs
    # (@see #stub)
    def protected_stub object, stub, &proc
      stub(object, stub, :protected, &proc)
    end

    def protected_stubs object, *stubs, &proc
      MiniSpec::Mocks::MultipleStubsProxy.new(stubs.map {|s| protected_stub(object, s, &proc)})
    end

    # same as stub except it defines private stubs
    # (@see #stub)
    def private_stub object, stub, &proc
      stub(object, stub, :private, &proc)
    end

    def private_stubs object, *stubs, &proc
      MiniSpec::Mocks::MultipleStubsProxy.new(stubs.map {|s| private_stub(object, s, &proc)})
    end
  end
end
