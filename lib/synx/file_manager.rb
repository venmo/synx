require 'fileutils'

module Synx
  class FileManager

    def initialize
      @options = {}
    end

    def rm_rf(list)
      unless dry_run
        FileUtils.rm_rf(list)
      end
    end

    def mv(src, dest)
      unless dry_run
        FileUtils.mv(src, dest)
      end
    end

    def options=(options = {})
      @options = options
    end

    def options
      @options
    end

    def dry_run
      @options.key?(:warn)
    end

  end
end
