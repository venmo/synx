require 'xcodeproj'

module Xcodeproj
  class Project
    module Object
      class PBXFileReference
        
        def sync(parent_work_pathname, group)
          binding.pry if basename == "PaymentWithEmailTarget.json"
          ensure_internal_consistency(group)
          if should_sync?
            if should_move?
              FileUtils.mv(real_path.to_s, parent_work_pathname.to_s)
              self.source_tree = "<group>"
              self.path = real_path.basename.to_s
            else
              # Don't move this file around -- it's not even inside the structure. Just fix the relative reference
              self.path = real_path.relative_path_from((project.work_pathname_to_pathname(parent_work_pathname))).to_s
            end
          end
        end

        def should_sync?
          # Don't sync files that don't exist or are Apple/Build stuff
          real_path.exist? && !(real_path.to_s =~ /^\$\{(SDKROOT|DEVELOPER_DIR|BUILT_PRODUCTS_DIR)\}/)
        end
        private :should_sync?

        def should_move?
          # Don't move these files around -- they're not even inside the structure. Just fix the relative references.
          !(real_path.to_s =~ /\.xcodeproj$/) && project.pathname_is_inside_root_pathname?(real_path)
        end
        private :should_move?

        def ensure_internal_consistency(group)
          if referring_groups.count > 1
            # Files should only have one referring group -- this is an internal consistency issue if there is more than 1.
            # Just remove all referring groups but the first if there are more than 1.
            referring_groups[1...referring_groups.count].each { |rg| rg.remove_reference(self) unless rg == group }
          end
        end

      end
    end
  end
end