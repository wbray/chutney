require 'chutney/linter'

module Chutney
  # service class to lint for unused variables
  class UnusedVariable < Linter
    def lint
      scenarios do |file, feature, scenario|
        next unless scenario.key? :examples
        
        scenario[:examples].each do |example|
          next unless example.key? :tableHeader
          
          example[:tableHeader][:cells].map { |cell| cell[:value] }.each do |variable|
            references = [reference(file, feature, scenario)]
            add_error(references, "Variable '<#{variable}>' is unused") unless used?(variable, scenario)
          end
        end
      end
    end

    def used?(variable, scenario)
      variable = "<#{variable}>"
      return false unless scenario.key? :steps
      
      scenario[:steps].each do |step|
        return true if step[:text].include? variable
        next unless step.include? :argument
        return true if used_in_docstring?(variable, step)
        return true if used_in_table?(variable, step)
      end
      false
    end

    def used_in_docstring?(variable, step)
      step[:argument][:type] == :DocString && step[:argument][:content].include?(variable)
    end

    def used_in_table?(variable, step)
      return false unless step[:argument][:type] == :DataTable
      
      step[:argument][:rows].each do |row|
        row[:cells].each { |value| return true if value[:value].include?(variable) }
      end
      false
    end
  end
end
