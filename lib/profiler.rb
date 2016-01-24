require 'markaby'
require_relative "file_contents"
class Profiler
  def initialize(filepath)
    @original_filename = File.basename(filepath)
    p '1' * 100
    @original_file_contents = File.read(filepath)
    FileContents.set(@original_filename, @original_file_contents)
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
    data = @annotation_data[line_number] || {}
    # binding.pry
    total_execution_time = ((data[:time_before_line] || []).sort.zip((data[:time_after_line] || []).sort) || []).map {|pair|
      if pair.include?(nil)
        0
      else
        pair.first - pair.last
      end

    }.inject(&:+)
    # if total_execution_time < 0
    #   total_execution_time = total_execution_time * -1
    # end

    ec = data[:execution_count]
    if ec && ec > 0
      avg_execution_time = total_execution_time / data[:execution_count]
    else
      avg_execution_time = -1
    end
    {execution_count: data[:execution_count], avg_execution_time: avg_execution_time, total_execution_time: total_execution_time}
  end

  def overview # todo: make this a different layer
    profile!
    # TODO make this per codebase, not per file
    a = @original_file_contents.split("\n")
    max_length = a.map {|l| l.length }.max + 10

    ad = @annotation_data
    line_times = a.each_with_index.map {|_, i| info(i)[:avg_execution_time] }
    mab = Markaby::Builder.new
    # p a
    mab.html do
      mab.head do
        mab.title "#{@original_filename} analysis"
        style :type => "text/css" do
          %[
            body { font: 11px/120% Courier, sans-serif }
          ]
        end
      end
      mab.body do
        mab.h1 "Analysis"
        a.each_with_index {|line, line_number|
          leading_whitespace_size = 0

          m = /^\s+/.match(line)
          if m
            leading_whitespace_size = m[0].size
          end
          0.upto(leading_whitespace_size - 1).each {|i| line[i] = "."}
          execution_count = 0
          if ad[line_number]
            execution_count = ad[line_number][:execution_count]
          end
          if execution_count > 0
            mab.font(color: "green")
          else
            mab.font(color: "red")
          end
          line_with_data = "#{line.ljust(max_length, ".")} execution count: #{execution_count} avg_execution_time: #{line_times[line_number]}"
          mab.text(line_with_data)

          mab.br
        }
      end
    end
    # puts mab.to_s
    results_filename = "tmp/html/overview_#{@original_filename}.html"
    File.open(results_filename, "w") do |f|
      f.write(mab.to_s)
    end
    File.read(results_filename)
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

