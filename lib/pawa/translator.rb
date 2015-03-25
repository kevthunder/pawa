
module Pawa
  class Translator
    def initialize(target_file)
      @target_file = target_file
      @pointer = 0
    end
    attr_accessor :target_file, :pointer
    def source_file
      target_file.translated_file
    end
    def config
      target_file.translated_file.folder_map.config
    end
    def translation
      @translation ||= source_file.syntax.get_translation_for(target_file.syntax)
    end
    def operations
      @operations ||= translation.operations.clone
    end
    def reg_next_operation(exclude=[])
      return @reg_next_operation if @reg_next_operation and exclude.empty?
      reg_strs = []
      operations.each_with_index do |op, index|
        if op.findable? and not exclude.include?(index)
          reg_strs.push "(?<o#{index}>#{op.start_reg.source})"
        end
      end
      reg_strs.push '(?<eol>\n)'
      Regexp.new(reg_strs.join('|')).tap do |reg|
        @reg_next_operation = reg if exclude.empty?
      end
    end
    def edited_content
      @edited_content ||= source_file.content
    end
    def next_operation
      if edited_content.length > pointer
        match = reg_next_operation.match(edited_content, pointer)
        unless match.nil?
          matched_names = match.names.reject{ |name| match[name].nil? }
          
          self.pointer = match.begin(0)+1
          op = nil
          matched_names.find do |name|
            op = nil
            if name == 'eol'
              op = next_operation
              true
            else
              oper = operations[name[1..-1].to_i]
              unless oper.nil?
                op = oper.instance(self,match,name)
                op.valid?
              end
            end
          end
          if op and op.reparse?
            self.pointer = op.match.begin(0)
          end
          op
        end
      end
    end
    def result
      while op = next_operation
        op.exec
      end
      edited_content
    end
  end
end