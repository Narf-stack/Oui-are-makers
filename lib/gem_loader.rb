require 'bundler/inline'

# Load the needed gem
class GemLoader
  def test_gem(gem_name)
    begin
      require gem_name
    rescue LoadError => e
      nil
    end
    e.class
  end

  def install_rubyxl
    gemfile do
      source 'https://rubygems.org'
      gem 'rubyXL', '~> 2.2.0'
    end
  end

  def install_spreadsheet
    gemfile do
      source 'https://rubygems.org'
      gem 'spreadsheet', '~> 1.2.6'
    end
  end

  def install_json
    gemfile do
      source 'https://rubygems.org'
      gem 'json', '~> 2.3'
    end
  end

  def install_selenium
    gemfile do
      source 'https://rubygems.org'
      gem 'selenium-webdriver', '~> 3.142', '>= 3.142.7'
    end
  end

  def installl_missing_gem
    install_rubyxl if test_gem('rubyXL') == LoadError
    install_spreadsheet if test_gem('spreadsheet') == LoadError
    install_json if test_gem('json') == LoadError
    install_selenium if test_gem('selenium-webdriver') == LoadError
  end
end
