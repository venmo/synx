require 'xcodeproj'

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
            children.each do |child|
              child.work_pathname.mkpath
              FileUtils.mv(child.real_path, child.work_pathname)
            end

            Synx::Tabber.puts "#{children.first.real_path.basename} (localized: #{localizations.join(", ")})"
          end
        end

        def lproj_as_group?
          parent.basename =~ /.+\.lproj$/
        end

        def localizations
          children.map do |child|
            matches = child.real_path.to_s.match /(\/[^\/]+?\.lproj)/
            matches[1].gsub(".lproj", "").gsub("/", "")
          end
        end

      end
    end
  end
end
