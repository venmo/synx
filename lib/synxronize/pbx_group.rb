require 'xcodeproj'

module Xcodeproj
  class Project
    module Object
      class PBXGroup
        
        def sync
          unless excluded_from_sync?
            work_pathname.mkpath
            files.each { |pbx_file| pbx_file.sync(self) }
            groups.each { |group| group.sync }
            move_entries_not_in_xcodeproj
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

        def move_entries_not_in_xcodeproj
          group_pathname = project.work_pathname_to_pathname(work_pathname)
          if group_pathname.exist?
            Dir[group_pathname.realpath.to_s + "/*"].each do |entry|
              entry_pathname = group_pathname + entry
              # TODO: Need a way to handle directories, too.
              unless File.directory?(entry_pathname.to_s) || has_entry?(entry_pathname)
                FileUtils.mv(entry_pathname.realpath, work_pathname.to_s)
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

        def work_pathname
          # hierarchy path has a leading '/' that will break path concatenation
          project.work_root_pathname + hierarchy_path[1..-1]
        end

      end
    end
  end
end