require 'fileutils'
require 'pawa/translator'

module Pawa
  class TargetFile
    def initialize(translated_file,syntax)
      @translated_file = translated_file
      @syntax = syntax
    end
    attr_accessor :translated_file, :syntax
    
    def invalidate
      @content = nil
      self
    end
    
    def content
      @content ||= File.read(filename)
    end
    
    def folder_map
      translated_file.folder_map
    end
    
    def filename
      @filename ||= File.join(folder_map.target_for_syntax(syntax),rel_filename)
    end
    
    def tmp_filename
      @tmp_filename ||= File.join(folder_map.tmp_for_syntax(syntax),rel_filename)
    end
    
    def rel_filename
      @rel_filename ||= File.join(File.dirname(translated_file.rel_filename), File.basename(translated_file.filename,'.*') + '.' + syntax.ext.first)
    end
    
    def create_tmp_folder
      unless File.exist?(File.dirname(tmp_filename))
        FileUtils::mkdir_p File.dirname(tmp_filename)
      end
    end
    
    def translate
      create_tmp_folder
      File.write(tmp_filename, translated_content)
      p "writed #{tmp_filename}"
    end
    
    def translated_content
      Translator.new(self).result
    end
    
    def deleteTmp
      File.delete(tmp_filename)
    end
  end
end