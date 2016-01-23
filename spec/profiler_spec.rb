describe Profiler do
  subject { described_class.new(example).profile! }
  let(:time) { Time.utc(2016, 1, 21) }

  context "with one line example" do
    let(:example) { "samples/1.rb" }
    it "records line count" do
      expect(subject.size).to eq 1
      expect(subject[0][:execution_count]).to eq 1.0
      expect(subject[0][:time_after_line].size).to be 1
      expect(subject[0][:time_before_line].size).to be 1
      expect(subject[0][:time_before_line].first).to be <= Time.now.utc
    end
  end

  context "with loop example" do
    let(:example) { "samples/2.rb" }
    it "records line count" do
      expect(subject.size).to eq 3
      expect(subject[0][:execution_count]).to eq 1
      expect(subject[0][:time_before_line].size).to be 1
      expect(subject[0][:time_after_line].size).to be 3

      expect(subject[1][:execution_count]).to eq 3.0
      expect(subject[1][:time_before_line].size).to be 3
      expect(subject[1][:time_after_line].size).to be 3

      expect(subject[2][:execution_count]).to eq 1
      expect(subject[2][:time_before_line].size).to be 3
      expect(subject[2][:time_after_line].size).to be 1
    end
  end
end
