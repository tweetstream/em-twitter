require 'spec_helper'

describe EM::Twitter::Request do

  describe '.new' do
    it 'assigns a proxy if one is set' do
      req = EM::Twitter::Request.new(:proxy => { :uri => 'http://my-proxy:8080', :user => 'username', :password => 'password'})
      req.proxy?.should be_true
    end
  end

  describe '#to_s' do
    context 'without a proxy' do
    end

    context 'when using a proxy' do
    end
  end
end