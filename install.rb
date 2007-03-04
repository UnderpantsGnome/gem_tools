require 'fileutils'

config_yaml  = File.join('.', 'config', 'gems.yml')
sample_yaml = File.join('.', 'vendor', 'plugins', 'gem_tools', 'gems.yml.sample')
puts "** Trying to copy gems.yml.sample to #{config_yaml}..."

begin
  if File.exists?(config_yaml)
    puts "You already have a #{config_yaml}.  " +  
         "Please check the sample for new settings or format changes."
    puts "You can find the sample at #{sample_yaml}."
    errors += 1
  else
    FileUtils.cp(sample_yaml, config_yaml)
  end
rescue
  puts "Error copying gems.yml.sample to #{config_yaml}.  Please try by hand."
end
