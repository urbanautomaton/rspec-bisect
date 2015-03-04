# RSpec Bisect

A tool for reducing order-dependent test failures to a minimal set of
failing examples.

## Explanation

If your test suite writes to global state that persists between
individual tests -- application configuration, external caches, or any
other type of globals -- then there is the possibility of
order-dependent test failures.

In a large test suite, the test responsible for mutating the state that
causes the eventual failure can be very far removed from the test that
actually fails.

This gem automates the reduction of an order-dependent test failure by:

1. Recording the order of example groups in the failed test
2. Replaying the test in this recorded order
3. Applying binary search to the failing example set until a single
   responsible example is found.

## Caveats

The tool assumes that there is a single culpable example, and will
proceed in reducing the example set until one is found. If multiple
dependent examples combine to cause the failure, a) that's really bad
luck for you, and b) this probably won't find them.

If there are multiple examples that *independently* cause the failure,
this will identify them one at a time.

Finally, this is very 0.0.1 - while bits of the core logic are tested,
other bits aren't and are in flux. Also the output is, to put it mildly,
rubbish.

## Installation

Add this line to your application's Gemfile:

    gem 'rspec-bisect'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-bisect

## Usage

First, identify an order-dependent failing rspec run. For example, if
you clone this repo and bundle install, the following will fail:

```
$ bundle exec rspec dummy/spec --fail-fast --seed 1234

Randomized with seed 1234
.............F

Failures:

  1) a second group in a file does not expect the Spanish Inquisition
     Failure/Error: expect(ENV.fetch("GLOBAL_MUTABLE_STATE", 3)).to eq 3

       expected: 3
            got: "The Spanish Inquisition"

       (compared using ==)
     # ./dummy/spec/other_spec.rb:11:in `block (2 levels) in <top (required)>'

Finished in 0.00351 seconds (files took 0.10925 seconds to load)
14 examples, 1 failure

Failed examples:

rspec ./dummy/spec/other_spec.rb:10 # a second group in a file does not expect the Spanish Inquisition

Randomized with seed 1234
```

Then, simply replace the `rspec` command with `rspec-bisect`:

```
$ bundle exec rspec-bisect dummy/spec --fail-fast --seed 1234
Recording failing example order
Searching within 13 candidates...
[█████████████] ✘
[███████______] ✔
[_______██████] ✘
[_______███___] ✘
[_______██____] ✘
[_______█_____] ✔
[________█____] ✘

The culprit appears to be at ./dummy/spec/in_order_spec.rb:24
```

## Contributing

1. Fork it ( https://github.com/urbanautomaton/rspec-bisect/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
