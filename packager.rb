require 'fpm'
require 'fpm/program'
require 'pp'

class Packager

  def initialize(package_type)
    self.validate_environment
    
    @basedirectory = ENV["WORKSPACE"]
    @build_number = ENV["BUILD_NUMBER"]
    @package_type = package_type 
    
    case package_type
    when "rpm"
      @delimiter_a, @delimiter_b, @architecture = "-", ".", "noarch"
    when "deb"
      @delimiter_a, @delimiter_b, @architecture = "_", "_", "all"
    end
  end

  def validate_environment()
    if ENV["WORKSPACE"].nil?
      fail("Environment variable WORKSPACE has not been set.")
    end
    if ENV["BUILD_NUMBER"].nil?
      fail("Environment variable BUILD_NUMBER has not been set.")
    end
  end
 
  def build(module_name, module_dependencies)
    version = "0.01"
    package_name = "cegeka-#{module_name}"
    destination_file = "#{package_name}#{@delimiter_a}#{version}-#{@build_number}#{@delimiter_b}#{@architecture}.#{@package_type}"
    destination_folder = "#{@basedirectory}/#{module_name}/target/dist"
    temp_src_dir = "#{@basedirectory}/#{module_name}/target/src"
    url = "https://github.com/cegeka/#{module_name}"
    description = "Puppet module: #{module_name} by Cegeka\nModule #{module_name} description goes here."

    static_arguments = ["-t", @package_type, "-s", "dir", "-x", ".git", "-a", @architecture, "-m", "Cegeka <computing@cegeka.be>", "--prefix", "/usr/share/doc"]
    var_arguments = ["-n", package_name, "-v", version, "--iteration", @build_number, "--url", url, "--description", description, "-C", temp_src_dir]
    dependency_arguments = []
    module_dependencies.each { |dependent_module,dependent_version|
      dependency_arguments << "-d"
      dependency_arguments << "#{dependent_module} <= #{dependent_version}"
    }

    arguments = static_arguments + dependency_arguments + var_arguments
    
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
