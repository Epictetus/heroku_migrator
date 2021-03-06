require 'thor'

begin
  require 'posix-spawn'
rescue LoadError
end

module HerokuMigrator
  class CLI < Thor
    include Thor::Actions

    default_task :help

    desc 'migrate APP', 'Migrate your database'

    method_option :maintenance, type: :boolean, aliases: '-m', default: true,
      desc: 'Use maintenance mode while copying data between databases'

    method_option :database_type, type: :string, aliases: '-d',
      default: 'heroku-postgresql:dev',
      desc: 'Specify the type of database to provision. http://www.heroku.com/pricing'

    def migrate(app)
      @app = app

      say "Using #{require_heroku_cli!}"

      provision_new_database

      maintenance do
        copy_database_contents
        promote_new_database
      end

      deprovision_old_database if yes?('Remove old database?')
    end

    private

    def require_heroku_cli!
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = "#{path}/heroku#{ext}"
          return exe if File.executable? exe
        end
      end
      say 'Heroku CLI is required. You need to install the heroku gem or toolbelt (https://toolbelt.heroku.com/).'
      exit 1
    end

    def app_option
      "-a #{@app}"
    end

    def tell_heroku(cmd)
      run "heroku #{cmd} #{app_option}"
      exit $?.exitstatus unless $?.success?
    end

    def addons
      @addons ||= `heroku addons #{app_option}`.lines.to_a[1..-1]
    end

    def addon_present?(addon)
      addons.any? { |description| description.include?(addon) }
    end

    def add_addon(addon)
      tell_heroku "addons:add #{addon}" unless addon_present?(addon)
    end

    def provision_new_database
      add_addon options[:database_type]
      add_addon 'pgbackups'

      # Development instances are provisioned instantly, but paid instances
      # take 3-5 minutes to become available. The `pg:wait` command will block
      # until the database instance comes up.
      tell_heroku 'pg:wait'
    end

    def copy_database_contents
      tell_heroku "pgbackups:capture --expire --confirm #{@app}"
      tell_heroku "pgbackups:restore #{pg_color} --confirm #{@app}"
    end

    def promote_new_database
      tell_heroku "pg:promote #{pg_color}"
    end

    def deprovision_old_database
      tell_heroku 'addons:remove shared-database'
    end

    def maintenance_mode(state)
      tell_heroku "maintenance:#{state}"
    end

    def maintenance
      maintenance_mode(:on) if options[:maintenance]

      yield

      if options[:maintenance] && yes?('Are you happy to go live?')
        maintenance_mode(:off)
      end
    end

    def pg_color
      @pg_color ||= `heroku config #{app_option} | grep POSTGRESQL`.split(':').
        first.sub(/_URL$/, '')
    end
  end
end
