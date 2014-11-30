module MiniSpec
  class Reporter
    @@indent = " ".freeze

    attr_reader :failed_specs, :failed_tests, :skipped_tests

    def initialize stdout = STDOUT
      @stdout = stdout
      @failed_specs, @failed_tests, @skipped_tests = [], {}, {}
    end

    def summary
      summary__failed_specs
      summary__failed_tests
      summary__skipped_tests
      totals
    end

    def summary__failed_specs
      return if @failed_specs.empty?
      puts
      puts(error('--- Failed Specs ---'))
      last_ex = nil
      @failed_specs.each do |(spec,proc,ex)|
        puts(info(spec))
        puts(info('defined at ' + proc.source_location.join(':')), indent: 2) if proc.is_a?(Proc)
        if last_ex && ex.backtrace == last_ex.backtrace
          puts('see exception above', indent: 2)
          next
        end
        last_ex = ex
        puts(error(ex.message), indent: 2)
        ex.backtrace.each {|l| puts(l, indent: 2)}
        puts
      end
    end

    def summary__skipped_tests
      return if @skipped_tests.empty?
      puts
      puts(warn('--- Skipped Tests ---'))
      @skipped_tests.each_pair do |spec,tests|
        puts(info(spec))
        tests.each do |(test,source_location)|
          puts(warn(test), indent: 2)
          puts(info(MiniSpec::Utils.shorten_source(source_location)), indent: 2)
          puts
        end
        puts
      end
    end

    def summary__failed_tests
      return if @failed_tests.empty?
      puts
      puts(error('--- Failed Tests ---'), '')
      @failed_tests.each_pair do |spec, failures|
        @failed_specs.push(spec) # to be used on #totals__specs
        failures.each do |(test,verb,proc,errors)|
          errors.each do |error|
            error.is_a?(Exception) ?
              exception_details(spec, test, error) :
              failure_details(spec, test, error)
          end
        end
      end
    end

    def totals
      puts
      puts('---')
      totals__specs
      totals__tests
      totals__assertions
    end

    def totals__specs
      print(info('       Specs: '))
      return puts(success(Minispec.specs.size)) if @failed_specs.empty?
      print(info(Minispec.specs.size))
      puts(error('  (%s failed)' % @failed_specs.size))
    end

    def totals__tests
      print(info('       Tests: '))
      print(send(@failed_tests.any? ? :info : :success, Minispec.tests))
      failed  = error('  (%s failed)' % @failed_tests.values.map(&:size).reduce(:+)) if @failed_tests.any?
      skipped = warn('  (%s skipped)' % @skipped_tests.size) if @skipped_tests.any?
      report  = [failed, skipped].compact.join(', ')
      puts(report)
    end

    def totals__assertions
      print(info('  Assertions: '))
      return puts(success(Minispec.assertions)) if @failed_tests.empty?
      print(info(Minispec.assertions))
      puts(error('  (%s failed)' % @failed_tests.values.map(&:size).reduce(:+)))
    end

    def exception_details spec, test, exception
      puts(info([spec, test]*' / '))
      puts(error(exception.message), indent: 2)
      exception.backtrace.each {|l| puts(info(MiniSpec::Utils.shorten_source(l)), indent: 2)}
      puts('---', '')
    end

    def failure_details spec, test, failure
      puts(info([spec, test]*' / '))
      puts(error(callerline(failure[:callers][0])), indent: 2)
      callers(failure[:callers]).each {|l| puts(info(l), indent: 2)}
      puts
      return puts(*failure[:message].split("\n"), '', indent: 2) if failure[:message]
      return if failure[:right_object] == :__ms__right_object

      expected, actual = [:right_object, :left_object].map do |obj|
        str = stringify_object(failure[obj])
        [str =~ /\n/ ? :puts : :print, str]
      end

      send(expected.first, info('           Expected: '))
      print('NOT ') if failure[:negation]
      puts(expected.last)

      send(actual.first, info('             Actual: '))
      puts(actual.last)

      print(info('     Compared using: '))
      puts(failure[:right_method])

      diff = diff(actual.last, expected.last)
      puts(info('               Diff: '), diff) unless diff.empty?
      puts('---', '')
    end

    def mark_as_passed spec, test
      puts(success("OK"))
    end

    def mark_as_skipped spec, test, source_location
      puts(warn("Skipped"))
      (@skipped_tests[spec] ||= []).push([test, source_location])
    end

    def mark_as_failed spec, test, verb, proc, failures
      puts(error("FAILED"))
      (@failed_tests[spec] ||= []).push([test, verb, proc, failures])
    end

    def print(*args); @stdout.print(*indent_lines(*args)) end
    def puts(*args);  @stdout.puts(*indent_lines(*args))  end

    {
      success: [1, 32],
      info:    [0, 36],
      warn:    [0, 35],
      error:   [0, 31]
    }.each_pair do |m,(esc,color)|
      define_method(m) {|str| "\e[%i;%im%s\e[0m" % [esc, color, str]}
    end

    def failures?
      @failed_specs.any? || @failed_tests.any?
    end

    private
    def indent_lines *args
      opts = args.last.is_a?(Hash) ? args.pop : {}
      (i = opts[:indent]) && (i = @@indent*i) && args.map {|l| i + l} || args
    end

    def callers *callers
      callers.flatten.uniq.reverse.map {|l| MiniSpec::Utils.shorten_source(l)}
    end

    def callerline caller
      file, line = caller.match(/^(.+?):(\d+)(?::in `(.*)')?/) {|m| m[1..2]}
      return unless lines = MiniSpec.source_location_cache(file)
      (line = lines[line.to_i - 1]) && line.strip
    end

    def stringify_object obj
      obj.is_a?(String) ? obj : MiniSpec::Utils.pp(obj)
    end

    def diff actual, expected
      @differ ||= MiniSpec::Differ.new(color: true)
      @differ.diff(actual, expected).strip
    end
  end
end
