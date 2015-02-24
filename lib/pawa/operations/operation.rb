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
      def parser
        OptParser.new(str_opt)
      end
    end
  end
end