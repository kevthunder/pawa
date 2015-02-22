require "pawa/version"
require 'listen'

module Pawa
  class Watcher
    def initialize(config,options)
      @config = config
      @target = options['target']
      @tmp = options['tmp'] || File.join(@target, "_pawa_tmp")
      @recur = options['recur'] || false
    end
    attr_accessor :config
  
    def start
      puts "Pawa #{VERSION} is waching for modifications!\n"
      
      conf.folder_maps.each do |map|
        map.listener = Listen.to(map.source) do |modified, added, removed|
          yield(
            modified.map{ |f| map.get_source_file(f).invalidate }, 
            added.map{    |f| map.get_source_file(f).invalidate }, 
            removed.map{  |f| map.get_source_file(f).invalidate }
          )
          puts "modified absolute path: #{modified}"
          puts "added absolute path: #{added}"
          puts "removed absolute path: #{removed}"
        end
        map.listener.start # not blocking
      end
      sleep
    end
    
  end
  
end