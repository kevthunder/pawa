
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
      return @reg_next_operation if @reg_next_operation and exclude.empty? and @reg_for_nb == operations.length
      reg_strs = []
      operations.each_with_index do |op, index|
        if op.findable? and not exclude.include?(index)
          reg_strs.push "(?<o#{index}>#{op.start_reg.source})"
        end
      end
      reg_strs.push '(?<eol>\n)'
      Regexp.new(reg_strs.join('|')).tap do |reg|
        @reg_next_operation = reg if exclude.empty?
        @reg_for_nb = operations.length
      end
    end
    def edited_content
      @edited_content ||= source_file.content
    end
    def check_new_operation
      if m = match_pawa_comment(pointer)
        operations.unshift(Operations::Operation.new_from_string(m[:op]).tap do |op|
          op.startPos = pointer
        end)
        @reg_for_nb = nil
        edited_content.slice!(m.begin(:comment)...m.end(:comment))
      end
    end
    def check_expired_operations
      operations.reject!{ |op| op.expired?(self) }
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
              check_expired_operations
              check_new_operation
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
    def match_to_eol(pos)
      edited_content.match(/(.*)\r?\n/,pos)
    end
    def cut_to_eol(pos)
      if m = edited_content.match(/\n/,pos)
        edited_content.slice!(pos...m.end(0))
      end
    end
    def match_pawa_comment(pos)
      rcmt = Regexp.escape(source_file.syntax.comment)
      edited_content.match(/\G(?<before>.*)(?<comment>(?<prefix>#{rcmt}\s+)\[pawa\s*(?<lang>[^\]]*)\](?<op>.*))$/,pos)
    end
    def match_pawa_continue(last_match,pos)
      prefix = Regexp.escape(last_match[:prefix])
      edited_content.match(/\G\s{#{last_match[:before].length}}#{prefix}\s+(?<op>.*)$/,pos)
    end
    def parse_header_operations
      ops = []
      while m = match_pawa_comment(pointer)
        lang_ok = (m[:lang].empty? or m[:lang] == target_file.syntax.name)
        if lang_ok and !m[:op].empty?
          ops.push(Operations::Operation.new_from_string(m[:op]))
        end
        cut_to_eol(pointer)
        while mc = match_pawa_continue(m,pointer)
          if lang_ok and !mc[:op].empty?
            ops.push(Operations::Operation.new_from_string(mc[:op]))
          end
          cut_to_eol(pointer)
        end
      end
      @operations = ops + operations
    end
    def result
      parse_header_operations
      while op = next_operation
        op.exec
      end
      edited_content
    end
  end
end