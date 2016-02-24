describe Profiler do
  subject { described_class.new(example).profile! }

  context "with one line example" do
    let(:example) { "samples/1.rb" }
    it "records line count" do
      expect(subject.size).to eq 1
      expect(subject[0][:execution_count]).to eq 1.0
      expect(subject[0][:time_after_line].size).to be 1
      expect(subject[0][:time_before_line].size).to be 1
      expect(subject[0][:time_before_line].first).to be <= Time.now.to_f
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

  context "pretty formatting" do
    subject { profiler.overview }
    before { Timecop.freeze(Time.parse("2016-1-30")) }
    after { Timecop.return }

    context "simple example" do
      let(:profiler) { described_class.new(example) }
      let(:example) { "samples/4.rb" }
      let(:so_much_html) { "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/><title> analysis</title><style type=\"text/css\">\n            body { font: 11px/120% Courier, sans-serif }\n          </style></head><body><h1>Analysis</h1><font color=\"green\"/>a = false................................... execution count: 1 avg_execution_time: 0.0000247955<br/><font color=\"red\"/>if a........................................ execution count: 0 avg_execution_time: -1<br/><font color=\"red\"/>..puts \"this line does not happen\".......... execution count: 0 avg_execution_time: -1<br/><font color=\"red\"/>end......................................... execution count: 0 avg_execution_time: -1<br/><font color=\"green\"/>b = \"cat\"................................... execution count: 1 avg_execution_time: 0.0000016689<br/><font color=\"green\"/>sleep 1..................................... execution count: 1 avg_execution_time: 1.0046389103<br/><font color=\"green\"/>puts b...................................... execution count: 1 avg_execution_time: 0.0000131130<br/></body></html>" }

      it "creates colored html" do
        expect(except_avg_execution_time(subject)).to eq except_avg_execution_time(so_much_html)
      end
    end

    context "with class" do
      let(:profiler) { described_class.new(example) }
      let(:example) { "samples/5.rb" }
      let(:expected_html) {"<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/><title> analysis</title><style type=\"text/css\">\n            body { font: 11px/120% Courier, sans-serif }\n          </style></head><body><h1>Analysis</h1><font color=\"green\"/>class Foo................. execution count: 1 avg_execution_time: 0.0<br/><font color=\"green\"/>..def bar(a).............. execution count: 1 avg_execution_time: 0.0<br/><font color=\"red\"/>....if a > 1.............. execution count: 0 avg_execution_time: -1<br/><font color=\"red\"/>......1................... execution count: 0 avg_execution_time: -1<br/><font color=\"red\"/>....else.................. execution count: 0 avg_execution_time: -1<br/><font color=\"green\"/>......2................... execution count: 1 avg_execution_time: 0.0<br/><font color=\"green\"/>....end................... execution count: 1 avg_execution_time: 0.0<br/><font color=\"green\"/>..end..................... execution count: 1 avg_execution_time: 0.0<br/><font color=\"green\"/>end....................... execution count: 1 avg_execution_time: 0.0<br/><font color=\"green\"/>.......................... execution count: 1 avg_execution_time: 0.0<br/><font color=\"green\"/>Foo.new.bar(-1)........... execution count: 1 avg_execution_time: 0.0<br/><font color=\"green\"/># Foo.new.bar(5).......... execution count: 1 avg_execution_time: 0.0<br/></body></html>"}
      it "still reports good data" do
        expect(except_avg_execution_time(subject)).to eq except_avg_execution_time(expected_html)
      end
    end

    def except_avg_execution_time(html)
      html.gsub(/avg_execution_time: \d.\d+/, "avg_execution_time: precision_is_hard")
    end
  end
end
