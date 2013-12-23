module Userq
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    # Setup and create the migration
    def do_migration
      migration_exists = Dir["db/migrate/*_create_user_queues.rb"].count > 0

      if migration_exists and installing?
        puts "UserQ is already installed. Maybe a 'rake db:migrate' command might help?"
        return
      end

      create_migration

      puts "Success! UserQ is installed. You can now use it in your application." if installing?
      puts "UserQ has already been uninstalled. Remember the 'user_queue' table needs to be manually destroyed." if destroying? and migration_exists == false
      puts "Success! UserQ is uninstalled. The table 'userq_queue' needs to be destroyed manually to complete removal." if destroying? and migration_exists
  end

    private

      def create_migration
        migration_id = Time.now.to_i
        migration_exists = Dir["db/migrate/*_create_user_queues.rb"].count > 0

        copy_file "migration.rb", "db/migrate/#{migration_id}_create_user_queues.rb" if installing?
        copy_file "migration.rb", Dir["db/migrate/*_create_user_queues.rb"][0].to_s if destroying? and migration_exists

        run "rake db:migrate VERSION=#{migration_id}"
      end

    # Thanks to ynkr: http://stackoverflow.com/a/8829177/408177
    protected

      def installing?
        :invoke == behavior
      end

      def destroying?
        :revoke == behavior
      end
  end
end