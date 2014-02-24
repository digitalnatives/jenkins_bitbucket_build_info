require 'spec_helper'
require 'pull_request/build_log'

describe PullRequest::BuildLog do

  let(:description_string) do
    <<-end_of_description
Not build related description

### Jenkins build statuses

http://passed_image_url.png 1f4ad90294d3fd7ab5cebe42ee97655c2e709bbf 2014/02/21
http://failed_image_url.png a4cad4e4c24ab53a725fe8953c2d587dd34573e1
    end_of_description
  end

  let(:build_log) do
    PullRequest::BuildLog.new(description_string)
  end

  describe ".initialize" do

    let(:builds_hash) do
      {"1f4ad90294d3fd7ab5cebe42ee97655c2e709bbf" => { commit_hash: "1f4ad90294d3fd7ab5cebe42ee97655c2e709bbf",
                                                       status: "http://passed_image_url.png",
                                                       date: "2014/02/21" },
    "a4cad4e4c24ab53a725fe8953c2d587dd34573e1" => { commit_hash: "a4cad4e4c24ab53a725fe8953c2d587dd34573e1",
                                                    status: "http://failed_image_url.png" }
      }
    end

    it "stores the part of the description not related to Jenkins builds" do
      expect(build_log.normal_description).to eq "Not build related description"
    end

    it "transforms Jenkins builds list into a hash" do
      expect(build_log.builds_hash).to eq builds_hash
    end
  end

  describe "#to_s" do
    it "regenerates previous description string" do
      expect(build_log.to_s).to start_with(description_string)
    end

    it "contains build images urls at the bottom" do
      expect(build_log.to_s).to end_with(PullRequest::BuildLog.build_images)
    end
  end

  describe "#add_build!" do
  end
end
