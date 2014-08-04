require 'xcodeproj'

module Xcodeproj
  class Project
    module Object
      class AbstractObject

        def basename
          name || path || Pathname(real_path).basename.to_s
        end

        def referring_groups
          referrers.select { |ref| ref.instance_of?(Xcodeproj::Project::Object::PBXGroup) }
        end

        def work_pathname
          # hierarchy path has a leading '/' that will break path concatenation
          @work_pathname ||= begin
            work_pathname_from_hierarchy = project.work_root_pathname + hierarchy_path[1..-1]
            if parent.class == PBXVariantGroup
              super_work_pathname_components = work_pathname_from_hierarchy.each_filename.to_a
              localization_parent_name = parent.real_path.basename.to_s
              index_of_localization_parent = super_work_pathname_components.index(localization_parent_name)
              localization = super_work_pathname_components.pop + ".lproj"
              work_pathname_from_hierarchy = "/" + super_work_pathname_components.insert(index_of_localization_parent + 1, localization).join(File::Separator)
            end
            Pathname(work_pathname_from_hierarchy)
          end
        end

        def ensure_internal_consistency(group)
          @removed_from_groups = []
          if referring_groups.count > 1
            # Files should only have one referring group -- this is an internal consistency issue if there is more than 1.
            # Just remove all referring groups but the one we're syncing with

            referring_groups.each do |rg|
              unless rg == group
                rg.remove_reference(self) unless rg == group
                @removed_from_groups << rg.hierarchy_path
              end
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