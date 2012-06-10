namespace :db do
  task :seed_stations => :environment do
    pls_files = Dir["#{Rails.root}/db/seed_pls/*.pls"]
    pls_files.each do |pls_file|
      data = {}
      File.open(pls_file, 'r') do |f|
        f.each_line do |l|
          if l.start_with?('File') or l.start_with?('Title')
            k, v = l.split('=', 2)
            data[k] = v
          end
        end
      end

      # Clean the name...
      name = data['Title1']
      name = name.match(/\(.+?\)(.*)/)[1].strip

      Station.create(:url => data['File1'],
                     :name => name)
    end
  end
end
