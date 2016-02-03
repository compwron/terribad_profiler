class Parser
  attr_reader :parsed_data
  BEFORE = "BEFORE"
  AFTER = "AFTER"

  def initialize(output)
    @parsed_data = parse(output)
  end

  private

  def parse(output)
    a = {}.tap do |annotation_data|
    output.each do |line|
        if is_annotation_output?(line)
          line_number = line.split(",")[0].split(":")[1].to_i
          annotation_data[line_number] ||= {time_before_line: [], time_after_line: [], execution_count: 0}
          timesstamp = line.split(",")[2]
          if line.include?(BEFORE)
            annotation_data[line_number][:time_before_line] << Time.parse(timesstamp)
          elsif line.include?(AFTER)
            annotation_data[line_number][:time_after_line] << Time.parse(timesstamp)
          end
        end
      end
    end
    a.each {|k, v|
      v[:execution_count] = [v[:time_before_line].count, v[:time_after_line].count].min
    }
    a
  end

  def is_annotation_output?(line)
    line.include?(BEFORE) || line.include?(AFTER)
  end
end
