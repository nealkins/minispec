module MiniSpec
  module Utils
    extend self

    def undefine_method object, method
      return unless method_defined?(object, method)
      object.instance_eval('undef :%s' % method)
    end

    # @api private
    # checking whether correct arguments passed to proxy methods.
    #
    # @raise [ArgumentError] if more than two arguments given
    # @raise [ArgumentError] if both argument and block given
    #
    def valid_proxy_arguments? left_method, *args, &proc
      args.size > 2 && raise(ArgumentError, '#%s - wrong number of arguments, %i for 0..2' % [left_method, args.size])
      args.size > 0 && proc && raise(ArgumentError, '#%s accepts either arguments or a block, not both' % left_method)
    end

    # @example
    #   received = [:a, :b, :c]
    #   expected = [1]
    #   => {:a=>1, :b=>1, :c=>1}
    #
    # @example
    #   received = [:a, :b, :c]
    #   expected = []
    #   => {:a=>nil, :b=>nil, :c=>nil}
    #
    # @example
    #   received = [:a, :b, :c]
    #   expected = [1, 2]
    #   => {:a=>1, :b=>2, :c=>2}
    #
    # @example
    #   received = [:a, :b, :c]
    #   expected = [1, 2, 3, 4]
    #   => {:a=>1, :b=>2, :c=>3}
    #
    # @param received [Array]
    # @param expected [Array]
    # @return [Hash]
    #
    def zipper received, expected
      result = {}
      received.uniq.each_with_index do |m,i|
        result[m] = expected[i] || expected[i-1] || expected[0]
      end
      result
    end

    # determines method's visibility
    #
    # @param object
    # @param method
    # @return [Symbol] or nil
    #
    def method_visibility object, method
      {
           public: :public_methods,
        protected: :protected_methods,
          private: :private_methods
      }.each_pair do |v,m|
        return v if object.send(m).include?(method)
      end
      nil
    end
    alias method_defined? method_visibility

    def array_elements_map array
      # borrowed from thoughtbot/shoulda
      array.inject({}) {|h,e| h[e] ||= array.select { |i| i == e }.size; h}
    end

    def source proc
      shorten_source(proc.source_location*':')
    end

    # get rid of Dir.pwd from given path
    def shorten_source source
      source.to_s.sub(/\A#{Dir.pwd}\/?/, '')
    end

    # checks whether given label matches any matcher.
    # even if label matched, it will return `false` if label matches some rejector.
    #
    # @param label
    # @param matchers  an `Array` of matchers and rejectors.
    #   matchers contained as hashes, rejectors as arrays.
    # @return `true` or `false`
    #
    def any_match? label, matchers
      reject, select = matchers.partition {|m| m.is_a?(Hash)}

      rejected = rejected?(label, reject)
      if select.any?
        return select.find {|x| (x == :*) || match?(label, x)} && !rejected
      end
      !rejected
    end

    # checks whether given label matches any rejector.
    #
    # @param label
    # @param reject  an `Array` of rejectors, each being a `Hash` containing `:except` key
    # @return `true` or `false`
    #
    def rejected? label, reject
      if reject.any? && (x = reject.first[:except])
        if x.is_a?(Array)
          return true if x.find {|m| match?(label, m)}
        else
          return true if match?(label, x)
        end
      end
      false
    end

    # compare given label to given expression.
    # if expression is a `Regexp` comparing using `=~`.
    # otherwise `==` are used
    #
    # @param label
    # @param x
    # @return `true` or `false`
    #
    def match? label, x
      x.is_a?(Regexp) ? label.to_s =~ x : label == x
    end
  end
end

Dir[File.expand_path('../utils/**/*.rb', __FILE__)].each {|f| require(f)}
