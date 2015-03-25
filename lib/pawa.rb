require "pawa/version"
require 'optparse'
require 'pawa/watcher'
require 'pawa/config'
require 'yaml'
require 'pp'

module Pawa
  class Pawa
     def initialize()
      @options = {}
    end
    attr_accessor :options
    def hello
      puts "Hello, world! This is PAWA #{VERSION}."
    end
    def parseOpt
      OptionParser.new do |opts|
        opts.banner = "Usage: pawa [options]"

        opts.on("-w", "--watch", "Watch files or directories for changes.") do |w|
          options[:watch] = w
        end
        
        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
      
      end.parse!
      options
    end
    def loadConfig(file)
      if File.exist?(file)
        ::Pawa::Config.new(YAML.load_file(file))
      end
    end
    def run!
      # p parseOpt
      # p Dir.pwd
      # p ARGV
      hello
      
      conf = loadConfig('.pawa')
      conf.folder_maps.each do |map|
        map.source_files.each do |file|
          file.translate()
        end
      end
      
      if options[:watch]
        Watcher.new(conf,options).start do |modified, added, removed|
          (modified + added).each do |file|
            file.translate()
          end
          removed.each do |file|
            file.deleteTmp()
          end
        end
      end
    end
  end
end
