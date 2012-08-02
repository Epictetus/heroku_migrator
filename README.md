# HerokuMigrator

This gem is provided AS-IS with no warranty or guarantees. If you run
this gem you will be moving data in your Heroku database. There's a
chance you will lose data. Back everything up before you even think
about running heroku_migrator!

## Installation

Install it yourself using:

    $ gem install heroku_migrator

## Usage

```
Usage:
  heroku_migrator migrate APP

Options:
  -m, [--maintenance]                  # Use maintenance mode while copying data between databases
                                       # Default: true
  -d, [--database-type=DATABASE_TYPE]  # Specify the type of database to provision. http://www.heroku.com/pricing
                                       # Default: heroku-postgresql:dev
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
