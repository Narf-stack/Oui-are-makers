require 'rubyXL'
require 'spreadsheet'
require 'csv'
require_relative '../profile'

# Self-adapting storing system
class Storing
  def initialize(dir_path, extension, profiles, file_name)
    @dir_path = dir_path
    @file_extension = extension
    @profiles = profiles
    @filename = file_name
    @headers = %w[type email first_name last_name url job_title company_name
                  user_company_size x_list_name]
    time_stamp_and_name
    run
  end

  def run
    case @file_extension
    when 'xlsx'
      save_xlsx
    when 'xls'
      save_xls
    when 'csv'
      save_csv
    end
    puts "out file: #{@clean_name}"
  end

  private

  def time_stamp_and_name
    date = Time.now.getutc.strftime('%d-%m-%Y')
    @clean_name = "#{date}_clean_#{@filename}"
    @file_path = @dir_path + '/' + @clean_name
  end

  def generate_attributes(profile)
    [profile.type, profile.email, profile.first_name, \
     profile.last_name, profile.url, profile.job, \
     profile.company_name, profile.cpny_size.join('-'), \
     profile.x_list_name]
  end

  def save_csv
    CSV.open(@file_path, 'wb', write_headers: true, headers: @headers) do |csv|
      @profiles.each do |profile|
        csv << generate_attributes(profile)
      end
    end
  end

  def save_xlsx
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    worksheet.sheet_name = 'valid'

    @headers.each_with_index do |element, index|
      worksheet.add_cell(0, index, element)
    end
    @profiles.each_with_index do |profile, row|
      new_row = row + 1
      attributes = generate_attributes(profile)
      attributes.each_with_index do |attribute, column|
        worksheet.add_cell(new_row, column, attribute)
      end
    end
    workbook.write(@file_path)
  end

  def save_xls
    new_book = Spreadsheet::Workbook.new
    new_book.create_worksheet name: 'valid'
    new_book.worksheet(0).insert_row(0, @headers)
    @profiles.each_with_index do |profile, row|
      new_row = row + 1
      attributes = generate_attributes(profile)
      new_book.worksheet(0).insert_row(new_row, attributes)
    end
    new_book.write(@file_path)
  end
end
