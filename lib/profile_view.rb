require 'markaby'
class ProfileView
  def initialize(original_file_contents, annotation_data, original_filename)
    @original_file_contents = original_file_contents
    @annotation_data = annotation_data
    @original_filename = original_filename
  end

  def overview
    generate_html
  end

  private

  def generate_html
    fill_html_generator(Markaby::Builder.new, analysis_title, data_lines_with_colors)

    # html(@original_file_contents,
    #      avg_execution_times,
    #      @annotation_data,
    #      max_line_length,
    #      Markaby::Builder.new)
  end

  def replace_leading_whitespace_with_dots(line)
    0.upto(line[/\A */].size - 1).each { |i| line[i] = "." }
  end

  def data_lines_with_colors
    @original_file_contents.each_with_index.map { |line, line_number|
      replace_leading_whitespace_with_dots(line)

      execution_count = (@annotation_data[line_number] || {})[:execution_count] || 0
      color = execution_count > 0 ? "green" : "red"
      line = "#{line.ljust(max_line_length, ".")} execution count: #{execution_count} avg_execution_time: #{avg_execution_times[line_number]}"
      [line, color]
    }
  end

  def leading_whitespace_size(line)
    0.upto(line[/\A */].size - 1).each { |i| line[i] = "." }
  end

  def html(lines, line_times, ad, max_length, mab)
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
        lines.each_with_index { |line, line_number|
          leading_whitespace_size = 0

          m = /^\s+/.match(line)
          if m
            leading_whitespace_size = m[0].size
          end
          0.upto(leading_whitespace_size - 1).each { |i| line[i] = "." }
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
    mab.to_s
  end

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
        data_lines_with_colors.each {|line, color|
          # binding.pry
          mab.font(color: color)
          mab.text(line)
          mab.br
        }
      end
    end
    mab.to_s
  end

  def analysis_title
    [@original_filename, "Analysis"].join(" ")
  end

  def avg_execution_times
    @original_file_contents.each_with_index.map { |_, line_number|
      data = @annotation_data[line_number]
      if data && data[:execution_count] > 0
        tet = total_execution_time(data)
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

  def total_execution_time(data)
    ((data[:time_before_line] || []).sort.zip((data[:time_after_line] || []).sort) || []).map { |pair|
      if pair.include?(nil)
        0
      else
        pair.first - pair.last
      end

    }.inject(&:+)
  end
end
