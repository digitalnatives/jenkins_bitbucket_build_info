require 'forwardable'

class CommitStatus
  extend Forwardable

  def_delegators :@attributes, :sha, :job_name, :job_number, :user, :repo,
                               :branch, :status, :to_h

  def initialize(params)
    @attributes = OpenStruct.new({
      sha:        params.fetch('sha')[0..11],
      job_name:   params.fetch('job_name'),
      job_number: params.fetch('job_number'),
      user:       params.fetch('user'),
      repo:       params.fetch('repo'),
      branch:     params.fetch('branch'),
      status:     params.fetch('status').to_s.downcase
    })
  end
end
