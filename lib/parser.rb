class Parser
  attr_reader :parsed_data
  BEFORE = "BEFORE"
  AFTER = "AFTER"

  def initialize(output)
    @parsed_data = parse(output)
  end

  private

  def parse(output)
    {}.tap { |annotation_data|
      output.each do |line|
        if is_annotation_output?(line)
          line_number = line_number(line)
          annotation_data[line_number] ||= default_data

          if line.include?(BEFORE)
            annotation_data[line_number][:time_before_line] << time(line)
          elsif line.include?(AFTER)
            annotation_data[line_number][:time_after_line] << time(line)
          end
        end
      end
    }.map {|k, v|
      v[:execution_count] = [v[:time_before_line].count, v[:time_after_line].count].min
      {k => v}
    }.inject(&:merge)
  end

  def time(line)
    Time.parse(line.split(",")[2])
  end

  def line_number(line)
    line.split(",")[0].split(":")[1].to_i
  end

  def default_data
    {time_before_line: [], time_after_line: [], execution_count: 0}
  end

  def is_annotation_output?(line)
    line.include?(BEFORE) || line.include?(AFTER)
  end
end
