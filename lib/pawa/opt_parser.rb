module Pawa
  class OptParser
    def initialize(str_opt)
      @str_opt = str_opt
    end
    attr_accessor :str_opt, :pos, :inStr, :inReg, :param, :name, :chr
    def testSyms
      [:end_of_arg,:string_delimiter,:reg_delimiter,:named_param,:any_chr]
    end
    def parse
      init
      until end?
        step
      end
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
      self.inStr = self.inReg = false
      self.param = ''
      self.name = self.chr = nil
    end
    def end?
      pos + 1 >= str_opt.length
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
    def in_escaped?
      inStr or inReg
    end
    
    def end_of_arg
      if chr == ' ' and !in_escaped?
        if param.length > 0 or !param.is_a? String
          if name.nil
            @params.push(param)
          else
            self.named.push([name,param])
          end
        end
        self.param = ''
        self.name = nil
        true
      end
    end
    
    def string_delimiter
      if chr == '"' and (inStr or !in_escaped?) 
        if prevChr != '\\'
          self.inStr =! inStr
        else
          str_opt[pos-1..pos] = chr
        end
        true
      end
    end
    
    def reg_delimiter
      if chr == '/' and (inReg or param.length == 0) and prevChr != '\\'
        if inReg and nextChr == ' '
          self.param = Regexp.new(param)
        else
          self.param = chr + param + chr
        end
        self.inReg =! inReg
        true
      end
    end
    
    def named_param
      if chr == ':' and name.nil? and !in_escaped?
        self.name = param
        self.param = ''
      end
    end
    
    def any_chr
      self.param += chr
      true
    end
  end
end