require 'spec_helper'
require 'spree/core/testing_support/preferences'

module Spree
  describe Omnikassa do
    let(:order) do
      FactoryGirl.create :completed_order_with_totals
    end
    
    before do
      # Use sprees default reset preference method
      config = Rails.application.config.spree.preferences
      config.reset
      config.currency = "EUR"
      Spree::Config[:omnikassa_merchant_id] = '1337'
      Spree::Config[:omnikassa_transaction_reference_prefix] = 'PREFIX'
      Spree::Config[:omnikassa_key_version] = '7'
      Spree::Config[:omnikassa_secret_key] = 'SECRET'
    end
    
    subject { Spree::Omnikassa.new order, 'http://e.x' }

    it 'has a seal' do
      seal = 'f567f491346710399e8cd608087daafb452e7a95757a685f8081424f739adffb'
      subject.seal.should eq seal
    end

    it 'has the data string' do
      d = "amount=1000|" \
          "currencyCode=978|" \
          "merchantId=1337|" \
          "normalReturnUrl=http://e.x/omnikassa/success/#{order.id}/|" \
          "automaticResponseUrl=http://e.x/omnikassa/success/automatic/#{order.id}/|"\
          "transactionReference=PREFIX#{order.id}|" \
          "keyVersion=7"
      subject.data.should eq d
    end
    
    context 'payment data' do
      it 'has the amount in cents' do
        subject.payment_data[:amount].should equal 1000
      end

      it 'has has the currency code of the current configuration' do
        subject.payment_data[:currencyCode].should eq '978'
      end

      it 'has the configured key version' do
        subject.payment_data[:keyVersion].should eq '7'
      end

      it 'has the configured merchant id' do
        subject.payment_data[:merchantId].should eq '1337'
      end

      it 'has the normal return url' do
        subject.payment_data[:normalReturnUrl].should eq "http://e.x/omnikassa/success/#{order.id}/"
      end
 
      it 'has the automatic return url' do
        subject.payment_data[:automaticResponseUrl].should eq "http://e.x/omnikassa/success/automatic/#{order.id}/"
      end

      it 'has the transaction reference' do
        subject.payment_data[:transactionReference].should eq "PREFIX#{order.id}"
      end
    end
  end
end
