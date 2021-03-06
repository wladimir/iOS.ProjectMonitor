class ParseClient
  attr_reader :application_id, :master_key

  def self.from_settings
    new(Settings.parse_application_id, Settings.parse_master_key)
  end

  def initialize(application_id, master_key)
    @application_id = application_id
    @master_key = master_key
  end

  def fetch_builds
    response = HTTParty.get(builds_url, headers: headers, query: "order=updatedAt&limit=500")
    validate_response response
    response['results'].map { |value| ParseBuild.new value }
  end

  def update(build)
    raise ArgumentError, "Must have objectId" unless build.objectId.present?
    url = File.join(builds_url, build.objectId)
    response = HTTParty.put(url, headers: headers, body: build.output.to_json)
    validate_response response
  end

  def create(build)
    response = HTTParty.post(builds_url, { headers: headers, body: build.output.to_json })
    validate_response response

    build.objectId = response["objectId"]
    build.createdAt = response["createdAt"]
    build
  end

  def notify_build_failed(build)
    raise ArgumentError, "Must have user" unless build.user.present?

    output = {
      "where" => {"user" => build.user},
      "data" => { "alert" => build.failure_description }
    }

    puts "notifying failure: #{output.to_json}"
    response = HTTParty.post(push_url, { headers: headers, body: output.to_json })
    validate_response response
  end

  private

  def headers
    {
      'X-Parse-Application-Id' => Settings.parse_application_id,
      'X-Parse-Master-Key' => Settings.parse_master_key,
      'Content-Type' => 'application/json'
    }
  end

  def builds_url
    'https://api.parse.com/1/classes/Build'
  end

  def push_url
    'https://api.parse.com/1/push'
  end

  def validate_response(response)
    if response.code >= 300
      raise StandardError, "Error connecting to parse. Status: #{response.code} Message: #{response.message} #{response}"
    else
      response
    end
  end
end
