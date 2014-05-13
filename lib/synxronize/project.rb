require 'fileutils'
require 'xcodeproj'

module Synxronize
  class Project < Xcodeproj::Project

    SYNXRONIZE_DIR = File.join(ENV["HOME"], '.synxronize')
    private_constant :SYNXRONIZE_DIR

    DEFAULT_EXCLUSIONS = %W(/Libraries /Frameworks /Products)
    private_constant :DEFAULT_EXCLUSIONS

    attr_accessor :delayed_groups_set_path, :group_exclusions

    def self.open(project)
      project = super
      project.group_exclusions = DEFAULT_EXCLUSIONS
      project
    end

    def sync
      main_group.all_groups.each(&:sync)
      main_group.all_groups.each(&:move_entries_not_in_xcodeproj)
      transplant_work_project
      save
    end

    def transplant_work_project
      # Move the synced entries over
      Dir.glob(work_root_pathname + "*").each do |path|
        FileUtils.rm_rf(work_pathname_to_pathname(Pathname(path)))
        FileUtils.mv(path, root_pathname.to_s)
      end
    end
    private :transplant_work_project

    def root_pathname
      @root_pathname ||= Pathname(path).parent
    end

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

    # We build up the new project structure in a temporary workspace, so convert a file path in the project space to
    # one in the temp workspace.
    def pathname_to_work_pathname(pathname)
      work_root_pathname + pathname.relative_path_from(root_pathname)
    end

    def work_pathname_to_pathname(work_pathname)
      root_pathname + work_pathname.relative_path_from(work_root_pathname)
    end

    def pathname_is_inside_root_pathname?(grandchild_pathname)
      grandchild_pathname.realpath.to_s =~ /^#{root_pathname.realpath.to_s}/
    end

  end
end



