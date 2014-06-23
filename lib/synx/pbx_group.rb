require 'xcodeproj'

module Xcodeproj
  class Project
    module Object
      class PBXGroup
        
        def sync(group)
          ensure_internal_consistency(group)
          if excluded_from_sync?
            Synx::Tabber.puts "#{basename}/ (excluded)".yellow
          else
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
          if excluded_from_sync?
            Synx::Tabber.puts "#{basename}/ (excluded)".yellow
          else
            Synx::Tabber.puts "#{basename}/".green
            Synx::Tabber.increase
            Dir[real_path.to_s + "/{*,.*}"].reject { |e| %W(. ..).include?(Pathname(e).basename.to_s) }.each do |entry|
              entry_pathname = real_path + entry
              unless project.has_object_for_pathname?(entry_pathname)
                handle_unused_entry(entry_pathname)
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

        def all_groups
          groups | version_groups | variant_groups
        end

        def variant_groups
          children.select { |child| child.instance_of?(Xcodeproj::Project::Object::PBXVariantGroup) }
        end
        private :variant_groups

        def handle_unused_entry(entry_pathname)
          entries_to_ignore = %W(.DS_Store)
          unless entries_to_ignore.include?(entry_pathname.basename.to_s)            
            if entry_pathname.directory?
              work_entry_pathname = project.pathname_to_work_pathname(entry_pathname)
              # The directory may have already been created for one of two reasons
              # 1. It was created as a piece of another path, ie, /this/middle/directory.mkdir got called.
              # 2. OS X has case insensitive folder names, so has_object_for_pathname? may have failed to notice it had the folder.
              work_entry_pathname.mkdir unless work_entry_pathname.exist?
              # recurse
              Synx::Tabber.puts entry_pathname.basename.to_s.green
              Synx::Tabber.increase
              entry_pathname.children.each { |child| handle_unused_entry(child) }
              Synx::Tabber.decrease
            elsif entry_pathname.file?
              handle_unused_file(entry_pathname)
            end
          end
        end
        private :handle_unused_entry

        def handle_unused_file(file_pathname)
          prune_file_extensions = %W(.h .m .xib .mm .c .png .jpg .jpeg)
          is_file_to_prune = prune_file_extensions.include?(file_pathname.extname.downcase)

          if is_file_to_prune && project.prune
            Synx::Tabber.puts "#{file_pathname.basename} (removed source/image file that is not referenced by the Xcode project)".red
            return
          elsif !project.prune || !is_file_to_prune
            FileUtils.mv(file_pathname.realpath, project.pathname_to_work_pathname(file_pathname.parent).realpath)
            if is_file_to_prune
              Synx::Tabber.puts "#{file_pathname.basename} (source/image file that is not referenced by the Xcode project)".yellow
            else
              Synx::Tabber.puts file_pathname.basename
            end
          end
        end
        private :handle_unused_file

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
            Synx::Tabber.puts "#{file.basename} (removed duplicate reference)".red
          end
        end
        private :squash_duplicate_file_references

        def groups_containing_forward_slash
          found_groups = []
          groups.each do |group|
            unless group.excluded_from_sync?
              found_groups << group if group.basename.include?("/")
              found_groups |= group.groups_containing_forward_slash
            end
          end
          found_groups
        end

      end
    end
  end
end