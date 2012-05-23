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

  describe '#concat' do
    it 'sets the body when empty' do
      response = EM::Twitter::Response.new
      response.concat('{ "status" : true }')
      response.body.should eq('{ "status" : true }')
    end

    it 'appends to an existing body' do
      response = EM::Twitter::Response.new('{ "status" : true')
      response.concat(', "enabled" : false }')
      response.body.should eq('{ "status" : true, "enabled" : false }')
    end

    it 'only appends when passed json' do
      str = '{ "status" : true'
      response = EM::Twitter::Response.new(str)
      response.concat('ohai')
      response.body.should eq(str)
    end

    it 'passively fails on nil' do
      response = EM::Twitter::Response.new
      lambda {
        response.concat(nil)
      }.should_not raise_error
    end

    it 'passively fails on empty strings' do
      response = EM::Twitter::Response.new('ohai')
      response.concat('')
      response.body.should eq('ohai')
    end

    it 'passively fails on blank strings' do
      response = EM::Twitter::Response.new('ohai')
      response.concat('  ')
      response.body.should eq('ohai')
    end

    it 'is aliased as <<' do
      response = EM::Twitter::Response.new
      response << '{ "status" : true }'
      response.body.should eq('{ "status" : true }')
    end

    it 'updates the timestamp when data is received' do
      response = EM::Twitter::Response.new
      response << '{ "status" : true }'
      response.timestamp.should be_kind_of(Time)
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

  describe '#older_than?' do
    it 'returns false when the last response is younger than the number of seconds' do
      response = EM::Twitter::Response.new
      response.older_than?(100).should be_false
    end

    it 'returns true when the last response is older than the number of seconds' do
      response = EM::Twitter::Response.new
      response.concat('fakebody')
      sleep(2)
      response.older_than?(1).should be_true
    end

    it 'generates a timestamp when no initial timestamp exists' do
      response = EM::Twitter::Response.new
      response.older_than?(100)
      response.timestamp.should be_kind_of(Time)
    end
  end

  describe '#empty?' do
    it 'returns true when an empty body' do
      EM::Twitter::Response.new.should be_empty
    end

    it 'returns false when a body is present' do
      EM::Twitter::Response.new('{ "status" : true }').should_not be_empty
    end
  end

  describe '#reset' do
    it 'resets the body to an empty string' do
      response = EM::Twitter::Response.new('{ "status" : true }')
      response.body.length.should be > 0
      response.reset
      response.body.should eq('')
    end
  end
end