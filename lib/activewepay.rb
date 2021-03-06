require "activewepay/version"
require 'rubygems'
require 'uri'
require 'json'
require 'net/http'
require 'net/https'
require 'cgi'
require 'active_model'
 
module ActiveWepay
  class Base
    include ActiveModel::Model

    attr_accessor :oauth_token
    attr_reader :errors, :id, :amount, :redirect_uri, :callback_uri, :response, :name

    STAGE_API_ENDPOINT = "https://stage.wepayapi.com/v2"
    STAGE_UI_ENDPOINT = "https://stage.wepay.com/v2"
  
    PRODUCTION_API_ENDPOINT = "https://wepayapi.com/v2"
    PRODUCTION_UI_ENDPOINT = "https://www.wepay.com/v2"

    validate :validate_response
     
    def initialize(options)
      @errors = ActiveModel::Errors.new(self)
      @options = options

      options[:oauth_token]  ? @oauth_token = options[:oauth_token] : false
      options[:amount]       ? @amount = options[:amount] : false
      options[:account_id]   ? @account_id = options[:account_id] : false
      options[:redirect_uri] ? @redirect_uri = options[:redirect_uri] : false
      options[:callback_uri] ? @callback_uri = options[:callback_uri] : false
      options[:id]           ? @id = options[:id] : false
      options[:name]         ? @name = options[:name] : false
    end
     
    # make a call to the WePay API
    def call(path, access_token = false, params = false)
      if Rails.env == 'development' || Rails.env == 'test'
        api_endpoint = STAGE_API_ENDPOINT
        ui_endpoint = STAGE_UI_ENDPOINT
      else
        api_endpoint = PRODUCTION_API_ENDPOINT
        ui_endpoint = PRODUCTION_UI_ENDPOINT
      end
         
      # get the url
      url = URI.parse(api_endpoint + path)
      # construct the call data and access token
      call = Net::HTTP::Post.new(url.path, initheader = {'Content-Type' =>'application/json', 'User-Agent' => 'WePay Ruby SDK'})
      if params
        call.body = params.to_json
      end

      if access_token
        call.add_field('Authorization: Bearer', access_token)
      end

      # create the request object
      request = Net::HTTP.new(url.host, url.port)
      request.use_ssl = true
      # make the call
      response = request.start {|http| http.request(call) }
      # returns JSON response as ruby hash
      @response = JSON.parse!(response.body, :symbolize_names => true)
      
      self
    end

    private 
  
    def validate_response
      if @response && @response[:error]
        @errors.add(@response[:error].to_sym, @response[:error_description])
      end
    end

    def method_missing(method_name, *args, &block)
      if @response and @response.keys.include? method_name.to_sym
        @response[method_name.to_sym]
      elsif @options.keys.include? method_name.to_sym
        @options[method_name.to_sym]
      else
        super
      end
    end
  end

  class Account < Base

    validates_presence_of :oauth_token
    
    def self.create(options)
      account = self.new(options)

      theme = { name: 'Black and White', primary_color: 'FFFFFF', secondary_color: '000000', background_color: 'FFFFFF', button_color: 'FFFFFF' }
      account.call('/account/create', account.oauth_token, {
        :name => account.name,
        :description => 'Automatically generated by Vocalem',
        :theme_object => theme 
      })
    end
  end

  class Checkout < Base

    validates_presence_of :oauth_token 

    def self.create(options)
      checkout = self.new(options)
      checkout.call('/checkout/create', checkout.oauth_token, {
        account_id: checkout.account_id,
        amount: checkout.amount,
        short_description: 'Payment',
        type: 'DONATION',
        mode: 'iframe',
        app_fee: checkout.amount * 0.021,
        redirect_uri: checkout.redirect_uri,
        callback_uri: checkout.callback_uri 
      })
    end
  
    def self.find(options)
      checkout = self.new(options)
      checkout.information
    end
   
    def information
      validates_presence_of :id

      call('/checkout/', @oauth_token, {
        checkout_id: @id
      })
    end
    
    def cancel
      validates_presence_of :id
 
      self.call('/checkout/cancel/', @oauth_token, {
        checkout_id: @id,
        cancel_reason: 'Refund'
      })
    end
  
    def refund
      validates_presence_of :id

      call('/checkout/refund', @oauth_token, {
        checkout_id: @id,
        refund_reason: 'Refunded'
      })
    end
  end

  class Preapproval < Base

    validates_presence_of :oauth_token
  
    def self.create(options)

      validates_presence_of :account_id, :amount, :redirect_uri, :callback_uri

      recurring = self.new(options)
      recurring.call('/preapproval/create', recurring.oauth_token, {
        short_description: 'Vocalem plan change',
        account_id: recurring.account_id,
        amount: recurring.amount,
        period: 'monthly',
        redirect_uri: recurring.redirect_uri,
        callback_uri: recurring.callback_uri, 
        auto_recur: true,
        mode: 'iframe'
      }) 
    end
  
    def self.find(options)
      validates_presence_of :id

      recurring = self.new(options)
  
      recurring.call('/preapproval/', recurring.oauth_token, {
          preapproval_id: recurring.id
      })
    end
  
    def cancel
      validates_presence_of :id

      call('/preapproval/cancel', @oauth_token, {
        preapproval_id: @id
      })
    end
  end

  class Withdrawal < Base
  
    validates_presence_of :oauth_token, :account_id, :redirect_uri
   
    def self.create(options)
      withdrawal = self.new(options)
  
      withdrawal.call('/withdrawal/create', withdrawal.oauth_token, {
        account_id: withdrawal.account_id,
        redirect_uri: withdrawal.redirect_uri,
        mode: 'iframe'
      })
    end
  end
end
