# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'codebreaker_rg'
gem 'i18n'
gem 'rack'

group :development do
  gem 'fasterer'
  gem 'pry'
  gem 'rubocop', require: false
  gem 'rubocop-rspec'
end

group :test do
  gem 'rack-test'
  gem 'rspec'
  gem 'simplecov'
end
