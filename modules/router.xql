xquery version "3.1";
(:~      main app routes
@author  Grant MacKenzie
@version 0.1

this app is proxied behind openresty/nginx
the data for the app is separate from the app

-------------------------------------------

GET routes deliver a hyperlinked website

website:
 - render docs in named collections -  pages
 - render docs in date archive      -  posts
 -

 pages/home/index.html - home-page
 pages/about/index.html  about-page
 pages/tags/index.html   list named tags
 pages/tags/{tag-name}   list entries tagged as

 posts/{ID}.html         a dated entry
 posts/latest            latest dated entries
 posts/2016/10/01        this days entries
 posts/2016/10           this months entries
 posts/2016              this years entries
 posts/                  all posts

-------------------------------------------
:)

module namespace router = "http://gmack.nz/#router";
import module namespace system="http://exist-db.org/xquery/system";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace map="http://www.w3.org/2005/xpath-functions/map";
import module namespace req="http://exquery.org/ns/request";

import module namespace qt="http://markup.nz/#qt" at "lib/qt.xqm";
import module namespace feed="http://markup.nz/#feed" at "render/feed.xqm";
import module namespace note="http://markup.nz/#note" at "render/note.xqm";
import module namespace tags="http://markup.nz/#tags" at "render/tags.xqm";
import module namespace unavailable="http://markup.nz/#unavailable" at "render/unavailable.xqm";

declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace pkg="http://expath.org/ns/pkg";
declare namespace rest="http://exquery.org/ns/restxq";
declare namespace http="http://expath.org/ns/http-client";
declare namespace xi="http://www.w3.org/2001/XInclude";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html5";
declare option output:html-version "5";
declare option output:media-type "text/html";
declare option output:indent "yes";

(:Determine the application base from the current module load path :)
declare variable $router:base :=
 substring-before( system:get-module-load-path(), '/modules');

declare variable $router:domain :=
  substring-after( $router:base, repo:get-root() );

declare variable $router:root := substring-before( $router:base,'/apps/');
declare variable $router:dPath  := $router:root    || '/data/' || $router:domain;
declare variable $router:dDocs  := $router:dPath   || '/docs';
declare variable $router:dRecyle  := $router:dPath || '/docs/recycle';
declare variable $router:dPosts := $router:dPath   || '/docs/posts';
declare variable $router:dPages := $router:dPath   || '/docs/pages';
declare variable $router:dUploads := $router:dPath || '/docs/uploads';
declare variable $router:dMentions := $router:dPath || '/docs/mentions';
declare variable $router:dMedia := $router:dPath   || '/media';
declare variable $router:docRepo  := doc($router:base ||  "/repo.xml");
declare variable $router:docPkg   := doc($router:base ||  "/expath-pkg.xml");

declare variable $router:rPath  := "http://ex:8080/exist/rest/db/apps/" || $router:domain;
declare variable $router:renderPath  := $router:rPath || '/modules/render';

declare variable $router:nl := "&#10;";

declare variable $router:wmValue :=
 "&lt;https://" || $router:domain || "/webmention&gt; rel='webmention'";

declare variable $router:wmLink :=
 <http:header name="Link" value="{$router:wmValue}"/>;

declare variable $router:myCard := map {
  "type": "card",
  "name": "Grant MacKenzie",
  "photo": concat('https://', $router:domain, '/images/180/me' ),
  "url": concat('https://', $router:domain ),
  "uuid": concat('https://', $router:domain ),
  "email": 'grantmacken@gmail.com',
  "street-address": '8 Featon Ave',
  "locality": 'Awhitu',
  "country-name": 'New Zealand',
  "note": 'My URL therefore I am'
  };

declare variable $router:myProfiles :=  [
  map { 'url': 'https://twitter.com/grantmacken', 'name': 'grantmacken', 'icon': '/icons/twitter' } ,
  map { 'url': 'https://github.com/grantmacken', 'name': 'grantmacken', 'icon': '/icons/github'} ,
  map { 'url': 'https://plus.google.com/+GrantMacKenzieAwhitu/about', 'name': 'grantmacken', 'icon': '/icons/gplus' }
  ];

declare variable $router:pkg :=   map {
  'pkg-title':  $router:docPkg//pkg:title/string(),
  'pkg-version': $router:docPkg/pkg:package/@version/string()
};

declare variable $router:repo :=   map {
  'repo-author': $router:docRepo//repo:author/string(),
  'repo-description': $router:docRepo//repo:description/string(),
  'repo-website': $router:docRepo//repo:website/string()
};

declare variable $router:default :=   map {
  'domain': $router:domain,
  'micropub-endpoint': concat('https://',$router:domain,'/micropub')
};

