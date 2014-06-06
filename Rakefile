#
#  2014, Chaofan Li <chaof@tamu.edu>
#

require "rake/extensiontask"
root_dir = Dir.pwd
rake = "rake"
Rake::ExtensionTask.new "ilp" do |ext|
	ext.lib_dir = "lib/ilp"
	ext.source_pattern = "*.c"    
end
Rake::ExtensionTask.new "parser"do |ext|
	ext.lib_dir = "lib/parser"
	ext.source_pattern = "*.c"    
end

task :default => [:compile]
