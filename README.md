Capistrano Server Configs
=========================

Simplest possible way of managing and versioning your server configuration files in your repository.

Capistrano recipe for managing configuration files on your servers. Assumes you have stored your configuration files
in config/servers/hostname_of_server/ or a subdirectory. Each configuration file then contains a line specifying the
location of the file on that server, ex.
   
     # location: /etc/my.cnf

The capistrano task compares the remote file it to the local file. If it has changed it replaces the
remote file and runs a restart command for that service, also specified in the configuration file:

    # restart: sudo /etc/init.d/mysql restart

INSTALLATION
------------

    # FROM RAILS_ROOT
    ruby script/plugin install git://github.com/conorh/cap_crontab.git

Create a directory in config/ named crontabs/ and create crontab files for each
environment where you want to install a crontab:

    config/
      servers/
        server1/
          my.cnf
          nginx.conf
          monit/
            mysql.conf
            nginx.conf

Example config file:

  # location: /etc/my.cnf
  # restart: sudo /etc/init.d/mysql restart
  
  ... rest of configuration file

In your deploy file add the :manage_server_configs => true flag on the server(s) where you'd
like this task run

    task :staging do
      role :web,                  'example.com'
      role :app,                  'example.com', :manage_server_configs => true
      role :db,                   'example.com', :primary => true
    end

== USAGE

Check for modified server configurations. Report them, but do not restart any services.

    cap production server_configs:check

Check for modified server configurations. Replace them and restart services for any that were replaced (and that have a replace: line)

    cap production server_configs:replace

== COPYRIGHT

Copyright (c) 2010 Conor Hunt <conor.hunt AT gmail>
Released under the MIT license