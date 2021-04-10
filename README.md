# Branchtree

Command-line tool to interactively manage chains or trees of dependent branches in a git repository.

## Installation

Install the gem from Rubygems:

    $ gem install branchtree

## Usage

Configure your desired branch topology by creating a file called `branchtree-map.yml` in your home directory.

```yml
---
- branch: first-branch
  children:
  - branch: second-branch-v1
    children:
    - branch: third-branch-v1
      rebase: true
  - branch: second-branch-v2
```

View your current place in the branch tree by running:

```
$ branchtree show

# Or:

$ branchtree
```

Interactively check out a different branch in the tree with:

```
$ branchtree checkout
```

If you've made commits to a non-leaf branch, run this to propagate changes forward through the tree with merges and rebases:

```
$ branchtree update
```

To see the full usage, run:

```
$ branchtree help
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/branchtree. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/branchtree/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Branchtree project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/branchtree/blob/master/CODE_OF_CONDUCT.md).
