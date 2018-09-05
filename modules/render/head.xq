xquery version "3.1";
(:~
:
@author 
@version 
@see 
:)

declare namespace xi="http://www.w3.org/2001/XInclude";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:indent "yes";

let $title := request:get-parameter('title',())
return
<head>
 <meta content="text/html; charset=utf-8" http-equiv="content-type" />
 <meta http-equiv="X-UA-Compatible" content="IE=edge" />
 <title>{$title}</title>
 <meta name="viewport" content="width=device-width, initial-scale=1" />
 <link href="/styles" rel="Stylesheet" type="text/css" />
 <link rel="authorization_endpoint" href="https://indieauth.com/auth" />
 <link rel="token_endpoint" href="https://tokens.indieauth.com/token" />
 <link rel="micropub" href="https://gmack.nz/micropub" />
</head>
