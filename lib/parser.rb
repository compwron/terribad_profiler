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
          ln, data = data(annotation_data, line)
          annotation_data[ln] = data
        end
      end
    }.map {|k, v|
      v[:execution_count] = [v[:time_before_line].count, v[:time_after_line].count].min
      {k => v}
    }.inject(&:merge)
  end

  def data(annotation_data, line)
    d = annotation_data[ln = line_number(line)]
    d ||= default_data
    key, time = time_key(line)
    d[key] << time
    [ln, d]
  end

  def time_key(line)
    if line.include?(BEFORE)
      [:time_before_line, time(line)]
    elsif line.include?(AFTER)
      [:time_after_line, time(line)]
    end
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
