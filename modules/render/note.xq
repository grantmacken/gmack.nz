xquery version "3.1";
(:~
:
@author 
@version 
@see 
:)

declare namespace xi="http://www.w3.org/2001/XInclude";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html5";
declare option output:html-version "5";
declare option output:media-type "text/html";
declare option output:indent "yes";

declare variable $local:render  := 'http://ex:8080/exist/rest/db/apps/gmack.nz/modules/render/';

<html>
    <xi:include href="{ $local:render || 'head.xq?title=xyz'}"/>
    <body>
        <h3>It is now {current-dateTime()}</h3>
    </body>
</html>

