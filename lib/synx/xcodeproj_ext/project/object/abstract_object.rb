module Xcodeproj
  class Project
    module Object
      class AbstractObject

        def basename
          name || path || Pathname(real_path).basename.to_s
        end

        def referring_groups
          referrers.select { |ref| ref.is_a?(Xcodeproj::Project::Object::PBXGroup) }
        end

        def work_pathname
          # Intuitively, we want the work pathname to correspond 1-1 with the
          # view in the project hierarchy. Xcode's collapsed display of
          # identically-named localized files causes some complications, leading
          # to the special cases here.
          if self.equal?(project.main_group)
            @work_pathname ||= project.work_root_pathname
          elsif parent.is_a?(Xcodeproj::Project::Object::PBXVariantGroup)
            # Localized object, naming is handled differently.
            @work_pathname ||= parent.work_pathname + "#{display_name}.lproj" + parent.display_name
          elsif is_a?(Xcodeproj::Project::Object::PBXVariantGroup)
            # Localized container, has no path of its own.
            @work_pathname ||= parent.work_pathname
          else
            @work_pathname ||= parent.work_pathname + display_name
          end
        end

        def ensure_internal_consistency(group)
          @removed_from_groups = []
          # Objects should only have one referring group -- this is an internal consistency issue if there is more than 1.
          # Just remove all referring groups but the one we're passed
          referring_groups.each do |rg|
            unless rg == group
              rg.remove_reference(self)
              @removed_from_groups << rg.hierarchy_path
            end
          end
        end

        def track_sync_issues
          current_relative_path = real_path.relative_path_from(project.root_pathname).to_s
          synced_relative_path = work_pathname.relative_path_from(project.work_root_pathname).to_s

          if current_relative_path != synced_relative_path
            issue = "#{readable_type} #{basename} is not synchronized with file system (current path: #{current_relative_path}, desired path: #{synced_relative_path})."
            project.sync_issues_repository.add_issue(issue, basename, :not_synchronized)
          end
        end

        def readable_type
          isa.sub('PBX', '').split(/(?=[A-Z])/).join(' ').capitalize
        end

        def sync(group)
          raise NotImplementedError
        end

        def file_utils
          project.file_utils
        end

      end
    end
  end
end
