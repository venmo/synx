require 'xcodeproj'

module Xcodeproj
  class Project
    module Object
      class PBXFileReference
        
        def sync(group)
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

            output
          else
            Synx::Tabber.puts "skipped #{basename}".red
          end
        end

        def output
          build_settings_ammended = "(build settings ammended: #{@setting_keys_changed.join(", ")})" if @setting_keys_changed.count > 0
          removed_from_groups = "(had multiple parent groups, removed from groups: #{@removed_from_groups.join(", ")})" if @removed_from_groups.count > 0
          str_output = "#{basename} #{build_settings_ammended} #{removed_from_groups}"
          str_output = str_output.yellow if removed_from_groups || build_settings_ammended
          Synx::Tabber.puts str_output
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

        # Fixes things like pch, info.plist references being changed
        def change_build_settings_reference
          @setting_keys_changed = []
          return unless basename =~ /\.(pch|plist)$/

          native_targets = project.targets.select do |target|
            target.kind_of?(Xcodeproj::Project::Object::PBXNativeTarget)
          end

          native_targets.each do |t|
            t.each_build_settings do |bs|
              ["INFOPLIST_FILE", "GCC_PREFIX_HEADER"].each do |setting_key|
                setting_value = bs[setting_key]
                if setting_value == real_path.relative_path_from(project.root_pathname).to_s
                  bs[setting_key] = hierarchy_path[1..-1]
                  @setting_keys_changed << setting_key
                end
              end if bs
            end
          end

          @setting_keys_changed.uniq!
        end

      end
    end
  end
end
