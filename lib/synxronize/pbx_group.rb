require 'xcodeproj'

module Xcodeproj
  class Project
    module Object
      class PBXGroup
        
        def sync
          unless excluded_from_sync?
            work_pathname.mkpath
            files.each { |pbx_file| pbx_file.sync(self) }
            groups_and_version_groups.each { |group| group.sync }
            sync_path
            move_entries_not_in_xcodeproj
          end
        end

        def excluded_from_sync?
          project.group_exclusions.include?(hierarchy_path)
        end

        def move_entries_not_in_xcodeproj
          unless excluded_from_sync?
            Dir[real_path.to_s + "/*"].each do |entry|
              entry_pathname = real_path + entry
              unless has_entry?(entry_pathname)
                FileUtils.mv(entry_pathname.realpath, work_pathname.to_s)
              end
            end
          end
        end
        private :move_entries_not_in_xcodeproj

        def sync_path
          self.path = basename
          self.source_tree = "<group>"
        end
        private :sync_path

        def has_entry?(entry_pathname)
          %W(. ..).include?(entry_pathname.basename.to_s) || children.any? do |child|
            child.real_path.cleanpath == entry_pathname.realpath.cleanpath
          end
        end
        private :has_entry?

        def work_pathname
          # hierarchy path has a leading '/' that will break path concatenation
          @work_pathname ||= project.work_root_pathname + hierarchy_path[1..-1]
        end
        private :work_pathname

        def groups_and_version_groups
          groups | version_groups
        end

      end
    end
  end
end