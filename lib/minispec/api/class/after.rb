module MiniSpec
  module ClassAPI

    # same as `before` except it will run after matched tests.
    # @note `after` hooks will run even on failed tests.
    #       however it wont run if some exception arise inside test.
    def after *matchers, &proc
      proc || raise(ArgumentError, 'block is missing')
      matchers.flatten!
      matchers = [:*] if matchers.empty?
      return if after?.find {|x| x[0] == matchers && x[1].source_location == proc.source_location}
      after?.push([matchers, proc])
    end

    def after? filter = nil
      hooks_filter(@after ||= [], filter)
    end

    def reset_after
      @after = []
    end

    # import `:after` and `:after_all` hooks from base
    def import_after base
      import_instance_variable(:after_all, base)
      base.after?.each {|(m,p)| self.after(m, &p)}
    end
    alias import_after_from import_after

    # code to run once after all tests finished.
    # this callback will run only once.
    # for callbacks that runs after any test @see #after
    #
    # @note this callback will run even if there are failed tests.
    def after_all &proc
      proc || raise(ArgumentError, 'block is missing')
      @after_all = proc
    end
    alias after! after_all

    def after_all?
      @after_all
    end

    def reset_after_all
      remove_instance_variable(:@after_all)
    end
  end
end
