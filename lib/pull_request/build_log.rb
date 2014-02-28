require 'pull_request/build_log_line'

module PullRequest
  class BuildLog
    attr_reader :build_lines, :normal_description, :repo_full_name

    SEPARATOR = "\n\n### Jenkins build statuses\n\n".freeze
    LINE_FORMAT = "%{badge_img} %{sha_link} %{date}"

    def initialize(description_string, repo_full_name)
      @repo_full_name = repo_full_name
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
    attr_writer :build_lines, :normal_description

    def log
      build_lines.map do |bl|
        LINE_FORMAT % {
          badge_img: badge_img(bl),
          sha_link: sha_link(bl),
          date: bl.formatted_date
        }
      end.join("\n")
    end

    def badge_img(build_line)
      #TODO prepend badge path with app url
      "![badge](/#{repo_full_name}/#{build_line.sha}/badge)"
    end

    def sha_link(build_line)
      "[commit details](https://bitbucket.org/#{repo_full_name}/commits/#{build_line.sha})"
    end
  end
end
