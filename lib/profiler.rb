class Profiler
  def initialize(filepath)
  end

  def profile!
    [{line_number: 1,
           time_before_line: [Time.now],
           time_after_line: [Time.now],
           execution_count: 1}]
  end
end
