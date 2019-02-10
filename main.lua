

-- Load shared config 
local config = ngx.shared.config
local whitelist = ngx.shared.whitelist

local VALIDATE_URI = config:get("js_validate_uri")


-- Require the mitigation functions from mitigate.lua
local mitigate = require("mitigate")


-- Get request headers
local headers = ngx.req.get_headers();


-- Generate a client id to use
-- TODO: Add more here... Window width etc...
local CLIENT_ID = ngx.md5(ngx.var.remote_addr)


-- Validation
if ngx.var.uri == VALIDATE_URI then -- if validation URI is requested
    if not whitelist:get(CLIENT_ID) then -- and if client is not whitelisted / has not passed the test
        mitigate.validateChallengeResponse(CLIENT_ID) -- then we check the response of the JavaScript challenge and add to whitelist if pass
        return
    end

    -- To prevent people bruteforcing our validation process, return a blank page...
    ngx.exit(ngx.OK)

end


-- Challenge
if not whitelist:get(CLIENT_ID) then -- Check all other requests, and send challenge if client is not whitelisted / has not passed test
    mitigate.sendChallenge(CLIENT_ID)
    return
end

