class BuildLogLine
  def initialize(options)
    @line = options[:line]
    @status = options[:status]
    @commit_hash = options[:commit_hash]
    @date = options[:date]
  end

  def line
    @line ||= "#{status_image} #{commit_url} #{date}".strip
  end

  def status
    @status ||= splitted_line[0].tr("![]", "").split('_').first.to_sym
  end

  def commit_hash
    @commit_hash ||= splitted_line[1]
  end

  def date
    @date ||= splitted_line[2]
  end

  def status_image
    #TODO link to commit build using commit_hash
    "![#{status}_build_image]"
  end

  def commit_url
    #TODO link to bitbucket commit
    commit_hash
  end

  alias :to_s :line

  private

  def splitted_line
    @splitted_line ||= line.split(" ")
  end
end
