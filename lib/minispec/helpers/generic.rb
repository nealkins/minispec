module Minispec

  # checks whether given block produces any output
  #
  # @example
  #   expect { ... }.to_be_silent
  #
  helper :silent, with_context: true do |block, context|
    begin
      $stdout, $stderr = StringIO.new, StringIO.new
      self.instance_exec(&block)
      message = 'Expected block at %s to be silent' % MiniSpec::Utils.source(block)
      out = [$stdout, $stderr].map {|s| s.rewind; v = s.read; s.close; v}.join
      context[:negation] ?
        out.empty? && fail('Not %s' % message) :
        out.empty? || fail(message + ". Instead it did output:\n" + out)
    ensure
      $stdout, $stderr = STDOUT, STDERR
    end
  end
  alias_helper :silent?,       :silent
  alias_helper :is_silent,     :silent
  alias_helper :to_be_silent,  :silent
end
