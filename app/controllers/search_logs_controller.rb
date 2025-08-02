class SearchLogsController < ApplicationController
  def create
    query = params[:query].to_s.strip
    ip = request.remote_ip

    return head :ok if query.blank?

    session = SearchSession.where(ip: ip).where("started_at > ?", 2.minutes.ago).order(started_at: :desc).first
    session ||= SearchSession.create!(ip: ip, started_at: Time.current)

    session.search_queries.create!(
      query_text: query,
      submitted_at: Time.current
    )

    summarize_session(ip, query) if params[:final].to_s == "true"
    head :ok
  end

  private

  def summarize_session(ip, new_query)
    latest_summary = SearchSummary.where(ip_address: ip).order(created_at: :desc).first

    if latest_summary&.query && new_query.include?(latest_summary.query)
      # Replace old summary with the extended one
      latest_summary.update!(query: new_query)
    elsif latest_summary&.query == new_query
      # Avoid duplicate identical queries
      return
    else
      # Create new summary
      SearchSummary.create!(ip_address: ip, query: new_query)
    end
  end
end
