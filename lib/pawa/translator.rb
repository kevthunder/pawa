
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
    def translation
      @translation ||= source_file.syntax.get_translation_for(target_file.syntax)
    end
    def operations
      @operations ||= translation.operations.clone
    end
    def reg_next_operation(exclude=[])
      reg_strs = []
      operations.each_with_index do |op, index|
        if op.findable? and not exclude.include?(index)
          reg_str.push "(?<o#{index}>#{op.start_reg})"
        end
      end
      reg_str.push '(?<eol>\n)'
      reg_strs.join('|')
    end
    def edited_content
      @edited_content ||= source_file.content
    end
    def next_operation
      if edited_content.length > pointer
        match = reg_next_operation.match(edited_content, pointer)
        unless match.nil?
          matched_names = match.names.reject{ |name| match[name].nil? }
          pointer = match.start(0)+1
          name = matched_names.first
          if name == 'eol'
          else
            name.slice|(0)
            op = operations[name.to_i]
            op.instance(self,match) unless op.nil?
          end
        end
      end
    end
    def result
      # while op = next_operation
        # op.exec
      # end
      edited_content
    end
  end
end