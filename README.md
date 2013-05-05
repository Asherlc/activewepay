# Activewepay

Access the WePay like ActiveModel/ActiveRecord objects.

## Installation

Add this line to your application's Gemfile:

    gem 'activewepay'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activewepay

## Usage

Access a WePay object by calling something like `ActiveWepay::Checkout.create` or `ActiveWepay::Checkout.find(<checkout id>)`

### Setup:

Once instantiated, an object can have useful methods called on it, depending on the object type. Example:

    checkout = ActiveWepay::Checkout.create({
       oauth_token: <oauth token>,
       account_id: <account id>,
       amount: <amount>,
       redirect_uri: <redirect uri>,
       callback_uri: <callback uri>
    })
    checkout.refund


    preapproval = ActiveWepay::Preapproval.create
    preapproval.cancel

You can also access the returned properties on the object:

    checkout.amount
    checkout.id

    preapproval.preapproval_uri
    
If there's an error in the call, you can call them like you would any ActiveModel object:

    checkout.errors.any?
    checkout.errors.full_messages

The gem automatically switches between stage and production domains based on the Rails environment.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
