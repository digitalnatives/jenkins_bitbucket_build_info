# Jenkins / Bitbucket Pull Requests
[![Build Status](https://travis-ci.org/digitalnatives/jenkins_bitbucket_build_info.png?branch=master)](https://travis-ci.org/digitalnatives/jenkins_bitbucket_build_info)


This application serves as a mediator between Bitbucket and Jenkins:

  * When a pull request is created / updated on a repository in Bitbucket it will start a job on Jenkins
  * When Jenkins is finished with that job it will update the Bitbucket pullrequest with badges

## Bitbucket setup

  * Create a user that will be editing / approving pull request
  * Make sure that `BITBUCKET_CREDENTIALS` is available with the previously created users credentials
  * In the repository you want to be monitored create a [Post Pull Request Hook](https://confluence.atlassian.com/display/BITBUCKET/POST+hook+management) that points to `http://application_url/bitbucket/post_pull_request`

## Jenkins Setup
On your Jenkins job:

  * add a **string paramter** to the builds named `SHA` with the default value for the branch you want to build by default.
  * add a **build step** to the top that will checkout the current SHA: `git checkout $SHA`
  * add a **Post Build Step** wich matches anything with `OR` and with the shell script:

    ```
    curl "http://application_url/jenkins/post_build?branch=$GIT_BRANCH&sha=$SHA&job_number=$BUILD_NUMBER&job_name=$JOB_NAME"
    ```
  *  Make sure that `JENKINS_USERNAME` `JENKINS_PASSWORD` and `JENKINS_URL` are available for the application

## Environmental variables
Make sure that these environmental variables are available for the applcation:
```ruby
# Bitbucket username and password
BITBUCKET_CREDENTIALS=username:password
# URL for Jenkins
JENKINS_URL=http://jenins.devmachine.com
# Jenkins Credentials
JENKINS_USERNAME=jenkins_username
JENKINS_PASSWORD=jenkins_password
# Redis URL
REDIS_URL=redis://127.0.0.1
```
