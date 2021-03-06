require 'spec_helper'

describe SourcesController do
  render_views
  
  context "RSS" do
    
    before(:each) do
      FactoryGirl.create_list(:article_with_events, 10)
    end
    
    let(:source) { FactoryGirl.create(:source) }

    it "returns an RSS feed for most-cited (7 days)" do
      get source_path(source, format: "rss", days: 7)
      last_response.status.should eql(200)
      last_response.should render_template("sources/show")
      last_response.content_type.should eq("application/rss+xml; charset=utf-8")
      
      response = Nori.new.parse(last_response.body)
      response = response["rss"]
      response["@version"].should eq("2.0")
      response["channel"]["title"].should eq(APP_CONFIG['useragent'] + ": most-cited articles in #{source.display_name}")
      URI.parse(response["channel"]["link"]).path.should eq(source_path(source))
      response["channel"]["item"].should_not be_nil
    end
  
    it "returns an RSS feed for most-cited (30 days)" do
      get source_path(source, format: "rss", days: 30)
      last_response.status.should eql(200)
      last_response.should render_template("sources/show")
      last_response.content_type.should eq("application/rss+xml; charset=utf-8")
      
      response = Nori.new.parse(last_response.body)
      response = response["rss"]
      response["@version"].should eq("2.0")
      response["channel"]["title"].should eq(APP_CONFIG['useragent'] + ": most-cited articles in #{source.display_name}")
      URI.parse(response["channel"]["link"]).path.should eq(source_path(source))
      response["channel"]["item"].should_not be_nil
    end
  
    it "returns an RSS feed for most-cited (12 months)" do
      get source_path(source, format: "rss", months: 12)
      last_response.status.should eql(200)
      last_response.should render_template("sources/show")
      last_response.content_type.should eq("application/rss+xml; charset=utf-8")
      
      response = Nori.new.parse(last_response.body)
      response = response["rss"]
      response["@version"].should eq("2.0")
      response["channel"]["title"].should eq(APP_CONFIG['useragent'] + ": most-cited articles in #{source.display_name}")
      URI.parse(response["channel"]["link"]).path.should eq(source_path(source))
      response["channel"]["item"].should_not be_nil
    end
  
    it "returns an RSS feed for most-cited" do
      get source_path(source, format: "rss")
      last_response.status.should eql(200)
      last_response.should render_template("sources/show")
      last_response.content_type.should eq("application/rss+xml; charset=utf-8")
      
      response = Nori.new.parse(last_response.body)
      response = response["rss"]
      response["@version"].should eq("2.0")
      response["channel"]["title"].should eq(APP_CONFIG['useragent'] + ": most-cited articles in #{source.display_name}")
      URI.parse(response["channel"]["link"]).path.should eq(source_path(source))
      response["channel"]["item"].should_not be_nil
    end
  end

end