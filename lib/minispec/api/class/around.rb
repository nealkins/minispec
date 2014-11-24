module MiniSpec
  module ClassAPI

    # a block to wrap each test evaluation
    #
    # @example
    #   describe SomeClass do
    #
    #     around do |test|
    #       DB.connect
    #       test.run
    #       DB.disconnect
    #     end
    #   end
    #
    def around *matchers, &proc
      proc || raise(ArgumentError, 'block is missing')
      matchers.flatten!
      matchers = [:*] if matchers.empty?
      return if around?.find {|x| x[0] == matchers && x[1].source_location == proc.source_location}
      around?.push([matchers, proc])
    end

    def around? filter = nil
      hooks_filter(@around ||= [], filter)
    end

    def reset_around
      @around = []
    end

    # import `:around` and `:around_all` from base
    def import_around base
      import_instance_variable(:around_all, base)
      base.around?.each {|(m,p)| self.around(m, &p)}
    end
    alias import_around_from import_around

    # a block to wrap all tests evaluation
    def around_all &proc
      proc || raise(ArgumentError, 'block is missing')
      @around_all = proc
    end
    alias around! around_all

    def around_all?
      @around_all
    end

    def reset_around_all
      remove_instance_variable(:@around_all)
    end
  end
end
