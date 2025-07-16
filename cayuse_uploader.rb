#!/usr/bin/env ruby

require "uri"
require "net/http"
require "json"
require "optparse"

# === Configuration ===
AUTH_URL = "https://oregon-state.app.cayuse.com/api/v2/auth/login"
ENDPOINTS = {
  people: "https://oregon-state.app.cayuse.com/api/v2/administration/batch/upload/people",
  role_assignment: "https://oregon-state.app.cayuse.com/api/v2/administration/batch/upload/role-assignment",
  affiliation: "https://oregon-state.app.cayuse.com/api/v2/administration/batch/upload/affiliation"
}

# === Authenticate and return token ===
def authenticate(username, password)
  uri = URI(AUTH_URL)
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true

  request = Net::HTTP::Post.new(uri)
  request["Content-Type"] = "application/json"
  request.body = { username: username, password: password }.to_json

  response = https.request(request)
  body = JSON.parse(response.body)

  if response.code.to_i == 200 && body["token"]
    puts "Authenticated successfully."
    body["token"]
  else
    puts "Authentication failed: #{body}"
    exit 1
  end
end

# === Upload CSV file ===
def upload_csv(endpoint, file_path, token)
  unless File.exist?(file_path)
    puts "File not found: #{file_path}"
    exit 1
  end

  uri = URI(endpoint)
  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true

  request = Net::HTTP::Post.new(uri)
  request["Content-Type"] = "text/csv"
  request["Authorization"] = "Bearer #{token}"
  request.body = File.read(file_path)

  response = https.request(request)
  puts "Upload to #{uri.path} - Response: #{response.code}"
  puts response.body
end

# === CLI Options ===
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby cayuse_uploader.rb [options]"

  opts.on("-u", "--username USERNAME", "Cayuse username") { |v| options[:username] = v }
  opts.on("-p", "--password PASSWORD", "Cayuse password") { |v| options[:password] = v }
  opts.on("-f", "--file FILE", "CSV file to upload") { |v| options[:file] = v }
  opts.on("-t", "--type TYPE", "Upload type: people, role_assignment, affiliation") { |v| options[:type] = v.to_sym }
end.parse!

# === Validate and Run ===
if options.values_at(:username, :password, :file, :type).any?(&:nil?)
  puts "Missing required arguments. Use -h for help."
  exit 1
end

endpoint = ENDPOINTS[options[:type]]
unless endpoint
  puts "Invalid upload type. Choose from: #{ENDPOINTS.keys.join(', ')}"
  exit 1
end

token = authenticate(options[:username], options[:password])
upload_csv(endpoint, options[:file], token)
