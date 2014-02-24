module PullRequest
  class BuildLog
    attr_reader :normal_description, :builds_hash

    def initialize(description_string)
      @normal_description, build_lines = description_string.split(PullRequest::BuildLog.separator)
      build_lines ||= ""
      @normal_description.strip!
      @builds_hash = Hash[build_lines.strip.each_line.map do |line|
        line_to_hash_line(line.strip)
      end]
    end

    def to_s
      [normal_description,
       PullRequest::BuildLog.separator,
       builds_hash_to_s,
       PullRequest::BuildLog.build_images].join "\n"
    end
    alias :description :to_s

    def add_build!(commit_hash, status, date = nil)
      @builds_hash[commit_hash] = { commit_hash: commit_hash, status: status, date: date }.delete_if { |k, v| v.nil? }
    end

    def self.separator
      "\n### Jenkins build statuses\n"
    end

    def self.build_images
      #TODO put the real images urls
      <<-build_images_urls
      [passed]: http://passed_build_image_url.png
      [failed]: http://failed_build_image_url.png
      [unknown]: http://unknown_build_image_url.png
      build_images_urls
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
