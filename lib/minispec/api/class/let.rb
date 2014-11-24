module MiniSpec
  module ClassAPI

    # @example
    #   describe Math do
    #     let(:x) { 0.1 }
    #     let(:y) { 1.0 }
    #
    #     test 'x vs y' do
    #       assert(x) < y
    #     end
    #   end
    #
    def let meth, &proc
      proc || raise(ArgumentError, 'block is missing')
      vars[meth] = proc
      define_method(meth) { @__ms__vars[meth] ||= self.instance_exec(&proc) }
    end

    # same as #let except it will compute the value on every run
    def let! meth, &proc
      proc || raise(ArgumentError, 'block is missing')
      vars[meth] = proc
      define_method(meth, &proc)
    end

    def subject &proc
      let(:subject, &proc)
    end

    def vars
      @vars ||= {}
    end

    def import_vars base
      base.vars.each_pair {|v,p| self.let(v, &p)}
    end
    alias import_vars_from import_vars

    def reset_vars
      @vars = {}
    end
  end
end
