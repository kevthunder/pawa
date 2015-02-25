require 'pawa/opt_parser'

module Pawa
  module Operations
    class Operation
      def initialize(str_opt)
        @str_opt = str_opt
      end
      attr_accessor :str_opt
      
      def params
        @params ||= parser.params
      end
      def listedParams
        params.reject{|param| param.is_a?(OptParser::NamedParam)}
      end
      def namedParams
        params.inject({}) do |h,param|
          if param.is_a?(OptParser::NamedParam)
            h[param.name] = param.val
          end
          h
        end
      end
      def parser
        OptParser.new(str_opt)
      end
      def findable?
        false
      end
      
      def instance_cls
        Instance
      end
      def instance(*arguments)
        instance_cls.new(self,*arguments)
      end
      
      class Instance
        def initialize(operation,translator,match,group)
          @operation = operation
          @translator = translator
          @match = match
          @group = group
        end
        attr_accessor :operation, :translator, :match, :group
        def method_missing(method_name, *arguments, &block)
          if @operation.respond_to?(method_name)
            res = @operation.send(method_name, self, *arguments, &block)
          end
        end
        def respond_to_missing?(method_name, include_private = false)
          @operation.respond_to?(method_name) || super
        end
        def my_match
          match[group]
        end
        def alter_remaining_text
          translator.edited_content[match.begin(0)..-1]= yield(translator.edited_content[match.begin(0)..-1])
        end
      end
    end
  end
end