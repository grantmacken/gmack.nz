xquery version "3.1";
(:~
:
@author Grant MacKenzie
@version 0.0.1
@see 
:)

module namespace note="http://markup.nz/#note";

declare
function note:head( $title ) {
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
};

declare
function note:header( $map  as map(*) ) {
  element header {
    attribute title { $map('repo-description') },
    attribute role  { 'banner' },
    element a {
      attribute href {'/'},
      attribute title {'home page'},
      $map('card-name')
    }
  }
};





declare
function note:content( $map  as map(*), $node as node()) {
 element article {
  attribute class {'h-entry '  || $map('kind') },
  element a {
    attribute class {'u-url'},
    attribute href {$node/entry/url/string()},
    attribute rel {'bookmark'},
    attribute title {'published ' || $map('kind') },
    element img {
      attribute width {'16'},
      attribute height {'16'},
      attribute alt { $map('kind')},
      attribute src { '/icons/' || $map('kind') }
      },
    element time {
      attribute class { 'dt-published' },
      attribute datetime { $node/entry/published/string() },
        format-dateTime(xs:dateTime($node/entry/published/string()) , "[D1o] of [MNn] [Y]", "en", (), ())
      }
    },
     element p {
      attribute class { 'e-content' },
      $node/entry/content/value/string() 
      }
  }

};


declare
function note:tags( $node as node()) {
 if ( $node/entry/category ) then (
  element small {'tags  [ ' || count($node/entry/category) || ' ]&#10;'},
  element ul {
    attribute class {'vertical_list'},
    for-each(  $node/entry/category  , function($a) {
      element li { 
        element a {
          attribute href { concat('/tags/', $a) }
          , $a }
          }
      })
    }
  )
 else ()
};





declare
function note:footer( $map  as map(*) ) {
   element footer {
    attribute title { 'page footer' },
    attribute role  { 'contentinfo' },
    element a {
      attribute href {'/'},
      attribute title {'home page'},
      $map('domain')
      },
      ' is the website owned, authored and operated by ',
      element a {
        attribute href {'.'},
        attribute title {'author'},
        $map('card-name')
        }
    }
 };

declare
function note:render( $map as map(*), $node as node()) {
  let $title :=  'note ' || $node/entry/uid/string()
  return 
  element html {
    note:head( $title ),
    element body {
      note:header( $map ),
      note:content( $map, $node),
      element aside {
        note:tags( $node )},
      note:footer( $map )
      }
    }
};


