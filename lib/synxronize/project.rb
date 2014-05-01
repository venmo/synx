require 'fileutils'
require 'find'
require 'xcodeproj'

module Synxronize
  class Project < Xcodeproj::Project

    SYNXRONIZE_DIR = File.join(ENV["HOME"], '.synxronize')
    private_constant :SYNXRONIZE_DIR

    def sync
      @delayed_groups_set_path = []

      main_group.groups.each do |gr|
        unless ["Libraries", "Frameworks"].include?(name_for_object(gr))
          sync_group(gr, pathname_to_work_pathname(main_group.real_path))
        end
      end
      # Set group paths after we're done syncing everything, so that calls to group.realpath don't
      # give us paths to the working directory while we're syncing
      set_group_paths
      transplant_work_project
      save
    end

    def sync_group(group, parent_work_pathname)  
      group_work_pathname = parent_work_pathname + name_for_object(group)
      group_work_pathname.mkpath
      # Save this to set after everything, or else it will mess up real_paths
      @delayed_groups_set_path << group

      group.files.each { |pbx_file| sync_pbx_file(pbx_file, group_work_pathname) }
      group.groups.each { |gr| sync_group(gr, group_work_pathname) }
      move_entries_not_in_xcodeproj(group, group_work_pathname)
    end
    private :sync_group

    def sync_pbx_file(pbx_file, parent_work_pathname)
      if should_sync_pbx_file?(pbx_file)
        if should_move_pbx_file?(pbx_file)
          FileUtils.mv(pbx_file.real_path.to_s, parent_work_pathname.to_s)
          pbx_file.source_tree = "<group>"
          pbx_file.path = pbx_file.real_path.basename.to_s
        else
          # Don't move these files around -- they're not even inside the structure. Just fix the relative references.
          pbx_file.path = pbx_file.real_path.relative_path_from((work_pathname_to_pathname(parent_work_pathname))).to_s
        end
      end
    end
    private :sync_pbx_file

    def should_sync_pbx_file?(pbx_file)
      # Don't sync files that don't exist or are Apple/Build stuff
      pbx_file.real_path.exist? && !(pbx_file.real_path.to_s =~ /^\$\{(SDKROOT|DEVELOPER_DIR|BUILT_PRODUCTS_DIR)\}/)
    end
    private :should_sync_pbx_file?

    def should_move_pbx_file?(pbx_file)
      # Don't move these files around -- they're not even inside the structure. Just fix the relative references.
      !(pbx_file.real_path.to_s =~ /\.xcodeproj$/) && pathname_is_inside_root_pathname?(pbx_file.real_path)
    end

    def move_entries_not_in_xcodeproj(group, group_work_pathname)
      group_pathname = work_pathname_to_pathname(group_work_pathname)
      if group_pathname.exist?
        Dir[group_pathname.realpath.to_s + "/*"].each do |entry|
          entry_pathname = group_pathname + entry
          unless File.directory?(entry_pathname.to_s) || entry_in_group?(group, entry_pathname)
            FileUtils.mv(entry_pathname.realpath, group_work_pathname.to_s)
          end
        end
      end
    end
    private :move_entries_not_in_xcodeproj

    def entry_in_group?(group, entry_pathname)
      %W(. ..).include?(entry_pathname.basename.to_s) || group.children.any? do |child|
        child.real_path.cleanpath == entry_pathname.realpath.cleanpath
      end
    end
    private :entry_in_group?


    def set_group_paths
      @delayed_groups_set_path.each { |group| group.path = name_for_object(group) }
    end
    private :set_group_paths

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

    def name_for_object(object)
      object.name || object.path || Pathname(object.real_path).basename.to_s
    end
    private :name_for_object

    # We build up the new project structure in a temporary workspace, so convert a file path in the project space to
    # one in the temp workspace.
    def pathname_to_work_pathname(pathname)
      work_root_pathname + pathname.relative_path_from(root_pathname)
    end
    private :pathname_to_work_pathname

    def work_pathname_to_pathname(work_pathname)
      root_pathname + work_pathname.relative_path_from(work_root_pathname)
    end
    private :work_pathname_to_pathname

    def pathname_is_inside_root_pathname?(grandchild_pathname)
      grandchild_pathname.realpath.to_s =~ /^#{root_pathname.realpath.to_s}/
    end
    private :pathname_is_inside_root_pathname?

  end
end



