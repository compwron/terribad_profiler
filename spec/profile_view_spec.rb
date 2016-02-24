describe ProfileView do
  subject { described_class.new(original_file_contents, annotation_data, original_filename).overview }

  context "with nothing" do
    let(:original_file_contents) { [""] }
    let(:annotation_data) { {} }
    let(:original_filename) {}

    it "renders empty results" do
      expect(subject).to eq "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/><title> Analysis</title><style type=\"text/css\">\n            body { font: 11px/120% Courier, sans-serif }\n          </style></head><body><h1> Analysis</h1><font color=\"red\"/>.......... execution count: 0 avg_execution_time: -1<br/></body></html>"
    end
  end

  context "with file contents" do
    let(:original_file_contents) { [
        "class Foo",
        "  def bar(a)",
        "    if a > 1",
        "      1",
        "    else",
        "      2",
        "    end",
        "  end",
        "end",
        "",
        "Foo.new.bar(-1)",
        "# Foo.new.bar(5)"] }

    let(:annotation_data) {
      {0 => {:time_before_line => [1456349870.7617438], :time_after_line => [1456349870.7617679], :execution_count => 1},
       1 => {:time_before_line => [1456349870.761771], :time_after_line => [1456349870.761787], :execution_count => 1},
       7 => {:time_before_line => [1456349870.7618], :time_after_line => [1456349870.761775], :execution_count => 1},
       8 => {:time_before_line => [1456349870.761777], :time_after_line => [1456349870.7617779], :execution_count => 1},
       9 => {:time_before_line => [1456349870.76178], :time_after_line => [1456349870.761782], :execution_count => 1},
       10 => {:time_before_line => [1456349870.761784], :time_after_line => [1456349870.761802], :execution_count => 1},
       2 => {:time_before_line => [1456349870.7617888], :time_after_line => [], :execution_count => 0},
       4 => {:time_before_line => [], :time_after_line => [1456349870.761791], :execution_count => 0},
       5 => {:time_before_line => [1456349870.7617931], :time_after_line => [1456349870.761795], :execution_count => 1},
       6 => {:time_before_line => [1456349870.7617972], :time_after_line => [1456349870.7617989], :execution_count => 1},
       11 => {:time_before_line => [1456349870.761804], :time_after_line => [1456349870.761806], :execution_count => 1}} }

    let(:original_filename) { "5.rb" }

    it "generates html" do
      expect(subject).to eq "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/><title>5.rb Analysis</title><style type=\"text/css\">\n            body { font: 11px/120% Courier, sans-serif }\n          </style></head><body><h1>5.rb Analysis</h1><font color=\"green\"/>class Foo................. execution count: 1 avg_execution_time: 0.0000240803<br/><font color=\"green\"/>..def bar(a).............. execution count: 1 avg_execution_time: 0.0000159740<br/><font color=\"red\"/>....if a > 1.............. execution count: 0 avg_execution_time: -1<br/><font color=\"red\"/>......1................... execution count: 0 avg_execution_time: -1<br/><font color=\"red\"/>....else.................. execution count: 0 avg_execution_time: -1<br/><font color=\"green\"/>......2................... execution count: 1 avg_execution_time: 0.0000019073<br/><font color=\"green\"/>....end................... execution count: 1 avg_execution_time: 0.0000016689<br/><font color=\"green\"/>..end..................... execution count: 1 avg_execution_time: 0.0000250340<br/><font color=\"green\"/>end....................... execution count: 1 avg_execution_time: 0.0000009537<br/><font color=\"green\"/>.......................... execution count: 1 avg_execution_time: 0.0000019073<br/><font color=\"green\"/>Foo.new.bar(-1)........... execution count: 1 avg_execution_time: 0.0000178814<br/><font color=\"green\"/># Foo.new.bar(5).......... execution count: 1 avg_execution_time: 0.0000019073<br/></body></html>"
    end
  end
end
