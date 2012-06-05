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
      file.puts "module_name: #{module_name}"
      file.puts "rpm_version: #{rpm_version}"
    }
    open("#{dist_dir}/#{module_name}.properties", "w") { |file|
      file.puts "module_name=#{module_name}"
      file.puts "rpm_version=#{rpm_version}"
    }
  end
end
