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

        def sync(group)
          raise NotImplementedError
        end

      end
    end
  end
end
