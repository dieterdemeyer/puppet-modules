require File.expand_path('../../env', __FILE__)

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'version_helper'

namespace "jenkins" do
  desc "Archive job configuration in YAML format."
  task :archive_job_configuration do
    dist_dir = "#{RESULTS}/dist"

    module_name = ENV['JOB_NAME']
    
    version_helper = VersionHelper.new
    rpm_version = version_helper.semver_version + "-" + version_helper.release
    
    puts "Saving #{module_name}.yaml file"
    FileUtils.mkdir_p(dist_dir)
    open("#{dist_dir}/#{module_name}.yaml", "w") { |file|
      file.puts("module_name: #{module_name}")
      file.puts("puppet_modules_rpm_version: #{rpm_version}")
    }
    open("#{dist_dir}/#{module_name}.properties", "w") { |file|
      file.puts("module_name=#{module_name}")
      file.puts("puppet_modules_rpm_version=#{rpm_version}")
    }

    jenkins_helper = JenkinsHelper.new
    module_dependencies = jenkins_helper.find_module_dependencies(module_name)
    
    dependencies_file = "puppet-modules-dependencies.yaml"
    puts "Saving #{dependencies_file} file"
    open("#{dist_dir}/#{dependencies_file}", "w") { |file|
      file.puts(module_dependencies.to_yaml)
    }
  end
end
