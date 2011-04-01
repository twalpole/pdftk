$LOAD_PATH.unshift File.dirname(__FILE__)

require 'tempfile'
require 'rubygems'
require 'haml'

module Pdftk
  class << self
    # Provides configurability to Pdftk. There are a number of options available, such as:
    # * log: Logs progress to the Rails log. Uses ActiveRecord's logger, so honors
    #   log levels, etc. Defaults to true.
    # * command_path: Defines the path at which to find the command line
    #   program pdftk if it is not visible to Rails the system's search path. Defaults to
    #   nil, which uses the first executable found in the user's search path.
    def options
      @options ||= {
        :command_path      => nil,
        :log               => false,
        :log_command       => true,
        :swallow_stderr    => true
      }
    end

    def configure
      yield(self) if block_given?
    end

    # The run method takes a command to execute and an array of parameters
    # that get passed to it. The command is prefixed with the :command_path
    # option from Pdftk.options. If you have many commands to run and
    # they are in different paths, the suggested course of action is to
    # symlink them so they are all in the same directory.
    #
    # If the command returns with a result code that is not one of the
    # expected_outcodes, a PdftkCommandLineError will be raised. Generally
    # a code of 0 is expected, but a list of codes may be passed if necessary.
    # These codes should be passed as a hash as the last argument, like so:
    #
    #   Pdftk.run("echo", "something", :expected_outcodes => [0,1,2,3])
    #
    # This method can log the command being run when
    # Pdftk.options[:log_command] is set to true (defaults to false). This
    # will only log if logging in general is set to true as well.
    def run cmd, *params
      CommandLine.path = options[:command_path]
      CommandLine.new(cmd, *params).run
    end

    # Log a Pdftk-specific line. Uses ActiveRecord::Base.logger
    # by default. Set Pdftk.options[:log] to false to turn off.
    def log message
      logger.info("[Pdftk] #{message}") if logging?
    end

    def logger #:nodoc:
      ActiveRecord::Base.logger
    end

    def logging? #:nodoc:
      options[:log]
    end
  end  
  
end

require 'pdftk/pdf'
require 'pdftk/field'
require 'pdftk/command_line'
