require_relative './app'
require_relative './middleware/error_handle_filter'

use ErrorHandleFilter
run Mosscow.new