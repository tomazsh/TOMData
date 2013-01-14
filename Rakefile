version = `cat VERSION`.strip
output = Dir.pwd + '/Documentation'
appledoc_options = [
  "--output \"#{output}\"",
  '--project-name TOMData',
  '--project-company "Tomaz Nedeljko"',
  '--company-id com.nedeljko',
  "--project-version #{version}",
  '--keep-intermediate-files',
  '--create-html',
  '--no-repeat-first-par',
  '--verbose',
  '--create-docset'
]

namespace :docs do
  desc 'Clean documentation output'
  task :clean do
    `rm -rf Documentation`
  end
  
  desc 'Generate documentation'
  task :generate => [:'docs:clean'] do
    `appledoc #{appledoc_options.join(' ')} TOMData/*.h`
  end
  
  desc 'Install documentation'
  task :install => [:'docs:clean'] do
    `appledoc #{appledoc_options.join(' ')} --install-docset TOMData/*.h`
  end
end