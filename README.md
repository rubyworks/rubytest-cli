# Ruby Test CLI

Command line interface for running tests for RubyTest-based
test frameworks.


## Usage

The rubytest command-line tool follows many of the usual conventions
so it's use is farily straightforward. The `-h/--help` option is 
available to detail all its options. Here is a basic example of usage. 

    $ rubytest -Ilib test/*_test.rb

This would add `lib` to Ruby's $LOAD_PATH and then load all the 
test files matching the `test/*_test.rb` glob.

Of course, it can become tedious having to type such a long command
over and over, so to simply the `rubytest` command supports
preconfigurations. To use, add an `etc/test.rb` file to a project
and add `Test.run` entries.

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

Now when `rubytest` is used the first configuration will apply. To use
the 'coverage' configuration use `-p/--profile` option.

    $ rubytest -p coverage

In this manner your project can have any number of different test
configurations.

A few helpful notes about configuration.

The above example could also have used `Test.configure` inplace of `Test.run`.
They are aliases. But do not use `Test.run!` because they will cuase testing
to be run immediately.

The configuration file can be in the `config` directory instead of `etc`, which
is nice for Rails projects. But if you prefer a file in the project's root 
then either `Testfile` or `.test` can be also be used. All of these locations
are supported simply b/c no one configuration convention has taken a solid
hold in the Ruby community. However, we highly recommend using `etc/test.rb`.
In the end that seems like the best overall convention (and beleive me, I've
analyized the hell out of every option!).


## Copyrights

Rubytest CLI is copyrighted open-source software.

    Copyright (c) 2013 Rubyworks. All rights reserved.

It is redistributable and modifiable in accordance with the terms of the
[BSD-2-Clause] license.

See LICENSE.txt for the full text.


