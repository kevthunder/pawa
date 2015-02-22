require "pawa/version"
require 'listen'

module Pawa
  class Watcher
    def initialize(config,options)
      @config = config
      @recur = options['recur'] || false
    end
    attr_accessor :config
  
    def start
      if config.folder_maps.any?
        puts "Pawa #{VERSION} is waching for modifications!\n"
        
        config.folder_maps.each do |map|
          map.listener = Listen.to(map.source) do |modified, added, removed|
            puts "modified absolute path: #{modified}"
            puts "added absolute path: #{added}"
            puts "removed absolute path: #{removed}"
            yield(
              modified.map{ |f| map.get_source_file(f).invalidate }, 
              added.map{    |f| map.get_source_file(f).invalidate }, 
              removed.map{  |f| map.get_source_file(f).invalidate }
            )
          end
          map.listener.start # not blocking
        end
        sleep
      end
    end
    
  end
  
end