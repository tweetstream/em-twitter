require 'spec_helper'

describe 'EM::Twitter::Client error handling' do
  error_callback_invoked('unauthorized', 401, 'Unauthorized')
  error_callback_invoked('forbidden', 403, 'Forbidden')
  error_callback_invoked('not_found', 404, 'Not Found')
  error_callback_invoked('not_acceptable', 406, 'Not Acceptable')
  error_callback_invoked('too_long', 413, 'Too Long')
  error_callback_invoked('range_unacceptable', 416, 'Range Unacceptable')
  error_callback_invoked('enhance_your_calm', 420, 'Enhance Your Calm')
  error_callback_invoked('error', 500, 'Internal Server Error', 'An error occurred.')
end