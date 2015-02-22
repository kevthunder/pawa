module Pawa
  class TargetFolder
    def initialize(options,folder_map,syntax)
      @folder_map = folder_map
      options = {'folder'=>options} if options.is_a? String 
      @folder = options['folder']
      @tmp = options['tmp'] || File.join(@folder, "_pawa_tmp")
      @syntax = syntax
    end
    attr_accessor :folder_map, :syntax, :folder, :tmp
    
  end
end