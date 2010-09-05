module CapServerConfigs
  class Helper
    attr_accessor :host
    attr_accessor :cap

    def initialize(cap)
      self.cap = cap
    end

    def get_cap_hosts
      cap_hosts = []
      cap.run('hostname') do |channel, stream, data|
        cap_hosts << channel[:server].instance_variable_get(:@host)
      end
      cap_hosts
    end

    def strip_cap_server_config_commands(file)
      file = file.gsub(/#\s*location:\s*.+\n/, '')
      file.gsub(/#\s*restart:\s*.+\n/, '')
    end

    def compare_files(local_file, remote_file)
      local_file = strip_cap_server_config_commands(local_file).gsub(/^\s*\n/, '')
      remote_file = remote_file.gsub(/^\s*\n/, '')
      remote_file.gsub(/\r|\n/,'') == local_file.gsub(/\r|\n/,'')
    end

    def get_modified_config_files
      modified_files = []
      hostname = cap.capture('hostname', :hosts => @host).strip
      dir = "config/servers/#{hostname}"
      Dir["#{dir}/**/*"].each do |local_path|
        next if File.directory?(local_path)

        local_file = File.read(local_path)
        remote_path = (local_file.match(/#\s*location:\s*(.+)$/)[1] rescue nil)
        if remote_path.nil? or remote_path.length == 0
          puts "Could not find location: setting in configuration file #{local_path}"
          next
        end

        remote_file = cap.capture("cat #{remote_path}", :hosts => @host)

        if !compare_files(local_file, remote_file)
          modified_files << {:local => local_file, :remote => remote_file, :local_path => local_path, :remote_path => remote_path}
        end
      end

      modified_files
    end

    def replace_remote_file(local_file, remote_path)
      puts "replacing remote file #{remote_path}"
      cap.put(local_file, remote_path, :host => @host)
    end

    def create_remote_backup(remote_file_path)
      backup_file_path = remote_file_path + ".cap_bak"
      puts "saving backup of #{remote_file_path} to #{backup_file_path}"
      cap.run("cp #{remote_file_path} #{backup_file_path}", :hosts => @host)
    end

    def restart_service(local_file)
      restart_command = (local_file.match(/#\s*restart:\s*(.+)$/)[1] rescue nil)
      if restart_command
        puts "restarting remote service"
        cap.run(remote_command, :hosts => @host)
      end
    end
  end
end