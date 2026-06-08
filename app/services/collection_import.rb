module CollectionImport
  module_function

  # Dispatches to the right parser and returns normalized rows.
  def parse(source_type, content, defaults = {})
    case source_type.to_s
    when "csv" then CsvParser.parse(content, defaults: defaults)
    else DecklistParser.parse(content, defaults: defaults)
    end
  end
end
