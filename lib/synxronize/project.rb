require 'fileutils'
require 'xcodeproj'

module Synxronize
  class Project < Xcodeproj::Project

    SYNXRONIZE_DIR = File.join(ENV["HOME"], '.synxronize')
    private_constant :SYNXRONIZE_DIR

    def sync
      @delayed_groups_set_path = []
      main_group.groups.each { |gr| sync_group(gr, pathname_to_work_pathname(main_group.real_path)) }
      set_group_paths
      transplant_work_project
      save
    end

    def sync_group(group, parent_work_pathname)  
      group_work_pathname = parent_work_pathname + dir_name_for_group(group)
      group_work_pathname.mkpath
      # Save this to set after everything, or else it will mess up real_paths
      @delayed_groups_set_path << group

      group.files.each { |pbx_file| sync_pbx_file(pbx_file, group_work_pathname) }
      move_files_not_in_xcodeproj(group_work_pathname)
      group.groups.each { |gr| sync_group(gr, work_p) }
    end
    private :sync_group

    def sync_pbx_file(pbx_file, parent_work_pathname)
      unless pbx_file.real_path.to_s =~ /^\$\{(SDKROOT|DEVELOPER_DIR|BUILT_PRODUCTS_DIR)\}/
        FileUtils.mv(pbx_file.real_path.to_s, parent_work_pathname.to_s)
        pbx_file.path = Pathname(pbx_file.path).basename.to_s
      end
    end
    private :sync_pbx_file

    def move_files_not_in_xcodeproj(group_work_pathname)
      group_pathname = work_pathname_to_pathname(group_work_pathname)
      group_pathname.entries.select { |f| File.file?(f) }.each do |file_path|
        FileUtils.mv(file_path, group_work_pathname)
      end
    end
    private :move_files_not_in_xcodeproj

    def set_group_paths
      @delayed_groups_set_path.each { |group| group.path = dir_name_for_group(group) }
    end
    private :set_group_paths

    def transplant_work_project
      # Should only be left with dirs and the original xcodeproj file. Delete them.
      (Dir.glob(root_pathname + "*") - [path.realpath.to_s]).each do { |dir| FileUtils.rm_rf(dir) }
      # Move the synced entries over
      work_root_pathname.entries.each { |entry| FileUtils.mv(entry.to_s, root_pathname)}
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

    def dir_name_for_group(group)
      group.name || group.path || Pathname(group.real_path).basename.to_s
    end
    private :dir_name_for_group

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

  end
end



