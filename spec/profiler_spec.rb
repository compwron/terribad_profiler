describe Profiler do
  subject { described_class.new(example_1).profile! }
  it "records line count" do
    time = Time.new(2016, 1, 21)
    Timecop.freeze(time) do
      expect(subject).to eq [{line_number: 1,
        time_before_line: [time],
        time_after_line: [time],
        execution_count: 1}]
    end
  end
end
