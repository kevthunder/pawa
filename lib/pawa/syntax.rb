
module Pawa
  class Syntax
    def initialize(name,config,options)
      @name = name
      @config = config
      @comment = options['comment'] || '#'
      @ext = options['ext'].respond_to?('each') ? options['ext'] : [options['ext'] || [name]]
      @translations_options = options['translations']
    end
    attr_accessor :name, :config, :comment, :ext, :translations_options
    
  end
end