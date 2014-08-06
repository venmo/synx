module Xcodeproj
  class Project
    module Object
      class PBXVariantGroup

        # Need to retain *.lproj files on the system
        def sync(group)
          ensure_internal_consistency(group)

          file = files.first
          if lproj_as_group?
            FileUtils.mv(file.real_path, work_pathname)
            Synx::Tabber.puts file.real_path.basename.to_s.green
          else
            parent_folder_path = children.first.real_path.parent
            work_destination_pathname = parent.work_pathname

            if parent_folder_path.exist?
              FileUtils.mv(parent_folder_path, work_destination_pathname.realpath)
            end
            Synx::Tabber.puts (parent_folder_path.basename.to_s + "/").green
            Synx::Tabber.increase
            Synx::Tabber.puts file.real_path.basename.to_s.green
            Synx::Tabber.decrease
          end
        end

        def lproj_as_group?
          parent.basename =~ /.+\.lproj$/
        end

      end
    end
  end
end
