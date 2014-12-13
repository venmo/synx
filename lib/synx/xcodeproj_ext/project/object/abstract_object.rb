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
          @work_pathname ||= if hierarchy_path
            # hierarchy path has a leading '/' that will break path concatenation
            project.work_root_pathname + hierarchy_path[1..-1]
          else
            project.work_root_pathname
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
