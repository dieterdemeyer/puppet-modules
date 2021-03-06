gem 'fpm', '<=0.3.11'
require 'fpm'
require 'fpm/program'
require 'pp'

$:.unshift(File.join(File.dirname(__FILE__), '..'))
require 'version_helper'

class BasePackager

  attr_writer :package_prefix

  def initialize(package_type)
    self.validate_environment
    
    @basedirectory = ENV['WORKSPACE']
    versionhelper = VersionHelper.new
    @semver_version = versionhelper.semver_version
    @release = versionhelper.release
    @package_type = package_type 
    @package_prefix = package_prefix
    
    case package_type
    when "rpm"
      @first_delimiter, @second_delimiter, @architecture = "-", ".", "noarch"
    when "deb"
      @first_delimiter, @second_delimiter, @architecture = "_", "_", "all"
    end
  end

  def package_prefix
    @package_prefix || "cegeka"
  end

  def validate_environment()
    if ENV['WORKSPACE'].nil?
      fail("Environment variable WORKSPACE has not been set.")
    end
		if ENV['BUILD_NUMBER'].nil?
      ENV["BUILD_NUMBER"] = "0"
    end
    if ENV['GIT_COMMIT'].nil?
      ENV['GIT_COMMIT'] = "54b0c58c7ce9f2a8b551351102ee0938"[0,10]
    end
  end
 
  def build(module_name, module_dependencies)
    package_name = "#{@package_prefix}-puppet-#{module_name}"
    destination_file = "#{package_name}#{@first_delimiter}#{@semver_version}-#{@release}#{@second_delimiter}#{@architecture}.#{@package_type}"
    destination_folder = "#{@basedirectory}/#{module_name}/#{RESULTS}/dist"
    temp_src_dir = "#{@basedirectory}/#{module_name}/#{RESULTS}/src"
    url = "https://github.com/cegeka/puppet-#{module_name}"
    description = "Puppet module: #{module_name} by Cegeka\nModule #{module_name} description goes here."

    static_arguments = ["-t", @package_type, "-s", "dir", "-a", @architecture, "-m", "Cegeka <computing@cegeka.be>", "--prefix", "/usr/share/doc"]
    exclude_arguments = ["-x", ".git", "-x", ".gitignore", "-x", "tasks", "-x", "Rakefile", "-x", "target", "-x", ".project", "-x", ".puppet-lintrc"]
    var_arguments = ["-n", package_name, "-v", @semver_version, "--iteration", @release, "--url", url, "--description", description, "-C", @basedirectory, module_name]
    dependency_arguments = []
    module_dependencies.each { |dependent_module,dependent_version|
      dependent_package = "#{@package_prefix}-#{dependent_module}"
      dependency_arguments << "-d"
      dependency_arguments << "#{dependent_package} = #{dependent_version}"
    }
		
    arguments = static_arguments + exclude_arguments + var_arguments + dependency_arguments
    
    tmpdir = Dir.mktmpdir
    Dir.chdir tmpdir
    FileUtils.mkpath destination_folder
    FileUtils.mkpath temp_src_dir
    FileUtils.mkpath "#{temp_src_dir}/#{package_name}"
    open("#{temp_src_dir}/#{package_name}/dependencies", "w") { |file|
      PP::pp(module_dependencies, file)
    }
    packagebuild = FPM::Program.new
    ret = packagebuild.run(arguments)
    FileUtils.mv("#{tmpdir}/#{destination_file}","#{destination_folder}/#{destination_file}")
    FileUtils.remove_entry_secure(tmpdir)
    return "Created #{destination_folder}/#{destination_file}"
  end

end
