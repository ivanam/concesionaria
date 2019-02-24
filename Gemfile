source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.2'
# Use postgresql as the database for Active Record
gem 'mysql2'
# Use Puma as the app server
gem 'puma', '~> 3.0'

gem 'rake', github: 'ruby/rake'

gem 'rvm-capistrano'

gem 'concurrent-ruby','~> 1.1.3' ,require: 'concurrent'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

gem 'week_of_month'

gem "autocomplete-off"

gem "paperclip", "~> 5.0.0.beta1"

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'bootstrap-sass', '~> 3.3.7'
#font-awesome
gem 'font-awesome-sass', '~> 5.0.9'

gem 'autoprefixer-rails'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '2.5.3'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'jquery_datepicker', github: 'foodforarabbit/jquery_datepicker'

gem 'bootstrap-datepicker-rails'

gem 'twitter-bootstrap-rails', github: 'seyhunak/twitter-bootstrap-rails', branch: 'bootstrap3'

#gem 'bootstrap-generators', :git => 'git://github.com/decioferreira/bootstrap-generators.git'

gem 'bootstrap-editable-rails'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development



gem 'wicked_pdf'

gem 'responders'

gem 'wkhtmltopdf-binary'


#--------------------------------- Users ---------------------------------

gem 'devise'

gem 'cancancan'

gem 'rolify'

#-------------------------------------------------------------------------
#--------------------------------- Charts ---------------------------------

gem 'chartjs-ror'

#-------------------------------------------------------------------------

#--------------------------------- Icons ---------------------------------

gem 'font-awesome-rails'

#-------------------------------------------------------------------------
#-------------------------------- Formularios ----------------------------

gem "nested_form"

gem 'select2-rails'

gem 'unicorn'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'capistrano', '~> 3.11'
gem 'capistrano-rails', '~> 1.4'
gem 'capistrano-passenger', '~> 0.2.0'
gem 'capistrano-rbenv', '~> 2.1', '>= 2.1.4'
