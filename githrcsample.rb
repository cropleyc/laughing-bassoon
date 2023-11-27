#Cayuse HR Connect is an API that allows you to sync the following common admin data:

# People and Users
# Org Units
# Internal Associations
# External organizations (sponsors)
# Role Assignments

# Authentication request
auth_url = URI("https://signin.<environment>.cayuse.com/api/v2/authenticate")
auth_https = Net::HTTP.new(auth_url.host, auth_url.port)
auth_https.use_ssl = true

auth_request = Net::HTTP::Post.new(auth_url)
auth_request["Content-Type"] = "application/json"
auth_request.body = '{"username":"my_username","password":"my_password"}'

auth_response = auth_https.request(auth_request)
auth_body = JSON.parse(auth_response.body)

# Store the token value in a variable
token = auth_body["token"]

# Upload request
upload_url = URI("https://signin.<environment>.cayuse.com/api/v2/administration/batch/upload/user?send_account_activation_emails=false")

upload_https = Net::HTTP.new(upload_url.host, upload_url.port)
upload_https.use_ssl = true

upload_request = Net::HTTP::Post.new(upload_url)
upload_request["Content-Type"] = "text/csv"
upload_request["Authorization"] = "Bearer #{token}" # Use the token variable here

# People file for upload to Cayuse HR Connect API
# upload_request.body = "<file contents here>"
upload_request.body = "People.csv"


upload_response = upload_https.request(upload_request)
puts upload_response.read_body


# Role access for upload to Cayuse HR Connect API
# upload_request.body = "<file contents here>"

url = URI("https://signin.<environment>.cayuse.com/api/v2/administration/batch/upload/role")

request = Net::HTTP::Post.new(url)
request["Content-Type"] = "text/csv"
request["Authorization"] = "Bearer #{token}" # Use the token variable here 
request.body = "RA.csv"

response = https.request(request)
puts response.read_body


# Affiliation for upload to Cayuse HR Connect API
# upload_request.body = "<file contents here>"

url = URI("https://oregon-state.app.cayuse.com/api/v2/administration/batch/upload/affiliation")

request = Net::HTTP::Post.new(url)
request["Content-Type"] = "text/csv"
request["Authorization"] = "Bearer #{token}" # Use the token variable here 
# request.body = "<file contents here>"
request.body = "IA.csv"

response = https.request(request)
puts response.read_body
