describe Helpers::Paginator do

  let(:url) { "https://example.localhost.com" }

  def encoded_data
    MultiJson.encode(incident_details)
  end

  def incident_details
    {
      "incident_id"=>900,
      "title"=>"Routing issues",
      "state"=>"resolved",
      "started_at"=>"2016-06-02T12:09:37.154Z",
      "updated_at"=>"2016-06-10T20:48:54.483Z",
      "resolved"=>true,
      "duration"=>1016,
      "resolved_at"=>"2016-06-02T12:26:33.061Z",
      "review"=>true,
    }
  end

  describe "#fetch" do
    describe "with one request" do
      before do
        stub_request(:get, "#{url}/?page=1&per_page=100").to_return(
          body: encoded_data,
          headers: {"Link" => "<#{url}?page=1&per_page=100>; rel=\"last\", <#{url}?page=1&per_page=100>; rel=\"next\""}
        )
      end

      it 'fetchs with one request' do
        Helpers::Paginator.fetch(url)

        expect(WebMock).to have_requested(:get, "#{url}/?page=1&per_page=100").once
      end
    end

    describe "Multiple requests" do
      before do
        stub_request(:get, /.*example.localhost.com.*/).to_return(
          body: encoded_data,
          headers: {"Link" => "<#{url}?page=2&per_page=100>; rel=\"last\", <#{url}?page=2&per_page=100>; rel=\"next\""}
        )
      end

      it 'fetchs with multiple requests' do
        Helpers::Paginator.fetch(url)

        expect(WebMock).to have_requested(:get, /.*example.localhost.com.*/).twice

        expect(WebMock).to have_requested(:get, "#{url}/?page=1&per_page=100").once
        expect(WebMock).to have_requested(:get, "#{url}/?page=2&per_page=100").once
      end
    end
  end
end
