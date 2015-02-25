module Pawa
  class OptParser
    def initialize(str_opt)
      @str_opt = str_opt
    end
    attr_accessor :str_opt, :pos, :context, :param, :name, :chr, :list
    def testSymsByContext
      {
        default: [:end_of_arg,:list_delemiter,:start_of_delimited,:any_chr],
        started: [:end_of_arg,:list_delemiter,:named_param,:any_chr],
        delimited: [:escaped_delimiter,:end_of_delimited,:any_chr],
        ended: [:end_of_arg,:list_delemiter,:revert_to_string]
      }
    end
    def testSyms
      testSymsByContext[context]
    end
    def parse
      init
      until end?
        step
      end
      end_of_arg
      @params
    end
    def step
      self.next
      testSyms.any?{ |sym| self.send(sym) }
    end
    def params
      @params ||= parse
    end
    def init
      @params = []
      self.pos = -1
      self.param = ''
      self.name = self.chr = nil
      self.context = :default
      self.list = []
    end
    def end?
      pos >= str_opt.length
    end
    def prevChr
      unless pos == 0
        str_opt[pos-1]
      end
    end
    def nextChr
      unless pos + 2 >= str_opt.length
        str_opt[pos+1]
      end
    end
    def next
      self.pos += 1
      self.chr = str_opt[pos]
    end
    
    def emptyParam?
      param.is_a?(String) and param.length == 0
    end
    
    def end_of_arg
      if end? or chr == ' '
        unless emptyParam?
          if list.length > 0
            self.param = list + [param]
          end
          if param.respond_to?(:final)
            self.param = param.final
          end
          if name.nil?
            @params.push(param)
          else
            @params.push(NamedParam.new(name,param))
          end
          self.list = []
        end
        self.param = ''
        self.name = nil
        self.context = :default
        true
      end
    end
    
    def list_delemiter
      if chr == ','
        if param.respond_to?(:final)
          self.param = param.final
        end
        list.push(param)
        self.param = ''
        self.context = :default
        true
      end
    end
    def start_of_delimited
      types = {
        '"' => ExplicitStringParam,
        "'" => ExplicitStringParam,
        '/' => RegParam,
      }
      if types.has_key?(chr)
        self.context = :delimited
        self.param = types[chr].new('',chr)
        true
      end
    end
    def escaped_delimiter
      if chr == self.param.delimiter and prevChr == '\\'
        self.param.str = param.str[0..-2] + chr
        true
      end
    end
    def end_of_delimited
      if chr == self.param.delimiter
        self.context = :ended
      end
    end
    
    def named_param
      if chr == ':' and name.nil?
        self.name = param
        self.param = ''
        self.context = :default
        true
      end
    end
    
    def revert_to_string
      if param.respond_to?(:revert_to_string)
        self.param = param.revert_to_string
      elsif
        self.param = self.param.to_str
      end
      true
    end
    
    def any_chr
      self.context = :started if context == :default
      unless chr.nil?
        self.param += chr
        true
      end
    end
    
    
    class NamedParam
      def initialize(name,val)
        @name = name
        @val = val
      end
      attr_accessor :name, :val
      def revert_to_string
        name +':'+ val
      end
    end
    class DelimitedParam
      def initialize(str,delimiter)
        @str = str
        @delimiter = delimiter
      end
      attr_accessor :str,:delimiter
      def +(val)
        self.class.new(str+val,delimiter)
      end
      def revert_to_string
        delimiter+str.gsub(delimiter,'\\'+delimiter)+delimiter
      end
      def final
        str
      end
    end
    class RegParam < DelimitedParam
      def final
        Regexp.new(str)
      end
    end
    class ExplicitStringParam < DelimitedParam
    end
  end
end