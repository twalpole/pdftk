module Pdftk
  class CommandLine
    class << self
      attr_accessor :path
    end

    def initialize(params = "", options = {})
      @binary            = 'pdftk'
      @params            = params.dup
      @options           = options.dup
      @swallow_stderr    = @options.has_key?(:swallow_stderr) ? @options.delete(:swallow_stderr) : Pdftk.options[:swallow_stderr]
      @expected_outcodes = @options.delete(:expected_outcodes)
      @expected_outcodes ||= [0]
    end

    def command
      cmd = []
      cmd << full_path(@binary)
      #cmd << interpolate(@params, @options)
      cmd << @params
      cmd << bit_bucket if @swallow_stderr
      cmd.join(" ")
    end

    def run
      Pdftk.log(command)
      begin
        output = self.class.send(:'`', command)
      rescue Errno::ENOENT
        raise Pdftk::CommandNotFoundError
      end
      if $?.exitstatus == 127
        raise Pdftk::CommandNotFoundError
      end
      unless @expected_outcodes.include?($?.exitstatus)
        raise Pdftk::PdftkCommandLineError, "Command '#{command}' returned #{$?.exitstatus}. Expected #{@expected_outcodes.join(", ")}"
      end
      output
    end

    private

    def full_path(binary)
      [self.class.path, binary].compact.join("/")
    end

    def shell_quote(string)
      return "" if string.nil? or string.blank?
      if self.class.unix?
        string.split("'").map{|m| "'#{m}'" }.join("\\'")
      else
        %{"#{string}"}
      end
    end

    def bit_bucket
      self.class.unix? ? "2>/dev/null" : "2>NUL"
    end

    def self.unix?
      File.exist?("/dev/null")
    end
  end
  
  
  class PdftkError < StandardError #:nodoc:
  end

  class PdftkCommandLineError < PdftkError #:nodoc:
    attr_accessor :output
    def initialize(msg = nil, output = nil)
      super(msg)
      @output = output
    end
  end

  class CommandNotFoundError < PdftkError
  end  
  
  
end
