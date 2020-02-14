require_relative 'scraper'

# remove and update contact's logic
class Filter
  attr_reader :profiles
  MAIL_REGEX = /([^@]+)@(?<domain>[^@]+)\./.freeze
  PERSO_PROVIDER = %w[gmail wanadoo free live yahoo outlook proton zoho
                      tutanota gmx lycos aol iCloud orange].freeze
  C_LEVEL = ['chief compliant officer', ' cco ', 'responsable de la conformité',
             'chief executive officer', 'ceo', 'president-directeur general',
             'president directeur general', 'pdg', 'chief information officer',
             'cio', 'directeur des systemes d\'information',
             'chief financial officer', 'cfo',
             'directeur financier', 'chief knowledge officer', 'cko',
             'directeur de la gestion des connaissances', 'cso',
             'chief security officer', 'responsable de la sécurité',
             'chief technology officer', 'cto', 'chief green officer', 'cgo',
             'cmo', 'chief marketing officer'].freeze

  def initialize(profiles)
    @profiles = profiles
    run
  end

  def run
    Scraper.new(@profiles)
    keep_big_cpny
    tag_c_level
    remove_irrelevant_job
    tag_mail
  end

  private

  def below_cap?(size)
    size.all? { |val| val >= 200 }
  end

  def keep_big_cpny
    @profiles = @profiles.select do |profile|
      next if profile.cpny_size.class == String

      below_cap?(profile.cpny_size)
    end
  end

  def tag_c_level
    @profiles.each do |prof|
      prof.type = 'c-level' if C_LEVEL.include?(prof.job)
    end
  end

  def remove_irrelevant_job
    irrelevant = ['intern', 'half time', 'retired']
    @profiles = @profiles.reject do |prof|
      irrelevant.include?(prof.job)
    end
  end

  def tag_mail
    @profiles.each do |prof|
      provider = MAIL_REGEX.match(prof.email)[:domain]
      if PERSO_PROVIDER.include?(provider) && prof.type.empty?
        prof.type = 'perso'
      elsif !PERSO_PROVIDER.include?(provider) && prof.type.empty?
        prof.type = 'pro'
      end
    end
  end
end
