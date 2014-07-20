# Rubytest CLI

[Website](http://rubyworks.github.com/rubytest-cli) /
[Support](http://github.com/rubyworks/rubytest-cli/issues) /
[Development](http://github.com/rubyworks/rubytest-cli)

<b>Command line interface for running tests for Rubytest-based test frameworks.</b>


## Status

[![Gem Version](http://img.shields.io/gem/v/rubytest-cli.svg?style=flat)](http://rubygems.org/gem/rubytest-cli)
[![Build Status](http://img.shields.io/travis/rubyworks/rubytest-cli.svg?style=flat)](http://travis-ci.org/rubyworks/rubytest-cli)
[![Fork Me](http://img.shields.io/badge/scm-github-blue.svg?style=flat)](http://github.com/rubyworks/rubytest-cli)
[![Report Issue](http://img.shields.io/github/issues/rubyworks/rubytest-cli.svg?style=flat)](http://github.com/rubyworks/rubytest-cli/issues)
[![Gittip](http://img.shields.io/badge/gittip-$1/wk-green.svg?style=flat)](https://www.gittip.com/on/github/rubyworks/)
[![Flattr Me](http://api.flattr.com/button/flattr-badge-large.png)](http://flattr.com/thing/324911/Rubyworks-Ruby-Development-Fund)


## Usage

The rubytest command-line tool follows many of the usual conventions
so it's use is farily straightforward. The `-h/--help` option is 
available to detail all its options. Here is a basic example of usage. 

    $ rubytest -Ilib test/*_test.rb

This would add `lib` to Ruby's $LOAD_PATH and then load all the 
test files matching the `test/*_test.rb` glob.

When running tests, you need to be sure to load in your test framework
or your framework's Ruby Test adapter. This is usually done via a helper
script in the test files, but might also be done via command line options,
e.g.

    $ rubytest -r lemon -r ae test/test_*.rb

Of course, it can become tedious having to type such a long command
over and over. One way to handle this is to use an a *runtime adjunct tool*
like [DotOpts](http://rubyworks.github.com/dotopts). For example, a project
might add a `.opts` file with the entry:

    rubytest
      -f progress
      -r spectroscope
      -r rspecial
      spec/spec_*.rb

That will work in many cases, but to make things *solid* Ruby Test CLI
supports a default configuration file. To utilize, add an `etc/test.rb` file
to a project and add `Test.run` (or the alias `Test.configure`) entries to it.

```ruby
    Test.run do |r|
      r.loadpath 'lib'
      r.test_files << 'test/*_test.rb'
    end

    Test.run 'coverage' do |r|
      r.loadpath 'lib'
      r.test_files << 'test/*_test.rb'
      r.before do
        require 'simplecov'
        Simplecov.setup do |s|
          s.filter 'test/'
          s.command_name File.basename($0)
          s.coverage_dir 'log/coverage'    
        end
        # to ensure proper coverage
        require 'myapp'
      end
    end
```

Now when rubytest is used, the first configuration will apply. To use
the 'coverage' configuration use `-p/--profile` option.

    $ rubytest -p coverage

In this manner a project can have any number of different test configurations,
and it is easy to select between them.

Note that the above example could have used `Test.configure` instead
of `Test.run`. They do the same thing. But do not use `Test.run!` because
that will cause testing to be run immediately.

The configuration file can be in the `config` directory instead of `etc`, which
is nice for Rails projects. But if you prefer a file in the project's root 
then either `Testfile` or `.test` can be also be used instead. All of these
locations are supported simply because no one configuration convention has 
taken a solid hold in the Ruby community. However, we highly recommend using
`etc/test.rb`. In the end that seems like the best overall convention.


## Copyrights

Rubytest CLI is copyrighted open-source software.

    Copyright (c) 2013 Rubyworks. All rights reserved.

It is redistributable and modifiable in accordance with the terms of the
[BSD-2-Clause] license.

See LICENSE.txt for the full text.


