module ActiveRecordToGoogleSpreadsheet
  module Converter
    module ActiveRecordBaseConverter
      include Utils
      extend Utils

      def to_google_spreadsheet(session, spreadsheet_key, name: self.model_name.name, worksheet_title: false, row_offset: 1)

        clazz = self.model_name.name.capitalize.singularize.camelize.to_s.constantize
        spreadsheet = session.spreadsheet_by_key(spreadsheet_key)
        ws = get_worksheet_by_name(spreadsheet, name)

        clazz.column_names.each_with_index.each do |name, column_index|
          if worksheet_title
            ws[row_offset, column_index+1] = name
            ws[row_offset + 1, column_index + 1] = self[name]
          else
            ws[row_offset, column_index + 1] = self[name]
          end

        end
        ws.save
        ws.reload
      end

      def from_google_spreadsheet
      end
    end

    module ActiveRecordRelationConverter
      include Utils
      extend Utils

      def to_google_spreadsheet(session, spreadsheet_key, name: self.table_name, worksheet_title: false, row_offset: 1)
        spreadsheet = session.spreadsheet_by_key(spreadsheet_key)
        ws = get_worksheet_by_name(spreadsheet, name)

        if worksheet_title
          self.column_names.each_with_index do |name, column_index|
            ws[row_offset, column_index+1] = name
          end
          row_offset += 1
        end

        self.each_with_index do |item, index|
          self.column_names.each_with_index do |name, column_index|
            ws[index + row_offset, column_index + 1] = item[name]
          end
        end
        ws.save
        ws.reload
      end

      def from_google_spreadsheet
      end
    end

    module ArrayConverter
      include Utils
      extend Utils

      def to_google_spreadsheet(session, spreadsheet_key, name, worksheet_title: false, row_offset: 1)
        if self.length > 0
          spreadsheet = session.spreadsheet_by_key(spreadsheet_key)
          ws = get_worksheet_by_name(spreadsheet, name)

          self.each_with_index do |item, index|
            if index == 0 && item.is_a?(ActiveRecord::Base) && worksheet_title
              item.to_google_spreadsheet(session, spreadsheet_key, name: name, worksheet_title:  true, row_offset: row_offset + index)
              row_offset += 1
            elsif item.is_a? ActiveRecord::Base
              item.to_google_spreadsheet(session, spreadsheet_key, name: name, row_offset: row_offset + index)
            elsif item.is_a? Array
              item.each_with_index do |array_item, array_index|
                ws[index + row_offset, array_index + 1] = item[name] = array_item
              end

            else
              ws[index + row_offset, 1] = val
            end
          end
        end

      end
    end
  end
end
