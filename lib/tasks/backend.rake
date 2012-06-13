require 'radio_backend'
namespace :backend do
  
  task :start => :environment do
    pid_file = File.join(Rails.root, 'tmp', 'pids', 'backend.pid')
    puts "start backend..."
    pid = Process.fork do
      backend = RadioBackend.new
      backend.logger = Logger.new(File.join(Rails.root, 'log', 'backend.log'))
      backend.start_all
    end
    if pid
      File.open(pid_file, 'w') {|f| f.write(pid) } # write pid file
    end
  end
  
  task :stop => :environment do
    pid_file = File.join(Rails.root, 'tmp', 'pids', 'backend.pid')
    if File.exists?(pid_file)
      puts "stop backend..."
      pid = nil
      File.open(pid_file, 'r') { |io|
        pid = io.readline.to_i
      }
      begin
        if pid
          Process.kill(15, pid) # TERM to pid
        end
      rescue Errno::ESRCH
        puts "backend was stopped unexpectantly"
      ensure
        File.delete(pid_file)
      end
    else
      puts "backend already stopped"
    end
    
  end
  
  task :restart => [:stop, :start] do
  end
end