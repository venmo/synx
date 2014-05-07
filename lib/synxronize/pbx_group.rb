require 'xcodeproj'

module Xcodeproj
  class Project
    module Object
      class PBXGroup
        
        def sync(parent_work_pathname)  
          unless excluded_from_sync?
            group_work_pathname = parent_work_pathname + basename
            group_work_pathname.mkpath
            files.each { |pbx_file| pbx_file.sync(group_work_pathname, self) }
            groups.each { |group| group.sync(group_work_pathname) }
            move_entries_not_in_xcodeproj(group_work_pathname)
          end
        end

        def excluded_from_sync?
          project.group_exclusions.include?(hierarchy_path)
        end

        def sync_child_group_paths
          unless excluded_from_sync?
            groups.each do |group|
              group.sync_child_group_paths
              group.sync_path
            end
          end
        end

        def sync_path
          self.path = basename
          self.source_tree = "<group>"
        end

        def move_entries_not_in_xcodeproj(group_work_pathname)
          group_pathname = project.work_pathname_to_pathname(group_work_pathname)
          if group_pathname.exist?
            Dir[group_pathname.realpath.to_s + "/*"].each do |entry|
              entry_pathname = group_pathname + entry
              # TODO: Need a way to handle directories, too.
              unless File.directory?(entry_pathname.to_s) || has_entry?(entry_pathname)
                FileUtils.mv(entry_pathname.realpath, group_work_pathname.to_s)
              end
            end
          end
        end
        private :move_entries_not_in_xcodeproj

        def has_entry?(entry_pathname)
          %W(. ..).include?(entry_pathname.basename.to_s) || children.any? do |child|
            child.real_path.cleanpath == entry_pathname.realpath.cleanpath
          end
        end
        private :has_entry?

      end
    end
  end
end