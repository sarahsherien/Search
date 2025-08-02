class AnalyticsController < ApplicationController
  def index
    @summaries_by_ip = SearchSummary.all.group_by(&:ip_address)
  end
end