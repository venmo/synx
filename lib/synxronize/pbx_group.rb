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
            ## TODO: Decide what to do with this shit.
            #move_entries_not_in_xcodeproj(group, group_work_pathname)
          end
        end

        def excluded_from_sync?
          project.group_exclusions.include?(hierarchy_path)
        end

        def sync_child_group_paths
          groups.each do |group|
            group.sync_child_group_paths
            group.sync_path
          end
        end

        def sync_path
          self.path = basename
        end

      end
    end
  end
end