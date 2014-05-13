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
          @work_pathname ||= project.work_root_pathname + hierarchy_path[1..-1]
        end

      end
    end
  end
end