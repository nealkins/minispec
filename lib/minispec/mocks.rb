module MiniSpec
  module Mocks
    class HashedStub
      def self.with(*)
        raise(ArgumentError, "`with' can not be used on stubs/mocks defined using a Hash")
      end
    end
  end
end

Dir[File.expand_path('../mocks/*.rb', __FILE__)].each {|f| require(f)}
