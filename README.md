# Hamish

Hamish is a (slightly) opinionated programmer-centric static website
generator. It is build on top of rake and is meant to be easily extended.
Essentially it adds a minimal dsl to be used in Rakefiles, which build rake
tasks. The primary methods are:

- `transform` -- Convert an input file to output (e.g., sass -> css, or markdown -> html)
- `copy_files` -- Static file copy
- `clean`
- `sitemap`
- `deploy` -- Use rsync to push site to server.

## Installation

Add this line to your site's Rakefile:

```ruby
gem 'hamish'
```

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake
install`. To release a new version, update the version number in `version.rb`,
and then run `bundle exec rake release` to create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/hamish/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
