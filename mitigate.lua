

-- Load shared config
local config = ngx.shared.config
local whitelist = ngx.shared.whitelist


local M = {} 

M.challenge_html_template = [[
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Just a moment please...</title>
    <meta name="description" content="">
    <meta name="robots" content="noindex, nofollow" />
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="https://fonts.googleapis.com/css?family=Roboto:100,300" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">

    <style>
        html, body {
            background: #212121;
            color: #FAFAFA;
            margin-top: 100px;
            font-family: 'Roboto';
        }

        img.brand {
            display: block;
            opacity: .95;
            max-height: 85px;
            margin: 0 auto;
            opacity: .80;
        }

        h1.message {
            text-align: center;
            margin-top: 45px;
            font-weight: 100;
            font-size: 20px;
            text-transform: uppercase;
            opacity: .9;
            color: #E0E0E0;
            line-height: 30px;
        }
        h1.message a:link {
            text-decoration: none;
            color: #E0E0E0;
            font-weight: 300;
        }

        span.loading {
            text-align: center;
            display: block;
            font-size: 45px;
            margin-top: 45px;
            color: rgba(250, 250, 250, 0.5);
        }
    </style>
</head>
<body>

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>

    <div class="container">
        <div class="row">
            
            <div class="col-sm-12">
                <span class="loading">
                    <h1 class="message" style="color: #E0E0E0">Checking your browser. Please wait...</h1>
                </span>
            </div>
            
        </div>
    </div>

    <script>
        function load()
        {
            setTimeout(function()
            {
                $('span.loading').fadeOut('slow').fadeIn('slow');
                load();
            }, 0);
        }

        load();
    </script>

    <script>
        //var hostname = $('<a>').prop('href', url).prop('hostname');
        //$('h1.message').text(hostname);
        //var ww = $(window).width();
    </script>


    <script type="text/javascript">
    
    var XHR = "onload"in new XMLHttpRequest ? XMLHttpRequest : XDomainRequest;
    var xhr = new XHR;

    xhr.open("GET", "/___S___/?rid=%s", true);

    xhr.onreadystatechange = function()
    {
        if(4==xhr.readyState&&(xhr.status==200))
        {
            var t = document.createElement("script");
            t.type = "text/javascript", t.text = xhr.responseText, document.body.appendChild(t)
            //window.location.reload();
        }
    };
    
    xhr.send(null);

    function wait(){}; 

    setTimeout(wait(), 4000);

    </script>
</body>
</html>
]]


-- Send JavaScript challenge to client
function M.sendChallenge(client_id)

    -- TODO: Check type of request, if page or resource etc... 

    -- Send the challenge
    local challengeHTML = string.format(M.challenge_html_template, client_id)
    ngx.header["Content-type"] = "text/html"
    ngx.say(challengeHTML)

end


-- Get challenge response from client, if client has JavaScript enabled, the challenge will be passed, and client will be added to the whitelist.
function M.validateChallengeResponse(client_id)
    
    local uri_args = ngx.req.get_uri_args()
    
    if uri_args['rid'] == client_id then
        whitelist:set(client_id, true, 3600) -- if passed, we are validated for 1 hr
        --ngx.say("success") -- if we want to print "success" when passing test, we can do that here just to make it easier for us to understand when developing.
        ngx.say("window.location.reload();") -- xhr.responseText
        ngx.exit(ngx.OK)
    end

    return
end

return M
