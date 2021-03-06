require 'spec_helper'

describe Mendeley do
  let(:mendeley) { FactoryGirl.create(:mendeley) }
  
  it "should report that there are no events if the doi, pmid and mendeley uuid are missing" do
    article_without_ids = FactoryGirl.build(:article, :doi => "", :pub_med => "", :mendeley => "")
    mendeley.get_data(article_without_ids).should eq({ :events => [], :event_count => nil })
  end
  
  context "use the Mendeley API for uuid lookup" do
    let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776", :mendeley => "") }
    
    it "should return the Mendeley uuid by the Mendeley API" do
      stub = stub_request(:get, mendeley.get_query_url(article.pub_med, "pmid")).to_return(:body => File.read(fixture_path + 'mendeley.json'), :status => 200)
      mendeley.get_mendeley_uuid(article).should eq("46cb51a0-6d08-11df-afb8-0026b95d30b2")
      stub.should have_been_requested
    end
    
    it "should return the Mendeley uuid by searching the Mendeley API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001", :mendeley => "") 
      stub = stub_request(:get, mendeley.get_query_url(article.pub_med, "pmid")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
      stub_doi = stub_request(:get, mendeley.get_query_url(CGI.escape(CGI.escape(article.doi)), "doi")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
      stub_title = stub_request(:get, mendeley.get_query_url(CGI.escape(CGI.escape(article.title)), "title")).to_return(:body => File.read(fixture_path + 'mendeley_search.json'), :status => 200)
      mendeley.get_mendeley_uuid(article).should eq("1779af10-6d0c-11df-a2b2-0026b95e3eb7")
      stub.should have_been_requested
      stub_doi.should have_been_requested
      stub_title.should have_been_requested
    end
    
    it "should return nil for the Mendeley uuid if the Mendeley API returns malformed response" do
      stub = stub_request(:get, mendeley.get_query_url(article.pub_med, "pmid")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
      stub_doi = stub_request(:get, mendeley.get_query_url(CGI.escape(CGI.escape(article.doi)), "doi")).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 200)
      stub_title = stub_request(:get, mendeley.get_query_url(CGI.escape(CGI.escape(article.title)), "title")).to_return(:body => File.read(fixture_path + 'mendeley_search.json'), :status => 200)
      mendeley.get_mendeley_uuid(article).should be_nil
      stub.should have_been_requested
      stub_doi.should have_been_requested
      stub_title.should have_been_requested
      ErrorMessage.count.should == 0
    end
    
    it "should return nil for the Mendeley uuid if the Mendeley API returns incomplete response" do
      stub = stub_request(:get, mendeley.get_query_url(article.pub_med, "pmid")).to_return(:body => File.read(fixture_path + 'mendeley_incomplete.json'), :status => 200)
      stub_doi = stub_request(:get, mendeley.get_query_url(CGI.escape(CGI.escape(article.doi)), "doi")).to_return(:body => File.read(fixture_path + 'mendeley_incomplete.json'), :status => 200)
      stub_title = stub_request(:get, mendeley.get_query_url(CGI.escape(CGI.escape(article.title)), "title")).to_return(:body => File.read(fixture_path + 'mendeley_search.json'), :status => 200)
      mendeley.get_mendeley_uuid(article).should be_nil
      stub.should have_been_requested
      stub_doi.should have_been_requested
      stub_title.should have_been_requested
      ErrorMessage.count.should == 0
    end
  end
    
  context "use the Mendeley API for metrics" do
    it "should report if there are no events and event_count returned by the Mendeley API" do
      article = FactoryGirl.build(:article)
      stub = stub_request(:get, mendeley.get_query_url(article.mendeley)).to_return(:body => File.read(fixture_path + 'mendeley_error.json'), :status => 404)
      mendeley.get_data(article).should eq({ :events => [], :event_count => 0 })
      stub.should have_been_requested
      ErrorMessage.count.should == 0
    end
    
    it "should report if there are events and event_count returned by the Mendeley API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776", :mendeley => "46cb51a0-6d08-11df-afb8-0026b95d30b2")
      body = File.read(fixture_path + 'mendeley.json')
      stub = stub_request(:get, mendeley.get_query_url(article.mendeley)).to_return(:body => body, :status => 200)
      stub_related = stub_request(:get, mendeley.get_related_url(article.mendeley)).to_return(:body => File.read(fixture_path + 'mendeley_related.json'), :status => 200)
      response = mendeley.get_data(article)
      response[:events].should be_true
      response[:events_url].should be_true
      response[:event_count].should eq(4)
      stub.should have_been_requested
    end
    
    it "should report no events and event_count if the Mendeley API returns incomplete response" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      stub = stub_request(:get, mendeley.get_query_url(article.mendeley)).to_return(:body => File.read(fixture_path + 'mendeley_incomplete.json'), :status => 200)
      mendeley.get_data(article).should eq({ :events => [], :event_count => 0 })
      stub.should have_been_requested
      ErrorMessage.count.should == 0
    end
    
    it "should report no events and event_count if the Mendeley API returns malformed response" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      stub = stub_request(:get, mendeley.get_query_url(article.mendeley)).to_return(:body => File.read(fixture_path + 'mendeley_nil.json'), :status => 404)
      mendeley.get_data(article).should eq({ :events => [], :event_count => 0 })
      stub.should have_been_requested
      ErrorMessage.count.should == 0
    end
    
    it "should catch errors with the Mendeley API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, mendeley.get_query_url(article.mendeley)).to_return(:status => [408, "Request Timeout"])
      mendeley.get_data(article).should be_nil
      stub.should have_been_requested
      ErrorMessage.count.should == 1
      error_message = ErrorMessage.first
      error_message.class_name.should eq("Net::HTTPRequestTimeOut")
      error_message.message.should include("Request Timeout")
      error_message.status.should == 408
      error_message.source_id.should == mendeley.id
    end
  end
end