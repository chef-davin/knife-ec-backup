#
# Author:: Steven Danna (<steve@getchef.com>)
# Copyright:: Copyright (c) 2014 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife'

class Chef
  class Knife
    module EcKeyBase

      def self.included(includer)
        includer.class_eval do

          deps do
            require 'sequel'
            require 'json' unless defined?(JSON)
          end

          option :sql_host,
          :long => '--sql-host HOSTNAME',
          :description => 'Postgresql database hostname (default: localhost)',
          :default => "localhost"

          option :sql_port,
          :long => '--sql-port PORT',
          :description => 'Postgresql database port (default: 5432)',
          :default => 5432

          option :sql_db,
          :long => '--sql-db DBNAME',
          :description => 'Postgresql Chef Server database name (default: opscode_chef)',
          :default => "opscode_chef"

          option :sql_user,
          :long => "--sql-user USERNAME",
          :description => 'User used to connect to the postgresql database.'

          option :sql_password,
          :long => "--sql-password PASSWORD",
          :description => 'Password used to connect to the postgresql database'

          option :secrets_file_path,
          :long => '--secrets-file PATH',
          :description => 'Path to a valid private-chef-secrets.json file (default: /etc/opscode/private-chef-secrets.json)',
          :default => '/etc/opscode/private-chef-secrets.json'

          option :skip_keys_table,
          :long => "--skip-keys-table",
          :description => "Skip Chef 12-only keys table",
          :default => false

          option :skip_users_table,
          :long => "--skip-users-table",
          :description => "Skip users table",
          :default => false
        end
      end

      def db
        @db ||= begin
                  require 'sequel'
                  server_string = "#{config[:sql_user]}:#{config[:sql_password]}@#{config[:sql_host]}:#{config[:sql_port]}/#{config[:sql_db]}"
                  ::Sequel.connect("postgres://#{server_string}", :convert_infinite_timestamps => :string)
                end
      end

      # Loads SQL user and password from running config if not passed
      # as a command line option
      def load_config_from_file!
        if ! File.exists?("/etc/opscode/chef-server-running.json")
          ui.fatal "SQL User or Password not provided as option and running config cannot be found!"
          exit 1
        else
          running_config ||= JSON.parse(File.read("/etc/opscode/chef-server-running.json"))
          # Latest versions of chef server put the database info under opscode-erchef.sql_user
          hash_key = if running_config['private_chef']['opscode-erchef'].has_key? 'sql_user'
                       'opscode-erchef'
                     else
                       'postgresql'
                     end
          config[:sql_user] ||= running_config['private_chef'][hash_key]['sql_user']
          config[:sql_password] ||= sql_password
        end
      end

      def veil_config
        { provider: 'chef-secrets-file',
          path: config[:secrets_file_path] }
      end

      def veil
        Veil::CredentialCollection.from_config(veil_config)
      end

      def sql_password
        if config[:sql_password]
          config[:sql_password]
        elsif veil.exist?("opscode_erchef", "sql_password")
          veil.get("opscode_erchef", "sql_password")
        else veil.exist?("postgresql", "sql_password")
          veil.get("postgresql", "sql_password")
        end
      end
    end
  end
end
