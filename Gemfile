# To include these dependencies in your applition, place this in the /Gemfile:
#
# #  To setup run:  gem bundle --build-options build_options.yml
# 
# skyline_gemfile = File.join(File.dirname(__FILE__), 'vendor', 'plugins', 'skyline', 'Gemfile')
# instance_eval(File.read(skyline_gemfile), skyline_gemfile)
# 
# bundle_path "vendor/bundler_gems"
# 
# disable_system_gems


source "http://gems.github.com"

gem "rails", "2.3.5"
gem "rack", "1.0.1"
gem "mysql", "2.8.1"

# When changing these, make sure you also change:
#
#   * config/initializers/dependencies.rb !!
#   * Rakefile
#
# Otherwise the gem will not work!

gem "polyglot", "0.2.6"
gem "sprockets", "1.0.2"
gem "mime-types", "1.16",                   :require_as => "mime/types"
gem "rmagick", "2.9.1",                     :require_as => "RMagick"
gem "hpricot", "0.8.2",                     :require_as => "hpricot"
gem "guid", "0.1.1"
gem "will_paginate", "~>2.3.11"
gem "seed-fu", "~>1.2.0"

# If you want to use the (outdated) rsolr interface, please 
# add the following two gems to your implementation Gemfile.
#
# gem "curb", "0.4.2.0"
# gem "mwmitchell-rsolr", "0.8.8",            :require_as => "rsolr"
# gem "mwmitchell-rsolr-ext", "0.7.35",       :require_as => "rsolr-ext"

only :test do
  gem "thoughtbot-factory_girl", "1.2.0",   :require_as => "factory_girl"
  gem "thoughtbot-shoulda", "2.9.1",        :require_as => "shoulda"
end
