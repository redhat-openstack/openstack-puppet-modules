task(:default).clear
task :default => :test

desc 'Run Puppetfile Validation'
task :test => [:validate_puppetfile,:all_modules]

desc "Validate the Puppetfile syntax"
task :validate_puppetfile do
  $stderr.puts "---> syntax:puppetfile"
  sh "r10k puppetfile check"
end

desc "Run rspec tests for each modules"
task :all_modules do
  FileList["*/Rakefile"].each do |project|
    dir = project.pathmap("%d")
    Dir.chdir(dir) do
      puts "======"
      puts "= Running spec test for #{project}"
      puts "======"
      system('rm -Rf vendor/')
      system('rm -Rf .bundle/')
      FileUtils.mkdir 'vendor'
      ENV['GEM_HOME'] = "vendor"
      system('bundle install --path=vendor/ --gemfile=./Gemfile')
      ENV['BUNDLE_GEMFILE'] = "./Gemfile"
      system('bundle exec rake spec')
      system('rm -Rf vendor')
      system('rm -Rf .bundle/')
    end
  end
end
