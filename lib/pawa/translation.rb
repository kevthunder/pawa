module Pawa
  class Syntax
    def initialize(syntax,options)
      @syntax = syntax
      @options = options
    end
    attr_accessor :syntax, :options
    
  end
end