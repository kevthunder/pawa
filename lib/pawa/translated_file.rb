require 'pawa/target_file'
require 'byebug'

module Pawa
  class TranslatedFile
    def initialize(filename,folder_map)
      @filename = filename
      @folder_map = folder_map
    end
    attr_accessor :filename, :folder_map
    
    def invalidate
      @content = nil
      @target_content = nil
      self
    end
    
    def ext 
      File.extname(filename)[1..-1]
    end
    
    def syntax
      @syntax ||= folder_map.config.get_syntax_for_ext(ext)
    end 
    
    def target_files
      @target_files ||= folder_map.syntaxes.map do |syntax|
        TargetFile.new(self,syntax)
      end
    end
    
    def content
      @content ||= File.read(filename)
    end
    
    def rel_filename
      @rel_filename ||= folder_map.remove_source_from(filename)
    end
    
    def translate
      target_files.each do |f|
        f.translate
      end
    end
    
    def deleteTmp
      target_files.each do |f|
        f.deleteTmp
      end
    end
  end
end