require 'fileutils'
require 'xcodeproj'

module Synxronize
  class Project < Xcodeproj::Project

    SYNXRONIZE_DIR = File.join(ENV["HOME"], '.synxronize')
    private_constant :SYNXRONIZE_DIR

    DEFAULT_EXCLUSIONS = %W(/Libraries /Frameworks)
    private_constant :DEFAULT_EXCLUSIONS

    attr_accessor :delayed_groups_set_path, :group_exclusions

    def self.open(project)
      project = super
      project.group_exclusions = DEFAULT_EXCLUSIONS
      project
    end

    def sync
      main_group.groups.each { |group| group.sync(pathname_to_work_pathname(main_group.real_path)) }
      # Set group paths after we're done syncing everything, so that calls to group.realpath don't
      # give us paths to the working directory while we're syncing
      main_group.sync_child_group_paths
      transplant_work_project
      save
    end

    # def move_entries_not_in_xcodeproj(group, group_work_pathname)
    #   group_pathname = work_pathname_to_pathname(group_work_pathname)
    #   if group_pathname.exist?
    #     Dir[group_pathname.realpath.to_s + "/*"].each do |entry|
    #       entry_pathname = group_pathname + entry
    #       # TODO: Need a way to handle directories, too.
    #       unless File.directory?(entry_pathname.to_s) || entry_in_group?(group, entry_pathname)
    #         FileUtils.mv(entry_pathname.realpath, group_work_pathname.to_s)
    #       end
    #     end
    #   end
    # end
    # private :move_entries_not_in_xcodeproj

    # def entry_in_group?(group, entry_pathname)
    #   %W(. ..).include?(entry_pathname.basename.to_s) || group.children.any? do |child|
    #     child.real_path.cleanpath == entry_pathname.realpath.cleanpath
    #   end
    # end
    # private :entry_in_group?

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

    # def fix_build_settings_if_necessary(old_pathname, new_pathname)
    #   if old_pathname.to_s =~ /Prefix\.pch$/
    #   elsif old_pathname.to_s =~ /Info\.plist$/
    #   end
    # end
    # private :fix_build_settings_if_necessary

    # def fix_build_setting(setting, old_path, new_pathname)
    #   targets.each do |t|

    #   end
    # end
    # private :fix_build_setting

    # def each_group
    # end

  end
end



