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
        listedParams[1]
      end
      
      
      def reparse?(instance = nil)
        return true if replace.empty?
        super
      end
      
      def valid?(instance)
        instance.my_match =~ start_reg
      end
      
      def alter_text(txt)
        alts = Alterations.new(txt,search)
        multi_param(:alter).each do |args|
          alts.new_group(args)
        end
        txt.sub(search,alts.process_replace(replace))
      end
      
      def exec(instance)
        instance.alter_remaining_text do |txt|
          alter_text(txt)
        end
      end
      
      class Alterations
        def initialize(txt,search)
          @txt, @search = txt,search
          @altered_groups = []
        end
        attr_accessor :altered_groups, :txt, :search 
        
        def new_group(args)
          AlteredGroup.new(args,self)
        end
        
        def process_replace(replace)
          replace = replace.gsub(/\$(\d+)/,'\\\\\1')
          altered_groups.each do |g|
            replace = g.apply(replace)
          end
          replace
        end
      end
      
      class AlteredGroup
        def initialize(args,alts)
          @alts = alts
          @from, @name, @search, @replace = args
          @from = alts.process_replace(from)
          @replace = alts.process_replace(replace)
          alts.altered_groups.push(self)
        end
        attr_accessor :alts, :from, :name, :search, :replace 
        
        def subject
          alts.txt.match(alts.search)[0].sub(alts.search,from)
        end
        
        def result
          subject.gsub(search,replace)
        end
        
        def apply(txt)
          txt.gsub("${#{name}}",result)
        end
        
      end
      
    end
  end
end