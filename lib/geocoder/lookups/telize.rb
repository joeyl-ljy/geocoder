require 'geocoder/lookups/base'
require 'geocoder/results/telize'

module Geocoder::Lookup
  class Telize < Base

    def name
      "Telize"
    end

    def required_api_key_parts
      configuration[:host] ? [] : ["key"]
    end

    def query_url(query)
      if configuration[:host]
        "#{protocol}://#{configuration[:host]}/location/#{query.sanitized_text}"
      else
        "#{protocol}://telize-v1.p.mashape.com/location/#{query.sanitized_text}?mashape-key=#{api_key}"
      end
    end

    def supported_protocols
      [].tap do |array|
        array << :https
        array << :http if configuration[:host]
      end
    end

    private # ---------------------------------------------------------------

    def results(query)
      # don't look up a loopback address, just return the stored result
      return [reserved_result(query.text)] if query.loopback_ip_address?
      if (doc = fetch_data(query)).nil? or doc['code'] == 401 or empty_result?(doc)
        []
      else
        [doc]
      end
    end

    def empty_result?(doc)
      !doc.is_a?(Hash) or doc.keys == ["ip"]
    end

    def reserved_result(ip)
      {
        "ip" => ip,
        "latitude" => 0,
        "longitude" => 0,
        "city" => "",
        "timezone" => "",
        "asn" => 0,
        "region" => "",
        "offset" => 0,
        "organization" => "",
        "country_code" => "",
        "country_code3" => "",
        "postal_code" => "",
        "continent_code" => "",
        "country" => "",
        "region_code" => ""
      }
    end

    def api_key
      configuration.api_key
    end

  end
end
