require 'rake'
require 'rspec/core/rake_task'

#task :default => [:spec, :lint]
task :default do
  system("rake -T")
end

desc "Run all rspec-puppet tests"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/*/*_spec.rb'
end

desc "Run all rspec-puppet tests visually"
RSpec::Core::RakeTask.new(:vspec) do |t|
  t.rspec_opts = ['--color', '--format documentation']
  t.pattern = 'spec/*/*_spec.rb'
end

def update_module_version
  gitdesc = %x{git describe}.chomp
  semver = gitdesc.gsub(/v?(\d+\.\d+\.\d+)-?(.*)/) do
    newver = "#{$1}"
    newver << "git-#{$2}" unless $2.empty?
    newver
  end
  modulefile = File.read("Modulefile")
  modulefile.gsub!(/^\s*version\s+'.*?'/, "version '#{semver}'")
  File.open("Modulefile", 'w') do |f|
    f.write(modulefile)
  end
  semver
end

desc "Build Puppet Module Package"
task :build do
#  system("gimli README*.markdown")
  FileUtils.cp "Modulefile", ".Modulefile.bak"
  update_module_version
  system("puppet-module build")
  FileUtils.mv ".Modulefile.bak", "Modulefile"
end
#desc "Build puppet module package"
#task :build do
#  # This will be deprecated once puppet-module is a face.
#  begin
#    Gem::Specification.find_by_name('puppet-module')
#  rescue Gem::LoadError, NoMethodError
#    require 'puppet/face'
#    pmod = Puppet::Face['module', :current]
#    pmod.build('./')
#  end
#end

desc "Check puppet manifests with puppet-lint"
task :lint do
  # This requires pull request: https://github.com/rodjek/puppet-lint/pull/81
  system("echo '** manifests'; puppet-lint --with-filename manifests")
  system("echo '** tests'; puppet-lint --with-filename tests")
end
