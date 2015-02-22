require 'pawa/folder_map'
require 'pawa/syntax'

module Pawa
  class Config
    def initialize(option)
      @option = option
      pp option
      @folder_maps = option['folder'].map{ |opt| FolderMap.new(self,opt)} if option['folder']
      @syntaxes = Hash[ption['syntax'].map{|name,opt| [name.to_sym,Syntax.new(name,self,opt)] } ] if option['syntax']
    end
    attr_accessor :option
    attr_reader :folder_maps, :syntaxes
    def get_syntax_for_ext(ext)
      syntaxes.find{|s| s.ext.include?(ext)}
    end
  
  end
end