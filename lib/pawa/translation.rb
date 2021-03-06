require 'pawa/operations/operation'
Dir[File.join(File.dirname(__FILE__),'operations','*.rb')].each {|file| require file }

module Pawa
  class Translation
    def initialize(source_syntax,target_syntax,options)
      @source_syntax = source_syntax
      @target_syntax = target_syntax
      @options = options
    end
    attr_accessor :source_syntax, :target_syntax, :options
    def operations
      @operations ||= options.inject([]) do |list, (key,val)|
        if val.respond_to?('each') and cls = Operations::Operation.get_op_class_from_key(key)
          val.each do |opt|
            list.push(cls.new(opt))
          end
        end
        list
      end
    end
    
  end
end