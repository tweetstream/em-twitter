require 'spec_helper'

describe "EM::Twitter::Connection error handling" do
  error_callback_invoked('on_unauthorized', 401, 'Unauthorized')
  error_callback_invoked('on_forbidden', 403, 'Forbidden')
  error_callback_invoked('on_not_found', 404, 'Not Found')
  error_callback_invoked('on_not_acceptable', 406, 'Not Acceptable')
  error_callback_invoked('on_too_long', 413, 'Too Long')
  error_callback_invoked('on_range_unacceptable', 416, 'Range Unacceptable')
  error_callback_invoked('on_enhance_your_calm', 420, 'Enhance Your Calm')
  error_callback_invoked('on_error', 500, 'Internal Server Error', 'An error occurred.')
  error_callback_invoked('on_service_unavailable', 503, 'Service Unavailable')
end
