require 'pull_request/build_log_line'

module PullRequest
  class BuildLog
    attr_reader :build_lines, :normal_description, :repo_full_name, :badge_url

    SEPARATOR = "### Jenkins build statuses".freeze
    LINE_FORMAT = "%{badge_img} %{link} %{date}"

    def initialize(description_string, user, repo, badge_url)
      @badge_url = badge_url
      @repo_full_name = "#{user}-#{repo}"
      @normal_description, build_lines = description_string.split(SEPARATOR).map(&:to_s)
      @normal_description.rstrip! if @normal_description
      @build_lines = build_lines.to_s.strip.each_line("\n\n").map do |line|
                       BuildLogLine.from_string(line.strip)
                     end.to_set
    end

    def add_build!(sha, date = nil, job_number = '')
      log_line = BuildLogLine.from_status(sha: sha, date: date, url: job_number)
      build_lines.select!{ |line| line.sha != log_line.sha }
      build_lines << log_line
    end

    def to_s
      [normal_description, log].join("\n\n#{SEPARATOR}\n\n").concat("\n")
    end
    alias_method :description, :to_s


    private
    attr_writer :build_lines, :normal_description

    def log
      build_lines.map do |bl|
        (LINE_FORMAT % {
          badge_img: badge_img(bl),
          link: link(bl),
          date: bl.formatted_date
        }).strip
      end.join("\n\n")
    end

    def badge_img(build_line)
      "![badge](#{badge_url})" % { sha: build_line.sha }
    end

    def link(build_line)
      "[jenkins](#{ENV['JENKINS_URL']}/job/#{repo_full_name}/#{build_line.url})"
    end
  end
end
