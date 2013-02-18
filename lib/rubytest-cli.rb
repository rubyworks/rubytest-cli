require 'rubytest'

module Test

  # Command line interface to test runner.
  #
  class CLI

    # Test configuration file can be in `etc/test.rb` or `config/test.rb`, or
    # `Testfile` or '.test` with optional `.rb` extension, in that order of 
    # precedence. To use a different file there is the -c/--config option.
    GLOB_CONFIG = '{etc/test.rb,config/test.rb,testfile.rb,testfile,.test.rb,.test}'

    # Convenience method for invoking the CLI.
    #
    # @return nothing
    def self.run(*argv)
      new.run(*argv)
    end

    # Initialize CLI instance.
    #
    # @return nothing
    def initialize
      require 'optparse'

      @config = {}
      @config_file = nil
      #@config = Test.configuration(true)
    end

    # Run tests.
    #
    # @return nothing
    def run(argv=nil)
      #require_dotopts
      argv = (argv || ARGV.dup)
      options.parse!(argv)

      @config[:files] = argv unless argv.empty?

      load_config

      test_config = Test.configuration(profile)
      test_config.apply_environment_defaults
      test_config.apply(@config)

      Test.run!(test_config)

      #runner = Runner.new(test_config)
      #begin
      #  success = runner.run
      #  exit -1 unless success
      #rescue => error
      #  raise error if $DEBUG
      #  $stderr.puts('ERROR: ' + error.to_s)
      #  exit -1
      #end
    end

    # TODO: Not sure if this should be used or not.
    def require_dotopts
      begin
        require 'dotopts'
      rescue LoadError
      end
    end

    # Setup OptionsParser instance.
    #
    # @return [OptionParser]
    def options
      conf = self

      OptionParser.new do |opt|
        opt.banner = "Usage: #{File.basename($0)} [options] [files ...]"

        opt.on '-p', '--profile NAME', 'use configuration profile' do |name|
          conf.profile = name
        end

        #opt.separator "PRESET OPTIONS:"
        #pnames = profile_names
        #unless pnames.empty?
        #  pnames.each do |pname|
        #    opt.separator((" " * 40) + "* #{pname}")
        #  end
        #end
        #opt.separator "CONFIG OPTIONS:"

        opt.on '-f', '--format NAME', 'report format' do |name|
          conf.format = name
        end
        opt.on '-y', '--tapy', 'shortcut for -f tapy' do
          conf.format = 'tapy'
        end
        opt.on '-j', '--tapj', 'shortcut for -f tapj' do
          conf.format = 'tapj'
        end

        # tempted to change -T
        opt.on '-t', '--tag TAG', 'select tests by tag' do |tag|
          conf.tags.concat makelist(tag)
        end
        opt.on '-u', '--unit TAG', 'select tests by software unit' do |unit|
          conf.units.concat makelist(unit)
        end
        opt.on '-m', '--match TEXT', 'select tests by description' do |text|
          conf.match.concat makelist(text)
        end

        opt.on '-A', '--autopath', 'automatically add paths to $LOAD_PATH' do |paths|
          conf.autopath = true
        end
        opt.on '-I', '--loadpath PATH', 'add given path to $LOAD_PATH' do |paths|
          #makelist(paths).reverse_each do |path|
          #  $LOAD_PATH.unshift path
          #end
          conf.loadpath.concat makelist(paths)
        end
        opt.on '-C', '--chdir DIR', 'change directory before running tests' do |dir|
          conf.chdir = dir
        end
        opt.on '-R', '--chroot', 'change to project root directory before running tests' do
          conf.chdir = Config.root
        end
        opt.on '-r', '--require FILE', 'require file' do |file|
          conf.requires.concat makelist(file)
        end
        opt.on '-c', '--config FILE', "use alternate config file" do |file|
          conf.config_files << file
        end
        #opt.on '-T', '--tests GLOB', "tests to run (if none given as arguments)" do |glob|
        #  config.files << glob
        #end
        opt.on '-V' , '--verbose', 'provide extra detail in reports' do
          conf.verbose = true
        end
        #opt.on('--log PATH', 'log test output to path'){ |path|
        #  config.log = path
        #}
        opt.on("--[no-]ansi" , 'turn on/off ANSI colors'){ |v| $ansi = v }
        opt.on("--debug" , 'turn on debugging mode'){ $DEBUG = true }

        #opt.separator "COMMAND OPTIONS:"
        opt.on('--about' , 'display information about rubytest') do
          puts "Ruby Test v%s" % [Test.index['version']]
          Test.index['copyrights'].each do |c|
            puts "(c) %s %s (%s)" % c.values_at('year', 'holder', 'license')
          end
          exit
        end
        opt.on('--version' , 'display rubytest version') do
          puts Test::VERSION
          exit
        end
        opt.on('-h', '--help', 'display this help message'){
          puts opt
          exit
        }
      end
    end

    # Test run configuration.
    #
    # @return [Hash]
    def config
      @config
    end

    # Load configuration file. An example file might look like:
    #
    #   Test.configure do |run|
    #     run.files << 'test/case_*.rb'
    #   end
    #
    # @deprecated Planned for deprecation in April 2013.
    def load_config
      file = config_file
      unless file
        if chdir
          file = Dir.glob(File.join(chdir, GLOB_CONFIG)).first
        else
          file = Dir.glob(GLOB_CONFIG).first
        end
      end
      load file if file
    end

    # Find traditional configuration file.
    #
    # @return [String] Config file path.
    def config_file
      @config_file
    end

    #
    def profile
      @profile
    end

    #
    def profile=(name)
      @profile = name.to_s
    end

    #
    def format
      @config[:format]
    end

    #
    def format=(format)
      @config[:format] = format.to_s
    end

    def tags
      @config[:tags] ||= []
    end

    def units
      @config[:units] ||= []
    end

    def match
      @config[:match] ||= []
    end

    def autopath?
      @config[:autopath]
    end

    def autopath=(bool)
      @config[:autopath] = !! bool
    end

    def chdir
      @config[:chdir]
    end

    def chdir=(dir)
      @config[:chdir] = dir.to_str
    end

    def loadpath
      @config[:loadpath] ||= []
    end

    def requires
      @config[:requires] ||= []
    end

    def verbose?
      @config[:verbose]
    end

    def verbose=(bool)
      @config[:verbose] = !! bool
    end

  private

    # If given a String then split up at `:` and `;` markers.
    # Otherwise ensure the list is an Array and the entries are
    # all strings and not empty.
    #
    # @return [Array<String>]
    def makelist(list)
      case list
      when String
        list = list.split(/[:;]/)
      else
        list = Array(list).map{ |path| path.to_s }
      end
      list.reject{ |path| path.strip.empty? }
    end

  end

end
