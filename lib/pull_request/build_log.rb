module PullRequest
  class BuildLog
    attr_reader :normal_description, :builds_hash

    def initialize(description_string)
      @normal_description, build_lines = description_string.split(PullRequest::BuildLog.separator)
      @normal_description.strip!
      @builds_hash = Hash[build_lines.strip.each_line.map do |line|
        line_to_hash_line(line.strip)
      end]
    end

    def to_s
      [normal_description, PullRequest::BuildLog.separator, builds_hash_to_s].join "\n"
    end

    def add_build!(commit_hash, status, date = nil)
      @builds_hash[commit_hash] = { commit_hash: commit_hash, status: status, date: date }.delete_if { |k, v| v.nil? }
    end

    def self.separator
      "\n### Jenkins build statuses\n"
    end

    private

    def line_to_hash_line(line)
      fields = line.split(" ")
      [ fields[1], { commit_hash: fields[1], status: fields[0], date: fields[2]}.delete_if { |k, v| v.nil? } ]
    end

    def builds_hash_to_s
      builds_hash.map do |_, build_hash|
        "#{build_hash[:status]} #{build_hash[:commit_hash]} #{build_hash[:date]}".strip
      end.join "\n"
    end
  end
end