declare variable $router:map := map {
  'data-media': $router:dMedia,
  'data-mentions': $router:dMentions,
  'data-pages': $router:dPages,
  'data-posts': $router:dPosts,
  'card': $router:myCard,
  'profiles': $router:myProfiles,
  'micropub-endpoint': concat('https://',$router:domain,'/micropub') ,
  'domain': $router:domain,
  'pkg-title':  $router:pkg('pkg-title'),
  'pkg-version': $router:pkg('pkg-version'),
  'repo-author': $router:repo('repo-author'),
  'repo-description': $router:repo('repo-description'),
  'repo-website': $router:repo('repo-website'),
  'card-name': $router:myCard('name'),
  'card-photo': $router:myCard('photo')
};

declare variable $router:error := map {
'notFound' := QName( 'http://gmack.nz/#router','documentNotAvailable'),
'wmError'  : QName( 'http://gmack.nz/#router','webmentionError')
};

(:
<http:header name="Link" value="&lt;https://gmack.nz/webmention&gt; rel='webmention'"/>
<http:header name="Link" value="&lt;https://gmack.nz/webmention&gt; rel='webmention'"/>
:)

declare
    %rest:GET
    %rest:path( "/gmack.nz/pages/home.html")
    %output:media-type("text/html")
    %output:method("html")
function router:home() {
  try {
  let $dataMap := map { 'kind': 'feed', 'card': $router:myCard, 'profiles': $router:myProfiles  }
  let $map := map:new(( $router:map, $dataMap ))
  return (
      <rest:response>
        <http:response status="200" message="OK">
        {(
        $router:wmLink
        )}
        </http:response>
      </rest:response>,
       feed:render( $map )
        )
 }
  catch * {(
  <rest:response>
    <http:response status="200" message="OK">
    </http:response>
  </rest:response>,
  <div>
    <h1> TODO! </h1>
    <p>error code - {$err:code}</p>
    <p>error description - {$err:description}</p>
    <p>error line number- {$err:line-number}</p>
    <p>error module - {$err:module}</p>
  </div>
    )}
};

declare
    %rest:GET
    %rest:path("/gmack.nz/posts/{$id}")
    %output:media-type("text/html")
    %output:method("html5")
function router:posts($id as xs:string) {
  try {
  let $uid := substring-before($id,'.')
  let $log :=  util:log('INFO', ' test log')
  let $kindOfPost :=
   switch( substring( $id,1,1) )
      case 'n' return 'note'
      case 'r' return 'reply'
      case 'a' return 'article'
      case 'p' return 'photo'
      default return 'note'
  let $docsPath := $router:dPosts || '/' || $uid
  let $data :=
      if (doc-available($docsPath)) then (doc($docsPath)) else (
        fn:error($router:error('notFound'), $docsPath || ' :  data doc not available on path' )
       )
  let $dataMap := map {
    'kind' := $kindOfPost
    }
  let $map := map:new(( $router:map, $dataMap ))
  return (
      <rest:response>
        <http:response status="200" message="OK">
        {$router:wmLink}
        </http:response>
      </rest:response>,
        switch ( $kindOfPost )
          case "note" return note:render( $map, $data )
          case "article" return ()
          default    return ()
          )
    }
  catch * {
    if ( xs:string($err:code) eq 'router:documentNotAvailable' ) then (
        <rest:response>
        <http:response status="404"/>
        </rest:response>,
         unavailable:render( map:new(( $router:map, map {
            'id' := substring-before($id, '.html'),
            'module' := $err:module,
            'code' := $err:code,
            'line-number' := $err:line-number,
            'description' := $err:description
            } )))
        )
    else
    (
     <rest:response>
     <http:response status="404"/>
     </rest:response>,
     <div>
     <h1> TODO! </h1>
     <p>{$id}</p>
     <p>error code - {$err:code}</p>
     <p>error description - {$err:description}</p>
     <p>error line number- {$err:line-number}</p>
     <p>error module - {$err:module}</p>
     </div>
    )
  }
 };


declare
    %rest:GET
    %rest:path("/gmack.nz/tags/{$tag}")
    %output:media-type("text/html")
    %output:method("html5")
function router:tags($tag as xs:string) {
  try {
 let $dataMap := map {
    'tag' := substring-before($tag,'.')
    }
  let $map := map:new(( $router:map, $dataMap ))
  return (
      <rest:response>
        <http:response status="200" message="OK">
        {$router:wmLink}
        </http:response>
      </rest:response>,
         tags:render( $map )
         )
    }
  catch * {
    if ( xs:string($err:code) eq 'router:documentNotAvailable' ) then (
        <rest:response>
        <http:response status="404"/>
        </rest:response>,
         unavailable:render( map:new(( $router:map, map {
            'id' := substring-before($tag, '.html'),
            'module' := $err:module,
            'code' := $err:code,
            'line-number' := $err:line-number,
            'description' := $err:description
            } )))
        )
    else
    (
     <rest:response>
     <http:response status="404"/>
     </rest:response>,
     <div>
     <h1> TODO! </h1>
     <p>{$tag}</p>
     <p>error code - {$err:code}</p>
     <p>error description - {$err:description}</p>
     <p>error line number- {$err:line-number}</p>
     <p>error module - {$err:module}</p>
     </div>
    )
  }
 };


