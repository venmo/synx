module Xcodeproj
  class Project
    module Object
      class PBXGroup

        def sync(group)
          ensure_internal_consistency(group) # Make sure we don't belong to any other groups
          if excluded_from_sync?
            Synx::Tabber.puts "#{basename}/ (excluded)".yellow
          else
            Synx::Tabber.puts "#{basename}/".green
            Synx::Tabber.increase

            squash_duplicate_file_references
            # Child directories may not exist yet (and may be different for
            # each file) if this is a localized group, so we do the mkpath call
            # inside the loops.
            files.each do |pbx_file|
              pbx_file.work_pathname.dirname.mkpath
              pbx_file.sync(self)
            end
            all_groups.each do |group|
              group.work_pathname.dirname.mkpath
              group.sync(self)
            end
            sync_path
            sort_by_name if project.sort_by_name

            Synx::Tabber.decrease
          end
        end

        def excluded_from_sync?
          project.group_exclusions.include?(hierarchy_path)
        end

        def sort_by_name
          children.sort! do |x, y|
            if x.isa == 'PBXGroup' && !(y.isa == 'PBXGroup')
              -1
            elsif !(x.isa == 'PBXGroup') && y.isa == 'PBXGroup'
              1
            elsif x.display_name && y.display_name
              x.display_name <=> y.display_name
            else
              0
            end
          end
        end

        def move_entries_not_in_xcodeproj
          if excluded_from_sync?
            Synx::Tabber.puts "#{basename}/ (excluded)".yellow
          elsif real_path.exist?
            Synx::Tabber.puts "#{basename}/".green
            Synx::Tabber.increase
            real_path.children.each do |entry_pathname|
              unless project.has_object_for_pathname?(entry_pathname)
                handle_unused_entry(entry_pathname)
              end
            end
            all_groups.each(&:move_entries_not_in_xcodeproj)
            Synx::Tabber.decrease
          end
        end

        def sync_path
          self.path = work_pathname.relative_path_from(parent.work_pathname).to_s
          self.source_tree = "<group>"
        end
        private :sync_path

        def all_groups
          children.select { |child| child.is_a?(Xcodeproj::Project::Object::PBXGroup)}
        end

        def handle_unused_entry(entry_pathname)
          entries_to_ignore = %W(.DS_Store)
          unless entries_to_ignore.include?(entry_pathname.basename.to_s)
            if entry_pathname.directory?
              # recurse
              Synx::Tabber.puts entry_pathname.basename.to_s.green
              Synx::Tabber.increase
              # Don't create the directory manually: if it has children, it will
              # be created then, and if it doesn't, we don't want it.
              entry_pathname.children.each { |child| handle_unused_entry(child) }
              Synx::Tabber.decrease
            elsif entry_pathname.file?
              handle_unused_file(entry_pathname)
            end
          end
        end
        private :handle_unused_entry

        def handle_unused_file(file_pathname)
          prune_file_extensions = %W(.h .m .swift .mm .c .xib .png .jpg .jpeg)
          is_file_to_prune = prune_file_extensions.include?(file_pathname.extname.downcase)

          if is_file_to_prune && project.prune
            Synx::Tabber.puts "#{file_pathname.basename} (removed source/image file that is not referenced by the Xcode project)".red
            return
          elsif !project.prune || !is_file_to_prune
            destination = project.pathname_to_work_pathname(file_pathname.parent.realpath)
            destination.mkpath
            FileUtils.mv(file_pathname.realpath, destination)
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
