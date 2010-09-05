require 'helpers'

namespace :server_configs do
  desc "Check for modified configuration files, replace them with the local version and restart services"
  task :replace, :only => { :manage_configs => true } do
    helper = CapServerConfig::Helper.new
    cap_hosts = helper.get_all_cap_hosts
    cap_hosts.each do |host|
      helper.host = host
      files = helper.get_modified_config_files
      files.each do |file_info|
        helper.create_remote_backup(file_info)
        helper.replace_remote_file(file_info)
        helper.restart_service(file_info)
      end
    end
  end

  desc "Check for modified configuration files"
  task :check, :only => { :manage_configs => true } do
    helper = CapServerConfig::Helper.new
    cap_hosts = helper.get_all_cap_hosts
    cap_hosts.each do |host|
      helper.host = host
      files = helper.get_modified_config_files
      files.each do |file_info|
         puts "#{file_info[:local_path]} differs from #{file[:remote_path]}"
         File.open("/tmp/local_config","w") {|f| f << file_info[:local] }
         File.open("/tmp/remote_config","w") {|f| f << file_info[:remote] }
         puts `git diff -w /tmp/local_config /tmp/remote_config`
      end
    end
  end
end