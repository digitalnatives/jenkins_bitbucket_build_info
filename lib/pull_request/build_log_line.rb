class BuildLogLine
  include Comparable
  DATE_FORMAT = '%Y/%m/%d'

  private_class_method :new

  attr_reader :sha, :date

  def self.from_string(line)
    new(line: line)
  end

  def self.from_status(options = {})
    new(options)
  end

  def initialize(options)
    if options.has_key?(:line)
      @line = options[:line]
      @sha  = @line.scan(/[a-f\d]{40}/).first
      date_string = @line.scan(/\d{4}\/\d{1,2}\/\d{1,2}/).first
    else
      @sha  = options.fetch(:sha)
      date_string = options[:date]
    end
    @date = Date.strptime(date_string, DATE_FORMAT) if date_string
  end

  def formatted_date(format = DATE_FORMAT)
    date.strftime(format) if date
  end

  def <=>(anOther)
    sha <=> anOther.sha
  end
  alias_method :eql?, :==
  alias_method :equal?, :==

end
