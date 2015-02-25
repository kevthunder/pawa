module Pawa
  module Operations
    class ReplaceOperation < Operation
      def findable?
        true
      end

      def start_reg
        if listedParams.first.is_a?(String)
          Regexp.new(Regexp.escape(listedParams.first))
        else
          Regexp.new(listedParams.first)
        end
      end
      def exec(instance)
        
      end
    end
  end
end