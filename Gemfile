source 'https://rubygems.org'

ruby '2.1.0'

# Distribute your app as a gem
# gemspec

# Server requirements
# gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

# Optional JSON codec (faster performance)
# gem 'oj'

# Project requirements
gem 'rake'

# Component requirements
gem 'sinatra'
gem 'sinatra-activerecord'
gem 'sinatra-reloader'
gem 'sinatra-contrib'
gem 'sqlite3'
gem 'haml'
gem 'redcarpet'
gem 'error_handle_filter', :git => 'https://github.com/yaeba88/error_handle_filter.git'

# Test requirements
group :development, :test do
  gem 'rspec', '~> 2.14.1'
  gem 'rack-test', :require => 'rack/test'
  gem 'coveralls', require: false
  gem 'rubocop', require: false
end

