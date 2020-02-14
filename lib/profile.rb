# Instantiate line of file
class Profile
  attr_reader :first_name, :last_name, :email, :url, :company_name, \
              :x_list_name
  attr_accessor :cpny_size, :job, :type

  def initialize(attributes = {})
    @first_name = attributes['first_name'].strip
    @last_name = attributes['last_name'].strip
    @email = attributes['email'].strip
    @url = attributes['url'].strip
    @job = attributes['job_title'].downcase.strip
    @company_name = attributes['company_name'].strip
    @cpny_size = size(attributes['user_company_size'])
    @x_list_name = attributes['x_list_name'].strip
    @type = ''
  end

  def size(value)
    return '' if value.class == NilClass

    value.delete('employees')
         .delete('employés')
         .strip.split('+')
         .join.split('-')
         .map { |v| v.scan(/\d+/).join.to_i }
  end
end
