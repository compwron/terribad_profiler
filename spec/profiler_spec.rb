describe Profiler do
  subject { described_class.new(example).profile! }
  let(:time) { Time.new(2016, 1, 21) }

  context "with one line example" do
    let(:example) { "samples/1.rb" }
    it "records line count" do
      Timecop.freeze(time) do
        expect(subject).to eq [{line_number: 1,
          time_before_line: [time],
          time_after_line: [time],
          execution_count: 1}]
      end
    end
  end

  context "with loop example" do
    let(:example) { "samples/2.rb" }
    it "records line count" do
      Timecop.freeze(time) do
        expect(subject).to eq [
          { line_number: 1,
            time_before_line: [time],
            time_after_line: [time],
            execution_count: 1},
          { line_number: 2,
            time_before_line: [time, time],
            time_after_line: [time, time],
            execution_count: 3},
          { line_number: 3,
            time_before_line: [time],
            time_after_line: [time],
            execution_count: 1},
          ]
      end
    end
  end
end
