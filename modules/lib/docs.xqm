xquery version "3.1";
(:~
: triggers for the docs collection
@author  Grant Mackenzie
@version 0.0.1
@see http://localhost:8080/exist/apps/doc/triggers
:)

module namespace trigger="http://exist-db.org/xquery/trigger";


declare
function trigger:after-create-document($uri as xs:anyURI) {
    util:log-system-out( 'EVENT:  after-create-document  [ ' ||  $uri || ' ]'  )
};


declare
function trigger:after-update-document($uri as xs:anyURI) {
    util:log-system-out( 'EVENT:  after-update-document [ ' ||  $uri || ' ]'  )
};


declare
function trigger:after-move-document($new-uri as xs:anyURI, $uri as xs:anyURI) {
    util:log-system-out( 'EVENT:  after-move-document  [ from ' ||  $uri || ' to ' || $new-uri || ' ]'  )
};

declare function trigger:after-delete-document($uri as xs:anyURI) {
    util:log-system-out( 'EVENT:  after-delete-document [ ' ||  $uri || ' ]'  )
};
