require_relative 'lib/gem_loader'
require_relative 'lib/procesing/parser'
require_relative 'lib/procesing/storing'
require_relative 'lib/procesing/filter'
#require_relative 'lib/profile'

# Coordinating the creation of the clean file
class CleanFile
  def initialize(files_paths)
    @path_to_source = files_paths[0]
    @path_to_dest = files_paths[1]
    GemLoader.new.installl_missing_gem
  end

  def run
    file_name = @path_to_source.split('/').last
    extension_to_source = file_extension(file_name)
    puts "read file: #{file_name}"
    raw_profiles = Parser.new(@path_to_source, extension_to_source).profiles
    filter_profiles = Filter.new(raw_profiles).profiles
    Storing.new(@path_to_dest, extension_to_source, filter_profiles, file_name)
  end

  private

  def find_extension(path, file)
    Dir.entries(path).select { |f| f.include?(file) }[0].split('.')[1]
  end

  def file_extension(file_name)
    dir_path = @path_to_source.gsub(file_name, '')
    find_extension(dir_path, file_name)
  end
end

puts
puts '************************************************'
puts
files_paths = []
ARGV.each do |a|
  files_paths << a
end

CleanFile.new(files_paths).run

puts '************************************************'
