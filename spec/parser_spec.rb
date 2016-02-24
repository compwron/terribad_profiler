describe Parser do
  subject { described_class.new(data).parsed_data }

  context "with empty data" do
    let(:data) { [] }
    it "" do
      expect(subject).to eq({})
    end
  end

  context "with simplest data" do
    let(:data) { [
        "line_number:0,BEFORE,1456278070.898416",
        "hi",
        "line_number:0,AFTER,1456278070.898442"] }
    it "" do
      expect(subject).to eq(
                             {
                                 0 => {
                                     :time_before_line => [1456278070.898416],
                                     :time_after_line => [1456278070.898442],
                                     :execution_count => 1}})
    end
  end

  context "with longer data" do
    let(:data) { [
        "line_number:0,BEFORE,1456278277.718526",
        "line_number:0,AFTER,1456278277.7185512",
        "line_number:1,BEFORE,1456278277.718555",
        "line_number:7,AFTER,1456278277.7185578",
        "line_number:8,BEFORE,1456278277.71856",
        "line_number:8,AFTER,1456278277.7185621",
        "line_number:9,BEFORE,1456278277.718564",
        "line_number:9,AFTER,1456278277.718566",
        "line_number:10,BEFORE,1456278277.718567",
        "line_number:1,AFTER,1456278277.71857",
        "line_number:2,BEFORE,1456278277.7185721",
        "line_number:4,AFTER,1456278277.718574",
        "line_number:5,BEFORE,1456278277.7185762",
        "line_number:5,AFTER,1456278277.718577",
        "line_number:6,BEFORE,1456278277.718579",
        "line_number:6,AFTER,1456278277.718581",
        "foo",
        "line_number:7,BEFORE,1456278277.718583",
        "line_number:10,AFTER,1456278277.718584",
        "line_number:11,BEFORE,1456278277.7185862",
        "line_number:11,AFTER,1456278277.7185879"] }
    it "" do
      expect(subject).to eq(
                             {0 =>
                                  {:time_before_line => [1456278277.718526],
                                   :time_after_line => [1456278277.7185512],
                                   :execution_count => 1},
                              1 =>
                                  {:time_before_line => [1456278277.718555],
                                   :time_after_line => [1456278277.71857],
                                   :execution_count => 1},
                              7 =>
                                  {:time_before_line => [1456278277.718583],
                                   :time_after_line => [1456278277.7185578],
                                   :execution_count => 1},
                              8 =>
                                  {:time_before_line => [1456278277.71856],
                                   :time_after_line => [1456278277.7185621],
                                   :execution_count => 1},
                              9 => {:time_before_line => [1456278277.718564],
                                    :time_after_line => [1456278277.718566],
                                    :execution_count => 1},
                              10 => {:time_before_line => [1456278277.718567],
                                     :time_after_line => [1456278277.718584],
                                     :execution_count => 1},
                              2 => {:time_before_line => [1456278277.7185721],
                                    :time_after_line => [],
                                    :execution_count => 0},
                              4 => {:time_before_line => [],
                                    :time_after_line => [1456278277.718574],
                                    :execution_count => 0},
                              5 => {:time_before_line => [1456278277.7185762],
                                    :time_after_line => [1456278277.718577],
                                    :execution_count => 1},
                              6 => {:time_before_line => [1456278277.718579],
                                    :time_after_line => [1456278277.718581],
                                    :execution_count => 1},
                              11 => {:time_before_line => [1456278277.7185862],
                                     :time_after_line => [1456278277.7185879],
                                     :execution_count => 1}})
    end
  end
end

