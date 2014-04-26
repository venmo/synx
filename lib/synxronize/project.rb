require 'xcodeproj'

module Synxronize
  class Project

    TEMP_DIR_NAME_PREFIX = ".synxronize-"

    def initialize(path)
      @xcodeproj = Xcodeproj::Project.open(path)
    end

    def self.open(path)
      return new(path)
    end

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

    def root_path
      @root_path ||= Pathname(@xcodeproj).parent.to_s
    end
    private :root_path

    def temp_root_path
      if @temp_root_path 
        @temp_root_path
      else
        temp_dir_name = TEMP_DIR_NAME_PREFIX + Pathname(root_path).basename.to_s
        temp_dir_pathname = Pathname(root_path).parent + temp_dir_name
        temp_dir_pathname.mkdir
        @temp_root_path = temp_dir_pathname.to_s
      end
    end
    private :temp_root_path

  end
end



