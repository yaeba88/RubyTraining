require 'error_handle_filter'

require_relative './app'
#require_relative './middleware/string_format_converter'

#use StringFormatConverter
use ErrorHandleFilter
run Mosscow.new