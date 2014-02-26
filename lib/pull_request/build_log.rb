require 'pull_request/build_log_line'

module PullRequest
  class BuildLog

    SEPARATOR = "\n\n### Jenkins build statuses\n\n".freeze
    LINE_FORMAT = "%{badge_img} %{sha_link} %{date}"

    def initialize(description_string)
      @normal_description, build_lines = description_string.split(SEPARATOR).map(&:to_s)
      @build_lines = build_lines.strip.each_line.map do |line|
                       BuildLogLine.from_string(line.strip)
                     end.to_set
    end

    def add_build!(sha, date = nil)
      build_lines << BuildLogLine.from_status(sha: sha, date: date)
    end

    def to_s
      [normal_description, log].join(SEPARATOR).concat("\n")
    end
    alias_method :description, :to_s


    private
    attr_accessor :normal_description, :build_lines

    def log
      build_lines.map do |bl|
        LINE_FORMAT % {
          badge_img: badge(bl),
          sha_link: 'alsdjf',
          date: bl.formatted_date
        }
      end
    end

  end
end
