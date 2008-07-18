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
    gem_command = config[:gem_command] || 'gem'
    gem_dash_y = "1.0" > Gem::RubyGemsVersion ? '-y' : ''

    unless gems.nil?
      if RUBY_PLATFORM =~ /MSWIN/
        print "rake gems:install doesn't currently work in windows. The commands you need to install the gems will be printed out for you.\n"
      end

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
            cmd = "#{gem_command} install #{gem[:path]} #{source} #{docs} #{gem_config}"
          else
            cmd = "#{gem_command} install #{gem[:name]} -v #{gem[:version]} #{gem_dash_y} #{source} #{docs} #{gem_config}"
          end

          if RUBY_PLATFORM =~ /MSWIN/
            print cmd
          else
            ret = system cmd
            # something bad happened, pass on the message
            p $? unless ret
          end
        else
          puts "#{gem[:name]} #{gem[:version]} already installed"
        end
      end
    end
  end
end
