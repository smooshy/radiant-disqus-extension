namespace :radiant do
  namespace :extensions do
    namespace :disqus do
      
      desc "Runs the migration of the Disqus extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          DisqusExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          DisqusExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Disqus to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from DisqusExtension"
        Dir[DisqusExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(DisqusExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory, :verbose => false
          cp file, RAILS_ROOT + path, :verbose => false
        end
      end  
    end
  end
end
