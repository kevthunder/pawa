
module Pawa
  class FolderMap
    def initialize(config,options)
      @config = config
      @source = options['source']
      @target = options['target']
      @recur = options['recur'] || false
    end
    def target_folders
      @target_folders ||= target.inject([]) do |syntaxes,(sname,opt)|
        s = config.syntaxes.find{ |s| s.name == sname }
        syntaxes.push(TargetFolders.new(opt,self,s)) if s
      end
    end
    def syntaxes
      target_folders.map{ |f| f.syntax}
    end
    def target_for_syntax(syntax)
      target_folders.find{ |f| f.syntax = syntax}.folder
    end
    def tmp_for_syntax(syntax)
      target_folders.find{ |f| f.syntax = syntax}.tmp
    end
    attr_accessor :config, :source, :target, :tmp, :recur, :listener
    def source_files()
      @source_files ||= source_files_with(source)
    end
    def get_source_file(path)
      if @source_files or found = @source_files.find{ |f| f.filename == path}
        found
      else
        TranslatedFile.new(file,self)
      end
    end
    def remove_source_from(file)
      file.tap{ |f| f.slice!(source) }
    end
    def source_files_with(source)
      Dir.entries(source).inject([]) do |list,file|
        if File.directory?(file)
          if recur
            list += source_files_with(file)
          end
        else
          list.push(get_source_file(file))
        end
      end
    end
  end
end