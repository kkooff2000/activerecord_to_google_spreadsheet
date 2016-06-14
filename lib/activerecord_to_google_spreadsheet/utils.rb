module ActiveRecordToGoogleSpreadsheet
  module Utils
    def get_worksheet_by_name(st, name)
      ws = st.worksheet_by_title(name)
      if !ws
        ws = st.add_worksheet(name)
      end
      return ws
    end
  end
end
