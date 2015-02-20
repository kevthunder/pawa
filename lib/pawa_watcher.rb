require "pawa/version"
require 'guard'
require 'guard/guard'

module Pawa
  class PawaWatcher < Gard
  
    def start
      puts "Pawa #{VERSION} is waching for modifications!\n"
    end
    
    def run_on_change(paths)
      paths.each do |file|
        unless File.basename(file)[0] == "_"
          puts "Changed - #{file}\n"
        end
      end
    end
    
  end
  
end