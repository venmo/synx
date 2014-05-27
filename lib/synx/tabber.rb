module Synx
  class Tabber

    @@tabbing = ""

    class << self
      def increase(n=1)
        @@tabbing += (a_single_tab * n)
      end

      def decrease(n=1)
        @@tabbing.sub!((a_single_tab * n), "")
      end

      def current
        @@tabbing.length / a_single_tab.length
      end

      def reset
        @@tabbing = ""
      end

      def puts(str="")
        Kernel.puts @@tabbing + str.to_s
      end

      def a_single_tab
        return "  "
      end
      private :a_single_tab

    end
  end
end