require 'yaml'
require File.dirname(__FILE__) + '/../gem_tools'

namespace :gems do
  require 'rubygems'

  desc "Install required gems based on config/gems.yml"
  task :install do
    # defaults to --no-rdoc, set DOCS=(anything) to build docs
    docs = ''
    if ENV['DOCS'].nil?
      docs << '--no-rdoc ' unless (`rdoc -v`).nil?
      docs << '--no-ri ' unless (`ri -v`).nil?
    end

    #grab the list of gems/version to check
    config = GemTools.load_config
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
        cmd = ''
        if gem[:path]
          cmd = "gem install #{gem[:path]} #{source} #{docs} #{gem_config}"
        else
          cmd = "gem install #{gem[:name]} -v #{gem[:version]} -y #{source} #{docs} #{gem_config}"
        end
        ret = system cmd
        # something bad happened, pass on the message
        p $? unless ret
      else
        puts "#{gem[:name]} #{gem[:version]} already installed"
      end
    end
  end
end
