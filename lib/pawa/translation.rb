module Pawa
  class Syntax
    def initialize(source_syntax,target_syntax,options)
      @source_syntax = source_syntax
      @target_syntax = target_syntax
      @options = options
    end
    attr_accessor :source_syntax, :target_syntax, :options
    
  end
end