# frozen_string_literal: true

# ResponseFormatter - Handles formatted responses
module ResponseFormatter
  def formatted_response(response, data, status: 200)
    response['content-type'] = 'application/json'
    response.status = status
    response.write(data.to_json)
  end
end
