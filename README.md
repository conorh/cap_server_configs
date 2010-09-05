Capistrano Server Configs
=========================

Extremely simple management, deployment and versioning of your server configuration files (nginx, mysql, apache etc.) from your Rails repository.

Store your configuration files in config/servers/some.server.com/. The hostname reported by the server when you do 'hostname' should exactly match the name of the directory. Each configuration file should contain the location of the file on that server on a line like this: 

     # location: /etc/my.cnf

     ... rest of configuration file

The capistrano task server_configs:update then compares the remote file at that location to the local file. If it has changed it replaces the remote file and runs a restart command, also specified in the configuration file:

    # restart: sudo /etc/init.d/mysql restart

There is also a capistrano task service_configs:check that will check each file to see if it has changed, and output a diff of the changes, but not replace the file.

PREREQUISITES
-------------

The script assumes you have capistrano of course, and it also uses the command 'diff' to output diffs of local and remote files (command is required locally).

INSTALLATION
------------

    # FROM RAILS_ROOT
    ruby script/plugin install git://github.com/conorh/cap_server_configs.git

Create a directory in config/ named servers/ and create directories for each server you want to manage. The hostname reported by the server when you do 'hostname' should *exactly* match the name of each directory in servers. Example structure:

    config/
      servers/
        server1.domain.com/
          my.cnf
          nginx.conf
          monit/
            mysql.conf
            nginx.conf
        server2.domain.com/
          redis.conf
          logrotate/
             rails

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

USAGE
-----

Check for modified server configurations. Report them, and output a diff, but do not restart any services.

    cap production server_configs:check

Check for modified server configurations. Replace them with the local version and restart
services for any that were replaced (and that have a # restart: line)

    cap production server_configs:update

Check for modified server configurations. Replace the local version with the server version.

   cap production server_configs:update_local

COPYRIGHT
---------

Copyright (c) 2010 Conor Hunt <conor.hunt AT gmail>
Released under the MIT license