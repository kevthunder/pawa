module Pawa
  module Operations
    class ReplaceOperation < Operation
      def findable?
        true
      end

      def parser()
        super.tap do |parser|
          parser.flags.push 'word'
        end
      end
      
      
      def start_reg
        if listedParams.first.is_a?(String)
          Regexp.new(Regexp.escape(listedParams.first))
        else
          Regexp.new(listedParams.first)
        end
      end
      
      def search
        start_reg
      end
      
      def replace
        listedParams[1].tap do |r| 
          unless listedParams.first.is_a?(String)
              r.gsub!(/\$(\d+)/,'\\\\\1')
          end
        end
      end
      
      def valid?(instance)
        instance.my_match =~ start_reg
      end
      
      def exec(instance)
        instance.alter_remaining_text do |txt|
          txt.sub(search,replace)
        end
      end
      
    end
  end
end