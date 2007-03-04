require 'yaml'

namespace :gems do
  require 'rubygems'

  desc "Install required gems based on config/gems.yml"
  task :install do
    # defaults to --no-rdoc, set DOCS=(anything) to build docs
    docs = (ENV['DOCS'].nil? ? '--no-rdoc' : '')
    #grab the list of gems/version to check
    config = YAML.load_file(File.join('config', 'gems.yml'))
    gems = config[:gems]

    gems.each do |gem|
      # load the gem spec
      gem_spec = YAML.load(`gem spec #{gem[:name]} 2> /dev/null`)
      gem_loaded = false
      begin
        gem_loaded = require_gem gem[:name], gem[:version]
      rescue Exception
      end

      # if forced
      # or there is no gem_spec
      # or the spec version doesn't match the required version
      # or require_gem returns false
      #    (return false also happens if the gem has already been loaded)
      if ! ENV['FORCE'].nil? ||
         ! gem_spec ||
         (gem_spec.version.version != gem[:version] && ! gem_loaded)
        gem_config = gem[:config] ? " -- #{gem[:config]}" : ''
        source = gem[:source] || config[:source] || nil
        source = "--source #{source}" if source
        ret = system "gem install #{gem[:name]} -v #{gem[:version]} -y #{source} #{docs} #{gem_config}"
        # something bad happened, pass on the message
        p $? unless ret
      else
        puts "#{gem[:name]} #{gem[:version]} already installed"
      end
    end
  end
end
