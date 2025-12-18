return {
  s("prerequest-script", fmt([=[
    ### pre-request script with variable local to next call
    # @lang=lua
    < {%
    -- Function to read from an external Linux process
    function getExternalData()
        local handle = io.popen("gopass show -o dt/bitbucket.lab.dynatrace.org/tokens/http-access-token-admin")
        local result = handle:read("*a")
        handle:close()
        return result
    end
    
    -- Use the function to get data
    local client_secret = getExternalData()
    %}
    GET https://someresource
    Authorization {{client_secret}}
  ]=], {}, { delimiters = "[]" })),

  s("postrequest-script", fmt([=[
    ### post-request script
    GET https://someresource
    > {%
    local body = vim.json.decode(response.body)
    client.global.set("post_id", body.id)
    %}

    GET https://someresource/{{post_id}}
  ]=], {}, { delimiters = "[]" })),

  s("oauth2-client-credentials-flow", fmt([=[
    ### Client Credentials Flow https://datatracker.ietf.org/doc/html/rfc6749#section-4.4
    ### Use Client ID and Client Secret to Acquire AccessToken from Authorization Server
    # Provide the following parameters in the request body. Be sure to URL-encode all values!
    # grant_type
    # client_id
    # client_secret
    # scope : OPTIONAL Defines requested permissions assigned/to-be-assigned-to access token
    # resource : Specifies the target resource or account context for which the token is valid.
    # @lang=lua
    < {%
    -- Use the anonymous function for one-liner to properly close handle
    local client_secret = (function(h) local r=h:read("*a"); h:close(); return r end)(io.popen("gopass show -o /path/to/client_secret"))
    %}
    @client_id = YOUR_CLIENT_ID
    @scope = YOUR_WHITESPACE_DELIMITED_SCOPES
    @resouce = YOUR_URN
    POST /token HTTP/1.1
    Host: https://authorizationserver
    Content-Type: application/x-www-form-urlencoded

    grant_type=client_credentials&
    client_id={{client_id}}&
    client_secret={{client_secret}}&
    scope={{scopes}}&
    resource={{resource}}

    > {%
    local body = vim.json.decode(response.body)
    client.global.set("access_token", body.access_token)
    client.global.set("access_token_type", body.token_type)
    %}

    ### Use Access Token to access protected Resource
    GET /protected/resource
    Host: https://dummy.invaliddomain
    Authorization: {{access_token_type}} {{access_token}}
  ]=], {}, {delimiters="[]"}))
}
