require 'xcodeproj'

module Xcodeproj
  class Project
    module Object
      class PBXGroup
        
        def sync(group)
          ensure_internal_consistency(group)
          unless excluded_from_sync?
            Synx::Tabber.puts "#{basename}/".green
            Synx::Tabber.increase

            squash_duplicate_file_references
            work_pathname.mkpath
            files.each { |pbx_file| pbx_file.sync(self) }
            all_groups.each { |group| group.sync(self) }
            sync_path

            Synx::Tabber.decrease
          end
        end

        def excluded_from_sync?
          project.group_exclusions.include?(hierarchy_path)
        end

        def move_entries_not_in_xcodeproj
          unless excluded_from_sync?
            Synx::Tabber.increase
            Synx::Tabber.puts "#{basename}/".green
            Dir[real_path.to_s + "/*"].each do |entry|
              entry_pathname = real_path + entry
              unless has_entry?(entry_pathname)
                FileUtils.mv(entry_pathname.realpath, work_pathname.to_s)

                puts_unused_file(entry_pathname)
              end
            end
            all_groups.each(&:move_entries_not_in_xcodeproj)
            Synx::Tabber.decrease
          end
        end

        def sync_path
          self.path = basename
          self.source_tree = "<group>"
        end
        private :sync_path

        def has_entry?(entry_pathname)
          %W(. ..).include?(entry_pathname.basename.to_s) || children.any? do |child|
            child.real_path.cleanpath == entry_pathname.realpath.cleanpath
          end
        end
        private :has_entry?

        def all_groups
          groups | version_groups | variant_groups
        end

        def variant_groups
          children.select { |child| child.instance_of?(Xcodeproj::Project::Object::PBXVariantGroup) }
        end
        private :variant_groups

        def puts_unused_file(file_pathname)
          source_file_extensions = %W(.h .m .mm .c)

          output = file_pathname.basename.to_s
          if source_file_extensions.include?(file_pathname.extname)
            output = "#{output} (source file that is not included in Xcode project)".yellow
          end

          Synx::Tabber.puts output
        end
        private :puts_unused_file

        def squash_duplicate_file_references
          files.each { |f| f.ensure_internal_consistency(self) }

          grouped_by_path = files.group_by do |file|
            file.real_path.cleanpath
          end

          duplicates = grouped_by_path.select do |file_path, files|
            files.count > 1
          end

          duplicates.each do |file_path, files|
            file = files.last
            # Removes all references (files array)
            remove_reference(file)
            # Adds just one back
            self << file
            Synx::Tabber.puts "#{file.basename}: removed duplicate reference".red
          end
        end
        private :squash_duplicate_file_references

      end
    end
  end
end