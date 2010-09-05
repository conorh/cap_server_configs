module CapServerConfigs
  class Helper
    attr_accessor :host

    def get_all_cap_hosts
      run('hostname') do |channel, stream, data|
        cap_hosts << channel[:server].instance_variable_get(:@host)
      end
    end

    def strip_cap_server_config_commands(file)
      file = file.gsub(/#\s*location:\s*.+\n|^\s*\n/, '')
      file.gsub(/#\s*restart:\s*.+\n|^\s*\n/, '')
    end

    def compare_files(local_file, remote_file)
      local_file = strip_cap_server_config_commands(local_file).gsub(/^\s*\n/, '')
      remote_file = remote_file.gsub(/^\s*\n/, '')
      remote_file.gsub(/\r|\n/,'') == local_file.gsub(/\r|\n/,'')
    end

    def get_modified_config_files
      modified_files = []
      @hostname = capture('hostname', :hosts => @host).strip
      dir = "config/servers/#{hostname}"
      Dir["#{dir}/**/*"].each do |file|
        next if File.directory?(file)

        local_file = File.read(file)
        remote_location = (local_file.match(/#\s*location:\s*(.+)$/)[1] rescue nil)
        if remote_location.nil? or remote_location.length == 0
          puts "Could not find location: setting in configuration file #{file}"
          next
        end

        if !compare_files(local_file, remote_file)
          modified_files << local_file
        end
      end

      modified_files
    end

    def replace_remote_file
      puts "replacing remote file #{remote_location}"
      put(local_file, remote_location, :host => @host)
    end

    def create_remote_backup(remote_file_path)
      backup_file = remote_file_path + ".cap_bak"
      puts "saving backup of #{remote_file_path} to #{backup_file}"
      run('cp #{remote_file_path} #{backup_file}', :hosts => @host)
    end

    def restart_service(local_file)
      restart_command = (local_file.match(/#\s*restart:\s*(.+)$/)[1] rescue nil)
      if restart_command
        puts "restarting remote service"
        run(remote_command, :hosts => @host)
      end
    end
  end
end