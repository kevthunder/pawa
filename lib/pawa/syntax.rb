require 'pawa/translation'

module Pawa
  class Syntax
    def initialize(name,config,options)
      @name = name
      @config = config
      @comment = options['comment'] || '#'
      @ext = options['ext'].respond_to?('each') ? options['ext'] : [options['ext'] || [name]]
      @translations_options = options['translations']
      @translations = []
    end
    attr_accessor :name, :config, :comment, :ext, :translations_options
    
    def get_translation_for(syntax)
      @translations.find{ |tr| tr.syntax == syntax} || Translation.new(
        self, 
        syntax, 
        translations_options[syntax.name] || {}
      ).tap do |tr|
        @translations.push(tr)
      end
    end
  end
end