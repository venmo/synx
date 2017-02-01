require 'xcodeproj'

module Synx
  class Project < Xcodeproj::Project

    SYNXRONIZE_DIR = File.join(ENV["HOME"], '.synx')
    private_constant :SYNXRONIZE_DIR

    DEFAULT_EXCLUSIONS = %W(/Libraries /Frameworks /Products /Pods)
    private_constant :DEFAULT_EXCLUSIONS

    attr_accessor :delayed_groups_set_path, :group_exclusions, :prune, :sort_by_name, :warn_type, :file_utils

    def sync(options={})
      set_options(options)
      presync_check
      Synx::Tabber.increase
      Synx::Tabber.puts "Syncing files that are included in Xcode project...".bold.white
      main_group.all_groups.each { |gr| gr.sync(main_group) }
      Synx::Tabber.puts "\n\n"
      Synx::Tabber.puts "Syncing files that are not included in Xcode project..".bold.white
      main_group.all_groups.each(&:move_entries_not_in_xcodeproj)
      main_group.sort_by_name if self.sort_by_name
      transplant_work_project
      Synx::Tabber.decrease
      print_dry_run_issues
      save unless warn_type
    end

    def presync_check
      forward_slash_groups = main_group.groups_containing_forward_slash
      unless forward_slash_groups.empty?
        Synx::Tabber.puts "Synx cannot sync projects with groups that contain '/'. Please rename the following groups before running synx again:".yellow
        Synx::Tabber.increase
        forward_slash_groups.each do |group|
          Synx::Tabber.puts group.hierarchy_path
        end
        abort
      end
    end

    def set_options(options)
      self.prune = options[:prune]

      if options[:no_default_exclusions]
        self.group_exclusions = []
      else
        self.group_exclusions = DEFAULT_EXCLUSIONS
      end

      self.group_exclusions |= options[:group_exclusions] if options[:group_exclusions]
      self.sort_by_name = !options[:no_sort_by_name]
      self.warn_type = validated_warn_type(options)

      Synx::Tabber.options = options
      sync_issues_repository.output = options[:output] unless options[:output].nil?
    end
    private :set_options

    def validated_warn_type(options)
      if options[:warn].to_s == 'warning' or options[:warn].to_s == 'error'
        options[:warn]
      elsif options[:warn]
        Synx::Tabber.puts "Unknown warn-type: #{options[:warn]}".red
        abort
      end
    end

    def transplant_work_project
      # Move the synced entries over
      Dir.glob(work_root_pathname + "*").each do |path|
        file_utils.rm_rf(work_pathname_to_pathname(Pathname(path)))
        file_utils.mv(path, root_pathname.to_s)
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
        file_utils.rm_rf(@work_root_pathname.to_s) if @work_root_pathname.exist?
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
      grandchild_pathname.realpath.to_s.start_with?(root_pathname.realpath.to_s)
    end

    def group_exclusions=(new_exclusions)
      @group_exclusions = new_exclusions.map do |exclusion|
        # Group paths always start with a '/', so put one there if it isn't already.
        exclusion = "/" + exclusion unless exclusion[0] == "/"
        # Don't check our own default exclusions -- they may not have it in their project.
        unless DEFAULT_EXCLUSIONS.include?(exclusion)
          # remove leading '/' for this check
          exclusionCopy = exclusion.dup
          exclusionCopy[0] = ''
          unless self[exclusionCopy]
            raise IndexError, "No group #{exclusionCopy} exists"
          end
        end
        exclusion
      end
    end

    def has_object_for_pathname?(pathname)
      @unmodified_project ||= Synx::Project.open(path)
      @unmodified_project.objects.any? do |o|
        begin
          o.real_path.cleanpath == pathname.cleanpath
        rescue
          false
        end
      end
    end

    def file_utils
      @file_utils ||= (warn_type.nil? ? FileUtils : Synx::BlankFileUtils)
    end

    def sync_issues_repository
      @sync_issues ||= Synx::IssueRegistry.new
    end

    def print_dry_run_issues
      sync_issues_repository.print(warn_type.to_s) if warn_type
    end

    def scanned_files
      @scanned_files ||= []
    end

    def exit_code
      if warn_type.to_s == 'error' and sync_issues_repository.issues_count > 0
        -1
      else
        0
      end
    end
  end
end
