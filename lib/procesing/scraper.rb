require 'selenium-webdriver'
require 'json'

# updating data by scraping method
class Scraper
  LINKEDIN_MAIL = ''.freeze
  LINKEDIN_PWD = ''.freeze

  def initialize(profiles)
    @driver = Selenium::WebDriver.for :chrome #:firefox
    @profiles = profiles
    run
  end

  def run
    log_in_linkedin
    @profiles.each do |profile|
      profile.cpny_size = find_size(profile) if profile.cpny_size.empty?
      # profile.job = find_job(profile) if profile.job.class == NilClass
    end
    @driver.close
  end

  private

  def log_in_linkedin
    @driver.navigate.to('https://www.linkedin.com/')
    sleep(8)
    mail_tag = '.input__field.input__field--with-label[type="text"]'
    mail_elem = find_element(mail_tag)
    mail_elem.send_keys(LINKEDIN_MAIL)
    pwd_tag = '.input__field.input__field--with-label[type="password"]'
    pwd_elem = find_element(pwd_tag)
    pwd_elem.send_keys(LINKEDIN_PWD)
    sleep(5)
    find_element('.sign-in-form__submit-btn').click
  end

  def find_element(tag)
    element = @driver.find_element(:css, tag)
    rescue Selenium::WebDriver::Error::WebDriverError => e
      element unless e
  end

  def find_elements(tag)
    @driver.find_elements(:css, tag)
  end

  def go_to_url(url)
    @driver.navigate.to(url)
  end

  def find_size(profile)
    go_to_url(profile.url)
    sleep(10)
    work_place = 'a[data-control-name="background_details_company"]'
    return 'nil' if find_elements(work_place).empty?

    href = find_elements(work_place).first.attribute('href')

    return nil if href.include?('/search/results/all/')

    company_page = href + 'about/'
    puts "company_page: #{company_page}"
    go_to_url(company_page)
    sleep(10)
    cleaning_size
  end

  def cleaning_size
    target = '.org-about-company-module__company-size-definition-text'
    return nil if find_element(target).nil?

    raw_size = find_element(target).text.delete('employees')
                                   .delete('employés')
    cleaned_size = raw_size.delete(" \t\r\n\,").split('+').join.split('-')
    cleaned_size.map { |value| value.gsub(/[^0-9]/, '').to_i }
  end

  def find_job(profile)
    sleep(8)
    go_to_url(profile.url)
    code_tags = find_elements('code')
    target_h = []

    code_tags.each do |code|
      next if code.attribute('textContent').class == NilClass

      target_string = "\"firstName\":\"#{profile.first_name}\",\"lastName\":"
      target_h << code if code.attribute('textContent').include?(target_string)
    end
    JSON.parse(target_h[0].attribute('textContent'))['data']['occupation']
  end
end
