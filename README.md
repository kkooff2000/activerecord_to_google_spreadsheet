# ActiverecordToGoogleSpreadsheet

This is a rails gem which can help you dump or export models to google spreadsheet easily.

TODO: Apply to_google_spreadsheet to ARRAY

## Installation

1. Add this line to your application's Gemfile:
```sh
gem 'google_drive'
gem 'activerecord_to_google_spreadsheet'
```
2. Add file to config/initializers/activerecord_to_google_spreadsheet.rb
```sh
require 'activerecord_to_google_spreadsheet'
ActiveRecordToGoogleSpreadsheet.configure do |config|
  config.client_id = "$GOOGLE_CLIENT_ID"
  config.client_secret = "$GOOGLE_CLIENT_SECRET"
  config.redirect_uri = "$CALLBACK_URL"
end
```
And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install activerecord_to_google_spreadsheet

## Usage

Then you can use following api.
```sh
ActiveRecordToGoogleSpreadsheet.dump_to_spreadsheet(session, "$SPREADSHEET_KEY")
```
Then you can see your databases show on https://docs.google.com/spreadsheets/d/$SPREADSHEET_KEY/

You can also restore databases from google spreadsheet by following api.
```sh
ActiveRecordToGoogleSpreadsheet.restore_from_spreadsheet(session, "$SPREADSHEET_KEY")
```

Then your databases will apply data from google spreadsheet.

There are some other api like this.
```sh
Product.where('price < 50').to_google_spreadsheet(session, "$SPREADSHEET_KEY", row_offset: 10, worksheet_title: true)
```

The variable session is GoogleDrive::Session.

You can follow the following url to get GoogleDrive::Session.

https://github.com/gimite/google-drive-ruby

Or ActiveRecordToGoogleSpreadsheet provide other way to get session.
```sh
//You can use the following code to login google account to grant auth code
redirect_to ActiveRecordToGoogleSpreadsheet.google_login_url

//Then put following code to the callback url controller function
ActiveRecordToGoogleSpreadsheet.setup_session(params['code'])

//Then you can get session now.
session = ActiveRecordToGoogleSpreadsheet.get_session()
```

Good Luck.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

