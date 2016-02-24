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
      output.select{|line| is_annotation_output?(line)}.each {|line|
        ln = line_number(line)
        annotation_data[ln] ||= default_data
        key = line.include?(BEFORE) ? :time_before_line : :time_after_line
        annotation_data[ln][key] << time(line)
        annotation_data[ln][:execution_count] += 1 if key == :time_after_line
      }
    }
    # broken
    # use this  v[:execution_count] = [v[:time_before_line].count, v[:time_after_line].count].min

  end

  def time(line)
    line.split(",")[2].to_f
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

