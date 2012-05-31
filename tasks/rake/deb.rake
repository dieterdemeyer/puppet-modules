require File.expand_path('../../env', __FILE__)

$:.unshift(File.join(File.dirname(__FILE__), 'lib', 'packaging'))
require 'deb_packager'

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'jenkins_helper'

desc "Create DEB package from puppet module."
task :deb do
  puts "Creating DEB package from puppet module..."

	if ENV["JOB_NAME"].nil?
    fail("Environment variable JOB_NAME has not been set.")
  end

  module_name = ENV["JOB_NAME"]
	
	jenkins_helper = JenkinsHelper.new
  module_dependencies = jenkins_helper.find_module_dependencies(module_name)

  deb_packager = DebPackager.new
  output = deb_packager.build(module_name, module_dependencies)
  puts output
end
