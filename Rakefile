require 'rubygems'
require 'rake/clean'
require 'pp'

require 'jenkins_helper'
require 'rpm_packager'
require 'deb_packager'

CLEAN.include("")
CLOBBER.include("target")

desc "Default task prints the possible targets."
task :default do
  sh %{rake -T}
end

desc "Create RPM package for puppet-modules."
task :rpm do
  puts "Creating RPM package from puppet module..."
  
  if ENV["JOB_NAME"].nil?
    fail("Environment variable JOB_NAME has not been set.")
  end

  module_name = ENV["JOB_NAME"]
  module_dependencies = find_module_dependencies module_name
  
  rpm_packager = RpmPackager.new
  output = rpm_packager.build(module_name, module_dependencies)
  puts output
end

desc "Create DEB package for puppet-modules."
task :deb do
  puts "Creating DEB package from puppet module..."
  
  if ENV["JOB_NAME"].nil?
    fail("Environment variable JOB_NAME has not been set.")
  end 
  
  module_name = ENV["JOB_NAME"]
  module_dependencies = find_module_dependencies module_name

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
