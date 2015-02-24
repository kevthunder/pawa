require 'pawa/folder_map'
require 'pawa/syntax'

module Pawa
  class Config
    def initialize(option)
      @option = option
      pp option
    end
    attr_accessor :option
    
    def folder_maps
      @folder_maps ||= if option['folder'] 
        option['folder'].map{ |opt| FolderMap.new(self,opt)} 
      else
        []
      end
    end
    
    def syntaxes
      @syntaxes ||= if option['syntax']
        option['syntax'].map { |name,opt| Syntax.new(name,self,opt) } 
      else
        []
      end
    end
    
    def get_syntax_for_ext(ext)
      syntaxes.find{|s| s.ext.include?(ext)}
    end
  
  end
end