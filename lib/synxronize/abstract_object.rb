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

      end
    end
  end
end