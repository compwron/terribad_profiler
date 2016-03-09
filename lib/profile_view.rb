require 'markaby'
class ProfileView
  def initialize(original_file_contents, annotation_data, original_filename)
    @original_file_contents = original_file_contents
    @annotation_data = annotation_data
    @original_filename = original_filename
  end

  def overview
    fill_html_generator(Markaby::Builder.new, analysis_title, data_lines_with_colors).to_s
  end

  private

  def fill_html_generator(mab, title, data_lines_with_colors)
    mab.html do
      mab.head do
        mab.title title
        style :type => "text/css" do
          %[
            body { font: 11px/120% Courier, sans-serif }
          ]
        end
      end
      mab.body do
        mab.h1 title
        data_lines_with_colors.each { |line, color|
          mab.font(color: color)
          mab.text(line)
          mab.br
        }
      end
    end
  end

  def analysis_title
    [@original_filename, "Analysis"].join(" ")
  end

  def data_lines_with_colors
    @original_file_contents.each_with_index.map { |line, line_number|
      [replace_leading_whitespace_with_dots(line), line_number]
    }.map { |line, line_number|
      execution_count = (@annotation_data[line_number] || {})[:execution_count] || 0
      color = execution_count > 0 ? "green" : "red"
      line = "#{line.ljust(max_line_length, ".")} execution count: #{execution_count} avg_execution_time: #{avg_execution_times[line_number]}"
      [line, color]
    }
  end

  def replace_leading_whitespace_with_dots(line)
    line.chars.each_with_index.map { |c, index|
      index < line[/\A */].size ? "." : c
    }.join("")
  end

  def leading_whitespace_size(line)
    0.upto(line[/\A */].size - 1).each { |i| line[i] = "." }
  end

  def total_execution_time
    @annotation_data.each {|line_number, data|

    }
  end

  def avg_execution_times
    @original_file_contents.each_with_index.map { |_, line_number|
      data = @annotation_data[line_number]
      if data && data[:execution_count] > 0
        tet = ((data[:time_before_line] || []).sort.zip((data[:time_after_line] || []).sort) || []).map { |pair|
          if pair.include?(nil)
            0
          else
            pair.first - pair.last
          end

        }.inject(&:+)
        if tet && tet < 0
          tet = tet * -1
        end
        "%.10f" % (tet / data[:execution_count])
      else
        -1
      end
    }
  end

  def max_line_length
    @max_line_length ||= @original_file_contents.map(&:length).max + 10
  end
end
