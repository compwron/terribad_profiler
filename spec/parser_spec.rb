describe Parser do
  subject { described_class.new(data).parsed_data }

  context "with empty data" do
    let(:data) {[]}
    it ""  do
      expect(subject).to eq nil
    end
  end

  context "with simplest data" do
    let(:data) { ["line_number:0,BEFORE,1456278070.898416", "hi", "line_number:0,AFTER,1456278070.898442"] }
    it "" do
      expect(subject).to eq({
        0=>{
          :time_before_line=>[1456278070.898416],
          :time_after_line=>[1456278070.898442],
          :execution_count=>1}})
    end
  end
end

