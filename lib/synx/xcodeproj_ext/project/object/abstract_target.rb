module Xcodeproj
  class Project
    module Object
      class AbstractTarget

        def each_build_settings
          build_configurations.each { |bc| yield bc.build_settings }
        end

      end
    end
  end
end
