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
  module_dependencies = find_module_dependencies(module_name)

  deb_packager = DebPackager.new
  output = deb_packager.build(module_name, module_dependencies)
  puts output
end

def find_module_dependencies(module_name)
  jenkins = JenkinsHelper.new
  upstream_projects = jenkins.find_upstream_projects module_name

  module_dependencies = {}
  upstream_projects.each { |upstream_project|
    build_number = jenkins.get_last_stable_build_number upstream_project
    module_dependencies.store upstream_project, build_number
  }
  puts "Found the following dependencies for #{module_name}:"
  PP::pp(module_dependencies, $stdout)

  module_dependencies
end
