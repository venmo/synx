require 'fileutils'
require 'xcodeproj'

module Synxronize
  class Project < Xcodeproj::Project

    SYNXRONIZE_DIR = File.join(ENV["HOME"], '.synxronize')
    private_constant :SYNXRONIZE_DIR

    def sync
      sync_group(@xcodeproj.root_object.main_group)
    end

    def sync_group(group)
      group.files
    end
    private :sync_group

    def sync_file
    end
    private :sync_file

    def root_pathname
      @root_pathname ||= Pathname(path).parent
    end
    private :root_pathname

    def work_root_pathname
      if @work_root_pathname 
        @work_root_pathname
      else
        @work_root_pathname = Pathname(File.join(SYNXRONIZE_DIR, root_pathname.basename.to_s))
        # Clean up any previous synx and start fresh
        FileUtils.rm_rf(@work_root_pathname.to_s) if @work_root_pathname.exist?
        @work_root_pathname.mkpath
        @work_root_pathname
      end
    end
    private :work_root_pathname

  end
end



