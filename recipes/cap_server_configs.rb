require File.dirname(__FILE__) + '/helpers'

namespace :server_configs do
  desc "Check for modified configuration files, replace them with the local version and restart services"
  task :update, :only => { :manage_configs => true } do
    helper = CapServerConfigs::Helper.new(self)
    helper.get_cap_hosts.each do |host|
      helper.host = host
      helper.get_modified_config_files.each do |file_info|
        puts "\033[33m#{file_info[:local_path]} differs from #{file_info[:remote_path]}\033[0m\n"
        helper.create_remote_backup(file_info[:remote_path])
        helper.replace_remote_file(file_info[:local_file], file_info[:remote_path])
        helper.restart_service(file_info[:local_file])
      end
    end
  end

  desc "Check for modified configuration files"
  task :check, :only => { :manage_configs => true } do
    helper = CapServerConfigs::Helper.new(self)
    output = ""
    helper.get_cap_hosts.each do |host|
      helper.host = host
      helper.get_modified_config_files.each do |file_info|
         output += "\n"
         output += "\033[33m#{file_info[:local_path]} differs from #{file_info[:remote_path]}\033[0m\n"
         File.open("/tmp/local_config","w") {|f| f << helper.strip_cap_server_config_commands(file_info[:local_file]) }
         File.open("/tmp/remote_config","w") {|f| f << file_info[:remote_file] }
         output += `diff -w -B -u /tmp/remote_config /tmp/local_config`
      end
    end
    puts output
  end
end