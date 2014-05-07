require 'xcodeproj'

module Xcodeproj
  class Project
    module Object
      class PBXFileReference
        
        def sync(group)
          ensure_internal_consistency(group)
          if should_sync?
            if should_move?
              FileUtils.mv(real_path.to_s, group.work_pathname.to_s)
              # TODO: move out to abstract_object
              self.source_tree = "<group>"
              self.path = real_path.basename.to_s
            else
              # Don't move this file around -- it's not even inside the structure. Just fix the relative reference
              self.path = real_path.relative_path_from((project.work_pathname_to_pathname(group.work_pathname))).to_s
            end
            change_build_settings_reference
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
            # Just remove all referring groups but the one we're syncing with
            referring_groups.each { |rg| rg.remove_reference(self) unless rg == group }
          end
        end

        # Fixes things like pch, info.plist references being changed
        def change_build_settings_reference
          return unless basename =~ /\.(pch|plist)$/

          project.targets.each do |t|
            t.each_build_settings do |bs|
              ["INFOPLIST_FILE", "GCC_PREFIX_HEADER"].each do |setting_key|
                setting_value = bs[setting_key]
                if setting_value == real_path.relative_path_from(project.root_pathname).to_s
                  bs[setting_key] = hierarchy_path[1..-1]
                end
              end if bs
            end
          end
        end

      end
    end
  end
end