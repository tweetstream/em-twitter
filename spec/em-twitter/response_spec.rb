require 'spec_helper'

describe EM::Twitter::Response do

  describe '.new' do
    it 'initializes an empty body' do
      EM::Twitter::Response.new.body.should eq('')
    end

    it 'initializes with a body parameter' do
      EM::Twitter::Response.new('ohai').body.should eq('ohai')
    end
  end

  describe '#<<' do
    before(:each) do
      @response = EM::Twitter::Response.new('{ "status" : true }')
    end

    it 'sets the body when empty' do
      @response.body.should eq('{ "status" : true }')
    end

    it 'appends to an existing body' do
      @response << '{ "status" : false }'
      @response.body.should eq('{ "status" : true }{ "status" : false }')
    end
  end

  describe '#complete?' do
    it 'returns false when an incomplete body' do
      EM::Twitter::Response.new('{ "status" : true').complete?.should be_false
    end

    it 'returns false when an complete body' do
      EM::Twitter::Response.new('{ "status" : true }').complete?.should be_true
    end
  end
end