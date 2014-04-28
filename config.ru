require 'error_handle_filter'

require_relative './app/app'
require_relative './app/middleware/string_format_converter'

use StringFormatConverter
use ErrorHandleFilter
run Mosscow.new