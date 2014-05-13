require 'xcodeproj'

module Xcodeproj
  class Project
    module Object
      class PBXVariantGroup
        
        def sync
          folder_path = children.first.real_path.parent
          work_destination_pathname = parent.work_pathname
          FileUtils.mv(folder_path, work_destination_pathname.realpath)
        end

      end
    end
  end
end
