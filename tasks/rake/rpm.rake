require File.expand_path('../../env', __FILE__)

$:.unshift(File.join(File.dirname(__FILE__), 'lib', 'packaging'))
require 'rpm_packager'

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'jenkins_helper'

desc "Create RPM package from puppet module."
task :rpm do
  puts "Creating RPM package from puppet module..."
	
  if ENV["JOB_NAME"].nil?
    fail("Environment variable JOB_NAME has not been set.")
  end

  module_name = ENV["JOB_NAME"].split('-')[1]

  jenkins_helper = JenkinsHelper.new
  module_dependencies = jenkins_helper.find_module_dependencies(module_name)

  rpm_packager = RpmPackager.new
  output = rpm_packager.build(module_name, module_dependencies)
  puts output
end
