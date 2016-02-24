require "markaby"
require_relative "parser"
require_relative "profile_view"

class Profiler
  def initialize(filepath)
    @original_filename = File.basename(filepath)
    @original_file_contents = File.read(filepath).split("\n")
  end

  def profile!
    File.open(new_filepath, "w") {|f|
      f.write annotate(@original_file_contents).join("\n")
    }
    annotation_output = `ruby #{new_filepath}`.split("\n")
    @annotation_data = Parser.new(annotation_output).parsed_data
  end

  def overview
    profile!
    html = ProfileView.new(@original_file_contents, @annotation_data, @original_filename).overview
    File.open(results_filename, "w") do |f|
      f.write(html)
    end
    html
  end

  private

  def info(line_number)
    data = @annotation_data[line_number]
    if data.nil? || data[:execution_count] == 0
      return {execution_count: 0, avg_execution_time: -1, total_execution_time: -1}
    end
    total_execution_time = sum_diff(data)
    if total_execution_time && total_execution_time < 0
      total_execution_time = total_execution_time * -1
    end

    avg_execution_time = total_execution_time / data[:execution_count]
    {execution_count: data[:execution_count], avg_execution_time: avg_execution_time, total_execution_time: total_execution_time}
  end

  def results_filename
    "tmp/html/overview_#{@original_filename}.html"
  end

  def sum_diff(data)
    ((data[:time_before_line] || []).sort.zip((data[:time_after_line] || []).sort) || []).map {|pair|
      if pair.include?(nil)
        0
      else
        pair.first - pair.last
      end

    }.inject(&:+)
  end

  def new_filepath
    "tmp/annotated_#{@original_filename}"
  end

  def annotate(file_contents)
    contents = file_contents
    annotated_contents = []
    file_contents.each_with_index {|line, line_number|
      annotated_contents << anno(line, line_number)
    }
    annotated_contents
  end

  def anno(line, line_number)
    [
      "puts \"line_number:#{line_number},BEFORE,#\{Time.now.to_f\}\"",
      "#{line}",
      "puts \"line_number:#{line_number},AFTER,#\{Time.now.to_f\}\""
    ].join("\n")
  end
end

