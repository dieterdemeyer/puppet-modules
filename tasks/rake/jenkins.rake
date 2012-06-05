require File.expand_path('../../env', __FILE__)

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'version_helper'

namespace "jenkins" do
  desc "Archive job configuration in YAML format."
  task :archive_job_configuration do
    dist_dir = "#{RESULTS}/dist"

    module_name = ENV['JOB_NAME']
    git_commit = ENV['GIT_COMMIT']
		semver_version = VersionHelper.new.semver_version
    
    puts "Saving #{module_name}.yaml file"
    FileUtils.mkdir_p(dist_dir)
    open("#{dist_dir}/#{module_name}.yaml", "w") { |file|
      file.puts "module_name: #{module_name}"
      file.puts "semver_version: #{semver_version}"
    }
  end
end
