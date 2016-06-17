require "activerecord_to_google_spreadsheet/version"
require "activerecord_to_google_spreadsheet/utils"
require "activerecord_to_google_spreadsheet/converter"
require "google_drive"
module ActiveRecordToGoogleSpreadsheet
  extend Utils

  class << self
    attr_accessor :configuration
  end

  class Configuration
    attr_accessor :client_id, :client_secret, :redirect_uri

    def initialize

    end
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield self.configuration
  end

  def self.get_db_info
    info = {}
    i = 1
    ActiveRecord::Base.connection.tables.map do |model|
      if i == 1
        i += 1
        next
      end
      clazz = model.capitalize.singularize.camelize.to_s.constantize
      info[model.capitalize.singularize.camelize.to_s] = clazz.column_names
      i += 1
    end
    return info
  end

  def self.dump_to_spreadsheet(session, spreadsheet_key)
    self.each_tables(session, spreadsheet_key) do |name, value, ws, clazz, info|

      info[name].each_with_index do |val, index|
        ws[1, index+1] = val
      end

      clazz.all.each_with_index do |val, index|
        clazz.column_names.each_with_index do |col, i|
          ws[index+2, i+1] = val[col]
        end
      end
      ws.save
      ws.reload
    end
  end

  def self.restore_from_spreadsheet(session, spreadsheet_key)
    self.each_tables(session, spreadsheet_key) do |name, value, ws, clazz, info|
      clazz = name.capitalize.singularize.camelize.to_s.constantize

      (2..ws.num_rows).each do |row|
        c = clazz.find_by_id(ws[row, 1])
        clazz.column_names.each_with_index do |col, i|
          if col == 'id' || col == 'created_at' || col == 'updated_at'
            next
          end
          c[col] = ws[row, i+1]
        end
        c.save
      end
    end
  end

  def self.setup_session(code)
    if $session
      return $session
    end
    auth = get_auth
    auth.code = code
    auth.fetch_access_token!
    $session = GoogleDrive.login_with_oauth(auth.access_token)
    return $session
  end

  def self.get_session
    if $session
      return $session
    else
      raise GetSessionException
    end
  end

  class GetSessionException < Exception
    def message
      "call setup_session(code) before get_session"
    end
  end

  def self.get_auth
    client = Google::APIClient.new
    auth = client.authorization
    auth.client_id =  self.configuration.client_id
    auth.client_secret = self.configuration.client_secret
    auth.scope =
      "https://www.googleapis.com/auth/drive " +
      "https://spreadsheets.google.com/feeds/"
    auth.redirect_uri = self.configuration.redirect_uri
    return auth
  end

  def self.google_login_url
    auth = get_auth
    auth_url = auth.authorization_uri
    return auth_url.to_s
  end

  class ActiveRecord::Base
    include Converter::ActiveRecordBaseConverter
  end

  class ActiveRecord::Relation
    include Converter::ActiveRecordRelationConverter
  end

#  class Array
#    include Converter::ArrayConverter
#  end

  def self.each_tables(session, spreadsheet_key)
    spreadsheet = session.spreadsheet_by_key(spreadsheet_key)
    info = get_db_info
    start_time = Time.now
    info.each do |name, value|
      worksheet = get_worksheet_by_name(spreadsheet, name)
      clazz = name.capitalize.singularize.camelize.to_s.constantize
      yield(name, value, worksheet, clazz, info)
    end
    puts '*************************'
    puts Time.now - start_time
    puts '*************************'
  end
end
