# frozen_string_literal: true

class GcloudHelper
  attr_accessor :authenticated

  def initialize
    @authenticated = true
    auth_command = "gcloud auth activate-service-account ${GOOGLE_ACCOUNT_NAME} --key-file ${GOOGLE_APPLICATION_CREDENTIALS}"
    project_command = "gcloud config set project ${GOOGLE_PROJECT}"
    auth = system(auth_command) and system(project_command)
    if !auth
      raise "Problem login with gcloud"
    end
    puts @authenticated
  end

  def run(args)
    if @authenticated
      out = `gcloud #{args}`
      raise GcloudCmdError if $CHILD_STATUS.exitstatus != 0
      return out
    end
    raise "You need to be authenticated for running gcloud"
  end

  # Gcloud is raised whenever the shell command 'gcloud' fails
  class GcloudCmdError < StandardError
    def initialize(msg = 'failed to call gcloud')
      super
    end
  end
end
