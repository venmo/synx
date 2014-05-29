require 'xcodeproj'

module Xcodeproj
  class Project
    module Object
      class PBXVariantGroup
        
        def sync(group)
          ensure_internal_consistency(group)
          folder_path = children.first.real_path.parent
          work_destination_pathname = parent.work_pathname
          if folder_path.exist?
            FileUtils.mv(folder_path, work_destination_pathname.realpath)
          end
        end

      end
    end
  end
end
