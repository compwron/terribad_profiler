class Profiler
  def initialize(filepath)
    @original_filename = File.basename(filepath)
    @original_file = File.open(filepath)
  end

  def profile!
    # binding.pry
    new_filepath = "tmp/annotated_#{@original_filename}"
    f = File.open(new_filepath, "w")
    f.puts annotate(@original_file)
    annotation_output = `ruby new_filepath`
    @annotation_data = parse(annotation_output)
    [{line_number: 1,
           time_before_line: [Time.now],
           time_after_line: [Time.now],
           execution_count: 1}]
  end

  private

  def annotate(file)
    contents = file.read
    binding.pry
    p contents
  end

  def parse(output)
  end
end

