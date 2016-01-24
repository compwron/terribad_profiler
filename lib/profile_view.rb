require 'markaby'
class ProfileView
  def initialize(original_file_contents, annotation_data, original_filename)
    @original_file_contents = original_file_contents
    @annotation_data = annotation_data
    @original_filename = original_filename

    generate_html
  end

  def overview
    generate_html
  end

  private

  def avg_execution_time(line_number)
    data = @annotation_data[line_number]
    if data && data[:execution_count] > 0
      tet = total_execution_time(data)
      if tet && tet < 0
        tet = tet * -1
      end
       tet / data[:execution_count]
    else
      -1
    end
  end

  def total_execution_time(data)
    ((data[:time_before_line] || []).sort.zip((data[:time_after_line] || []).sort) || []).map {|pair|
      if pair.include?(nil)
        0
      else
        pair.first - pair.last
      end

    }.inject(&:+)
  end

  def generate_html
    lines = @original_file_contents
    max_length = lines.map {|l| l.length }.max + 10

    ad = @annotation_data
    line_times = lines.each_with_index.map {|_, i| avg_execution_time(i) }
    mab = Markaby::Builder.new

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
        lines.each_with_index {|line, line_number|
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

    results_filename = "tmp/html/overview_#{@original_filename}.html"
    File.open(results_filename, "w") do |f|
      f.write(mab.to_s)
    end
    File.read(results_filename)
  end
end
