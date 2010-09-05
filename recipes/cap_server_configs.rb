require 'ruby-debug'
Debugger.start

namespace :server_configs do
  desc "Replace modified configuration files" do
    task :check, :only => { :manage_configs => true } do
      cap_hosts = []

      run('hostname') do |channel, stream, data|
        cap_hosts << channel[:server].instance_variable_get(:@host)
      end

      cap_hosts.each do |host|
        hostname = capture('hostname', :hosts => host).strip
        dir = "config/servers/#{hostname}"
        Dir["#{dir}/**/*"].each do |file|
          next if File.directory?(file)
          local_file = File.read(file)
          location = (local_file.match(/#\s*location:\s*(.+)$/)[1] rescue nil)
          if location.nil? or location.length == 0
            puts "Could not find location: setting in configuration file #{file}"
            next
          end

          local_file.gsub!(/#\s*location:\s*.+\n|^\s*\n/, '')

          restart_command = (local_file.match(/#\s*restart:\s*(.+)$/)[1] rescue nil)
          local_file.gsub!(/#\s*restart:\s*.+\n|^\s*\n/, '')

          remote_file = capture("cat #{location}", :hosts => host).gsub(/^\s*\n/, '')

          if remote_file.gsub(/\r|\n/,'') != local_file.gsub(/\r|\n/,'')
            puts "remote #{location} differs from local #{file}"
            backup_file = location + ".cap_bak"
            puts "saving backup of #{location} to #{backup_file}"
            run('cp #{location} #{backup_file}', :hosts => host)
            puts "replacing remote file #{location}"
            put(local_file, location)
            if restart_command
              puts "restarting remote service"
              run(remote_command, :hosts => host)
            end
          end
        end
      end
    end
  end

  desc "Check for modified configuration files"
  task :check, :only => { :manage_configs => true } do
    cap_hosts = []

    run('hostname') do |channel, stream, data|
      cap_hosts << channel[:server].instance_variable_get(:@host)
    end

    cap_hosts.each do |host|
      hostname = capture('hostname', :hosts => host).strip
      dir = "config/servers/#{hostname}"
      Dir["#{dir}/**/*"].each do |file|
        next if File.directory?(file)
        local_file = File.read(file)
        location = (local_file.match(/#\s*location:\s*(.+)$/)[1] rescue nil)
        if location.nil? or location.length == 0
          puts "Could not find location: setting in configuration file #{file}"
          next
        end

        local_file.gsub!(/#\s*location:\s*.+\n|^\s*\n/, '')
        remote_file = capture("cat #{location}", :hosts => host).gsub(/^\s*\n/, '')

        if remote_file.gsub(/\r|\n/,'') != local_file.gsub(/\r|\n/,'')
          puts "remote #{location} differs from local #{file}"
          puts "*****"
          File.open("/tmp/local_config","w") {|f| f << local_file }
          File.open("/tmp/remote_config","w") {|f| f << remote_file }
          puts `git diff -w /tmp/local_config /tmp/remote_config`
          puts "*****"
        end
      end
    end
  end
end