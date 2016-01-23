class Profiler
  def initialize(filepath)
    @original_filename = File.basename(filepath)
    @original_file_contents = File.read(filepath)
  end

  def profile!
    new_filepath = "tmp/annotated_#{@original_filename}"
    code_with_annotations = annotate(@original_file_contents)
    File.open(new_filepath, "w") {|f|
      f.write code_with_annotations.join("\n")
    }
    a = File.read(new_filepath)
    annotation_output = `ruby #{new_filepath}`
    @annotation_data = parse(annotation_output.split("\n"))
  end

  def info(line_number)
    data = @annotation_data[line_number]
    total_execution_time = data[:time_before_line].sort.zip(data[:time_after_line].sort).map {|pair|
      if pair.include?(nil)
        0
      else
        pair.first - pair.last
      end
    }.inject(&:+)
    avg_execution_time = total_execution_time / data[:execution_count]
    {execution_count: data[:execution_count], avg_execution_time: avg_execution_time, total_execution_time: total_execution_time}
  end

  private

  def annotate(file_contents)
    contents = file_contents.split("\n")
    annotated_contents = []
    contents.each_with_index {|line, line_number|
      annotated_contents << anno(line, line_number)
    }
    annotated_contents
  end

  def anno(line, line_number)
    [
      "puts \"line_number:#{line_number},BEFORE,#\{Time.now.utc\}\"",
      "#{line}",
      "puts \"line_number:#{line_number},AFTER,#\{Time.now.utc\}\""
    ].join("\n")
  end

  def parse(output)
    annotation_data = {}
    # "line_number:2,AFTER,#{Time.now}"
    # binding.pry
    output.each {|line|
      if line.include?("BEFORE") || line.include?("AFTER")
        line_number = line.split(",")[0].split(":")[1].to_i
        annotation_data[line_number] ||= {time_before_line: [], time_after_line: [], execution_count: 0}
        timesstamp = line.split(",")[2]
        if line.include?("BEFORE")
          annotation_data[line_number][:time_before_line] << Time.parse(timesstamp)
        elsif line.include?("AFTER")
          annotation_data[line_number][:time_after_line] << Time.parse(timesstamp)
        end
      end
    }
    annotation_data.each {|k, v|
      v[:execution_count] = [v[:time_before_line].count, v[:time_after_line].count].min
    }
    annotation_data
  end
end

