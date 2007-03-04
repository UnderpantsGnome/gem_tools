require 'yaml'

class GemTools
  def self.load_gems
    config = YAML.load_file(File.join(RAILS_ROOT, 'config', 'gems.yml'))
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
