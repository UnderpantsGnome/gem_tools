require 'yaml'
require 'erb'

class GemTools
  def self.load_gems
    config = self.load_config
    unless config[:gems].nil?
      gems = config[:gems].reject {|gem_info| ! gem_info[:load] }
      gems.each do |gem_info|
        if defined?(Kernel::gem)
          gem gem_info[:name], gem_info[:version]
        else
          require_gem gem_info[:name], gem_info[:version]
        end
        require gem_info[:require_name] || gem_info[:name]
      end
    end
  end
  
  def self.load_config
    config_file = File.join(RAILS_ROOT, 'config', 'gems.yml')
    raise 'config/gems.yml is missing' unless File.exist?(config_file)
    YAML.load(ERB.new(File.open(config_file).read).result)
  end
end
