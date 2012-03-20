require 'json'
require 'net/https'

class JenkinsHelper

  def initialize()
    self.validate_environment
    self.setup_jenkins_connection
  end

  def validate_environment()
    if ENV["JENKINS_URL"].nil?
      fail("Environment variable JENKINS_URL has not been set.")
    end
    if ENV["JENKINS_USERNAME"].nil?
      fail("Environment variable JENKINS_USERNAME has not been set.")
    end
    if ENV["JENKINS_TOKEN"].nil?
      fail("Environment variable JENKINS_TOKEN has not been set.")
    end
  end

  def setup_jenkins_connection()
    @jenkins_url = ENV["JENKINS_URL"]
    @jenkins_username = ENV["JENKINS_USERNAME"]
    @jenkins_token = ENV["JENKINS_TOKEN"]

    @jenkins_uri = URI.parse(@jenkins_url)
    @jenkins_conn = Net::HTTP.new(@jenkins_uri.host, @jenkins_uri.port)
    @jenkins_conn.use_ssl = true
    @jenkins_conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def find_upstream_projects(job_name)
    job_url = "/jenkins/job/#{job_name}/api/json"
    job_response = call_jenkins_api(job_url)

    upstream_projects = []
    job_response['upstreamProjects'].each { |project|
      upstream_projects << project['name']
    }

    upstream_projects
  end

  def get_last_stable_build_number(job_name)
    job_url = "/jenkins/job/#{job_name}/api/json"
    job_response = call_jenkins_api(job_url)
    job_response['lastStableBuild']['number']
  end

  def call_jenkins_api(request_url)
    request = Net::HTTP::Get.new(request_url)
    request.basic_auth @jenkins_username, @jenkins_token
    JSON.load(@jenkins_conn.request(request).body)
  end

end
