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
      def param(key)
        return namedParams[key.to_s] if namedParams.has_key?(key.to_s)
        return listedParams[key] if key.to_s.to_i.to_s == key.to_s and key.to_i < listedParams.length
      end
      def multi_param(key)
        params.select{ |p| p.is_a?(OptParser::NamedParam) && p.name == key.to_s }.map{ |p| p.val }
      end
      def reparse?(instance = nil)
        param(:reparse)
      end
      def parser
        OptParser.new(str_opt).tap do |parser|
          parser.flags.push 'reparse'
        end
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
          init
        end
        def init
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