require 'rails_helper'

RSpec.describe "SearchLogs", type: :request do
  describe "POST /search_logs" do
    it "creates a new SearchQuery regardless of final flag" do
      expect {
        post "/search_logs", params: { query: "hello", final: false }
      }.to change(SearchQuery, :count).by(1)
      .and change(SearchSummary, :count).by(0)
    end

    it "creates a new SearchSummary only if final is true" do
      expect {
        post "/search_logs", params: { query: "hello", final: true }
      }.to change(SearchQuery, :count).by(1)
      .and change(SearchSummary, :count).by(1)
    end


    it "creates a new summary even if the query is shorter than the previous one" do
      # First longer query
      post "/search_logs", params: { query: "hello", final: true }
      expect(SearchSummary.count).to eq(1)
      expect(SearchSummary.last.query).to eq("hello")

      # Then a shorter one — should still create a new summary
      post "/search_logs", params: { query: "hell", final: true }
      expect(SearchSummary.count).to eq(2)
      expect(SearchSummary.last.query).to eq("hell")
    end

    it "replaces previous summary if new query expands it" do
      # Initial short query
      post "/search_logs", params: { query: "hel", final: true }
      expect(SearchSummary.count).to eq(1)
      expect(SearchSummary.last.query).to eq("hel")

      # Now a longer, expanded query
      post "/search_logs", params: { query: "hello", final: true }

      # Should create a new summary
      expect(SearchSummary.count).to eq(1)
      expect(SearchSummary.last.query).to eq("hello")
    end

    it "keeps summaries separate for different IPs" do
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return("1.1.1.1")
      post "/search_logs", params: { query: "apple", final: true }

      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return("2.2.2.2")
      post "/search_logs", params: { query: "banana", final: true }

      expect(SearchSummary.count).to eq(2)
      expect(SearchSummary.pluck(:query)).to contain_exactly("apple", "banana")
    end


    # Stress test
    it "handles thousands of queries and creates the expected number of summaries" do
      ip = "123.456.789.001"
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return(ip)

      5000.times do |i|
        query = "test_query_#{i}"
        post "/search_logs", params: { query: query, final: false }
      end

      # Final one with `final: true`
      post "/search_logs", params: { query: "final_query", final: true }

      expect(SearchQuery.count).to eq(5001)
      expect(SearchSummary.count).to eq(1)
      expect(SearchSummary.last.query).to eq("final_query")
    end
  end
end
