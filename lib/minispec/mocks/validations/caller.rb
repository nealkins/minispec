class MiniSpec::Mocks::Validations

  def with_caller *expected, &block
    return self if @failed
    assert_given_arguments_match_received_messages(*expected, &block)
    received = received_callers

    if block
      return @base.instance_exec(*received.values, &block) ||
        caller_error!(@expected_messages, block)
    end

    expected = zipper(@expected_messages, expected)
    received.each_pair do |msg,callers|
      # each message should be called from expected caller at least once
      callers.any? {|line| caller_match?(line, expected[msg])} ||
        caller_error!(msg, expected[msg])
    end
    self
  end

  private
  def received_callers
    @expected_messages.inject({}) do |map,msg|
      map.merge(msg => @messages[msg] ? @messages[msg].map {|m| m[:caller]} : [])
    end
  end

  def caller_match? line, pattern
    regexp = pattern.is_a?(Regexp) ? pattern : Regexp.new(Regexp.escape(pattern))
    line.any? {|l| l =~ regexp}
  end

  def caller_error! message, expected
    fail_with("%s received %s message(s) from wrong location.\nCaller does not %s" % [
      pp(@object),
      pp(message),
      expected.is_a?(Proc) ?
        ('pass validation at %s' % pp(source(expected))) :
        ('match %s' % pp(expected))
    ])
  end
end
