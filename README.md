Capistrano Server Configs
=========================

Simplest possible way to manage, deploy and version your server configuration files (nginx, mysql, apache etc.)
in your repository.

Store your configuration files in config/servers/some.server.com/ or a subdirectory. Each configuration file
then contains a line with the location of the file on that server:

     # location: /etc/my.cnf

     ... rest of configuration file

The capistrano task server_configs:replace then compares the remote file at that location to the local file. If
it has changed it replaces the remote file and runs a restart command, also specified in the configuration file:

    # restart: sudo /etc/init.d/mysql restart

There is also a capistrano task service_configs:update that will check each file to see if it has changed, and output a diff of the changes, but not replace the file.

PREREQUISITES
-------------

The script assumes you have capistrano of course, and it also uses the command 'diff' to output
diffs of local and remote files (command is required locally).

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