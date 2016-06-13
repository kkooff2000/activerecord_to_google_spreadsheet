require "activerecord_to_google_spreadsheet/version"
require "google_drive"
module ActiveRecordToGoogleSpreadsheet
  def self.get_db_info()
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

  def self.get_worksheet_by_name(st, name)
    ws = st.worksheet_by_title(name)
    if !ws
      ws = st.add_worksheet(name)
    end
    return ws
  end

  def self.to_spreadsheet(session, spreadsheet_key)
    info = get_db_info

    st = session.spreadsheet_by_key(spreadsheet_key)

    start_time = Time.now
    info.each do |name, value|

      ws = get_worksheet_by_name(st, name)
      clazz = name.capitalize.singularize.camelize.to_s.constantize

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
    puts '*************************'
    puts Time.now - start_time
    puts '*************************'
  end

  def self.from_spreadsheet(session, spreadsheet_key)
    st = session.spreadsheet_by_key(spreadsheet_key)
    info = get_db_info
    start_time = Time.now
    info.each do |name, value|
      ws = get_worksheet_by_name(st, name)

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
    puts '*************************'
    puts Time.now - start_time
    puts '*************************'
  end

  def self.get_session(code)
    if $session
      return $session
    end
    auth = get_auth()
    auth.code = code
    auth.fetch_access_token!
    $session = GoogleDrive.login_with_oauth(auth.access_token)
    return $session
  end

  def self.get_auth
    client = Google::APIClient.new
    auth = client.authorization
    auth.client_id = "1079217375076-8nksnj4drtu77ni3rfrm9a7cv9pns7db.apps.googleusercontent.com"
    auth.client_secret = "_j52ipkBFLzBdJT7bLljm9ub"
    auth.scope =
      "https://www.googleapis.com/auth/drive " +
      "https://spreadsheets.google.com/feeds/"
    auth.redirect_uri = "http://127.0.0.1:3000/google/write"
    return auth
  end

  def self.google_login_url
    auth = get_auth()
    auth_url = auth.authorization_uri
    return auth_url.to_s
  end
end
