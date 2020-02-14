require 'rubyXL'
require 'spreadsheet'
require 'csv'
require_relative '../profile'

# Self-adapting parser
class Parser
  attr_reader :profiles
  def initialize(file_path, extension)
    @filepath = file_path
    @file_extension = extension
    @profiles = []
    run
  end

  def run
    case @file_extension
    when 'xlsx'
      load_xlsx
    when 'xls'
      load_xls
    when 'csv'
      load_csv
    else
      raise ArgumentError.new, 'Unknown format: only CSV,xls or xlsx are ok '
    end
    puts "parsed: #{@profiles.size} lines"
  end

  private

  def load_csv
    csv_options = { col_sep: ';', quote_char: '"', headers: true, \
                    encoding: 'iso-8859-1:utf-8' }
    CSV.foreach(@filepath, csv_options) do |row|
      @profiles << Profile.new(row)
    end
    @profiles
  end

  def load_xlsx
    workbook = RubyXL::Parser.parse(@filepath)
    worksheets = workbook.worksheets

    worksheets.each do |worksheet|
      headers = worksheet[0].cells.map(&:value)
      raw_profiles = []
      i = 0

      worksheet.each do |row|
        row_profile = []
        row && row.cells.each do |cell|
          next row if i.zero?

          value = cell && cell.value
          row_profile << value
        end
        i += 1
        raw_profiles << row_profile unless row_profile.empty?
      end

      raw_profiles.each do |profile|
        fusion_array = headers.zip(profile)
        profile_hash = fusion_array.inject({}) do |hash, (k, v)|
          hash[k] = v
          hash
        end
        @profiles << Profile.new(profile_hash)
      end
    end
    @profiles
  end

  def load_xls
    workbook = Spreadsheet.open(@filepath)
    worksheets = workbook.worksheets

    worksheets.each do |worksheet|
      headers = worksheet.rows[0]
      raw_profiles = []
      row_profile = []
      worksheet.rows.each do |row|
        row_cells = row.to_a.map { |v| v.methods.include?(:value) ? v.value : v }
        row_profile << row_cells
      end
      raw_profiles = row_profile[1...row_profile.length]

      raw_profiles.each do |profile|
        fusion_array = headers.zip(profile)

        profile_hash = fusion_array.inject({}) do |hash, (k, v)|
          hash[k] = v
          hash
        end
        @profiles << Profile.new(profile_hash)
      end
    end
    @profiles
  end
end
