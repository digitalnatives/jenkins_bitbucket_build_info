require 'pull_request/build_log_line'

module PullRequest
  class BuildLog
    attr_reader :normal_description, :builds_hash

    def initialize(description_string)
      @normal_description, build_lines = description_string.split(self.class.separator)
      @normal_description.strip!
      build_lines = (build_lines || "").strip.each_line.reject do |line|
        line.match(/\[.*\]: .+/)
      end
      @builds_hash = Hash[build_lines.map do |line|
        build_log_line = BuildLogLine.new(line: line.strip)
        [build_log_line.commit_hash, build_log_line]
      end]
    end

    def to_s
      [normal_description,
       self.class.separator,
       builds_hash_to_s,
       self.class.build_images].join "\n"
    end
    alias :description :to_s

    def add_build!(commit_hash, status, date = nil)
      @builds_hash[commit_hash] = BuildLogLine.new(commit_hash: commit_hash,
                                                   status: status,
                                                   date: date)
    end

    def self.separator
      "\n### Jenkins build statuses\n"
    end

    def self.build_status_images_hash
      #TODO put the real images urls
      {
        passed: 'http://passed_build_image_url.png',
        failed: 'http://failed_build_image_url.png',
        unknown: 'http://unknown_build_image_url.png'
      }
    end

    def self.build_images
      build_status_images_hash.map do |status, url|
        "[#{status}_build_image]: #{url}"
      end.join "\n"
    end

    private

    def builds_hash_to_s
      builds_hash.map do |_, build_log_line|
        build_log_line.to_s
      end.join "\n"
    end
  end
end
