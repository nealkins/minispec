# Borrowed and adapted from Pry - https://github.com/pry/pry

# Copyright (c) 2013 John Mair (banisterfiend)
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module MiniSpec
  module Utils
    def pp obj
      out = ''
      q = MiniSpec::PrettyPrint.new(out)
      q.guard_inspect_key { q.pp(obj) }
      q.flush
      out
    end
  end

  class PrettyPrint < ::PP
    def text str, width = str.length
      if str.include?("\e[")
        super "%s\e[0m" % str, width
      elsif str.start_with?('#<') || str == '=' || str == '>'
        super highlight_object_literal(str), width
      else
        super CodeRay.scan(str, :ruby).term, width
      end
    end

    private
    def highlight_object_literal object_literal
      "\e[32m%s\e[0m" % object_literal
    end
  end
end
