module BitbucketHooks

  def self.registered(app)
    app.post '/bitbucket/post_pull_request' do
      logger.fatal 'bitbucket hook is not implemented'
    end
  end

end
