module Synx
  class IssueRegistry

    attr_accessor :output

    def initialize
      @issues = {}
      @output = $stderr
    end

    def add_issue(reason, basename, type = nil)
      existing_issue = @issues.each_pair.select { |(name, (reason, type))| name == basename.to_s and type == :not_synchronized }

      if existing_issue.empty?
        @issues[basename.to_s] = [reason, type]
      end
    end

    def issues
      @issues.values.map(&:first).sort
    end

    def issues_for_basename(partial_basename)
      @issues.each_pair.select { |(basename, _)| basename.include? partial_basename.to_s }.map { |_, issue| issue.first }.sort
    end

    def issues_count
      @issues.size
    end

    def print(type)
      issues.each do |issue|
        output.puts [type, issue].join(': ')
      end
    end

  end
end
