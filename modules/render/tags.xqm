xquery version "3.1";
(:~
:
@author 
@version 
@see 
:)

module namespace tags="http://markup.nz/#tags";


declare
function tags:getKindOfPost( $id ) {
   switch( substring( $id,1,1) )
      case 'n' return 'note'
      case 'r' return 'reply'
      case 'a' return 'article'
      case 'p' return 'photo'
      default return 'note'
};

declare
function tags:head( $title, $myPhoto, $mpEndpoint ) {
element head {
  element meta { attribute charset { 'utf-8' }},
  element title { $title },
  element meta {
    attribute name { 'viewport' },
    attribute content { 'width=device-width, initial-scale=1' }
    },
  element link {
    attribute href { '/styles' },
    attribute rel { 'Stylesheet' },
    attribute type { 'text/css' }
    },
  element link {
    attribute href { '/icons/compose' },
    attribute rel { 'icon' },
    attribute type { 'image/svg+xml' }
    },
  element link {
    attribute href { $myPhoto } ,
    attribute rel { 'apple-touch-icon' }
    },
  element link {
    attribute href { 'https://indieauth.com/auth' },
    attribute rel { 'authorization_endpoint' }
    },
  element link {
    attribute href { 'https://tokens.indieauth.com/token' },
    attribute rel { 'token_endpoint' }
    },
  element link {
    attribute href { $mpEndpoint },
    attribute rel { 'micropub' }
    }
  }
};

declare
function tags:header( $map  as map(*) ) {
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
function tags:content( $map  as map(*)) {
let $filter := xmldb:xcollection($map('data-posts'))/entry[category =  $map('tag')]
return
 element main {
    attribute id {'tagged-entries'},
      element h2 {
       count($filter) || ' tagged as ' || $map('tag')
      },
    for $entry at $i in $filter
        order by xs:dateTime($entry/published) descending
        let $kindOfPost := tags:getKindOfPost( $entry/uid/string() )
        return
        element article {
                attribute class {'h-entry '  || $kindOfPost },
                element a {
                  attribute class {'u-url'},
                  attribute href {$entry/url/string()},
                  attribute rel {'bookmark'},
                  attribute title {'published ' || $kindOfPost },
                  element img {
                    attribute width {'16'},
                    attribute height {'16'},
                    attribute alt { $kindOfPost },
                    attribute src { '/icons/' || $kindOfPost }
                    },
                  element time {
                    attribute class { 'dt-published' },
                    attribute datetime { $entry/published/string() },
                    format-dateTime(xs:dateTime($entry/published/string()) , "[D1o] of [MNn] [Y]", "en", (), ())
                    }
                  },
                  switch ( $kindOfPost )
                  case "note" return
                              element p {
                              attribute class { 'e-content' },
                              $entry/content/value/string() }
                  case "article" return ()
                  default    return ()
                }

    }
};


declare
function tags:tags( $node as node()) {
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
function tags:footer( $map  as map(*) ) {
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
        attribute href {'/'},
        attribute title {'author'},
        attribute class {'h-card p-name'},
        $map('card-name')
        }
    }
 };

declare
function tags:render( $map as map(*)) {
  let $title :=  'tag: ' || $map('tag')
  let $myPhoto := $map('card-photo')
  let $mpEndpoint := $map('micropub-endpoint')
  return
  element html {
    tags:head( $title,$myPhoto, $mpEndpoint ),
    element body {
      tags:header( $map ),
      tags:content( $map),
      tags:footer( $map )
      }
    }
};


