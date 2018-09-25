xquery version "3.1";
(:~
this is the xQuery module for providing a 'feed'
view of entries posted to this site

routes: ../api/router.xqm

  archive-views: provide  date stamped landing pages
  - a feed of recent  entries   e.g.   /               last 20 entries displayed on home page
  - a feed of archived entries  e.g.   /YYYY/MM          entries for month
  - a feed of a 'type of entry' e.g.   /notes          last 40 notes
                                       /articles/2016  articles published/updated on date 

  tagged view (all posted categorised as ) /tags/[tag-name]
                                e.g.    /tags/tag       entries categorised as .. tag
  search view

https://0.gravatar.com/avatar/0650d3fbdb61ed5d8709eda6b80c3e47=180

@author Grant MacKenzie
@version 0.0.1
@see 
:)
module namespace feed="http://markup.nz/#feed";
import module namespace qt="http://markup.nz/#qt" at "../lib/qt.xqm";

declare
function feed:getKindOfPost( $id ) {
   switch( substring( $id,1,1) )
      case 'n' return 'note'
      case 'r' return 'reply'
      case 'a' return 'article'
      case 'p' return 'photo'
      default return 'note'
};

declare
function feed:head( $map as map(*)) {
element head {
  element meta { attribute charset { 'utf-8' }},
  element title { $map('kind') || ' for ' || $map('domain') },
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
    attribute href { $map('card-photo') } ,
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
    attribute href { $map('micropub-endpoint') },
    attribute rel { 'micropub' }
    }
  }
};

declare
function feed:header( $map as map(*)) {
element header {
  attribute title { $map('repo-description') },
  attribute role  { 'banner' },
  element a {
    attribute href {'.'},
    attribute title {'home page'},
    $map('card-name')
   }
  }
};

declare
function feed:sign-in-form( $map as map(*)) {
element form {
  attribute action { 'https://indielogin.com/auth' },
  attribute method  { 'get' },
  element label {
    attribute for {'url'},
    'Web Address:'
   },
  element input {
    attribute id {'url'},
    attribute type {'text'},
    attribute name {'me'},
    attribute placeholder {'https://gmack.nz'}
   },
  element p {
    element button {
      attribute type {'submit'},
      'Sign In'
    }
  },
  element input {
    attribute type {'hidden'},
    attribute name {'client_id'},
    attribute value {'https://gmack.nz'}
   },

  element input {
    attribute type {'hidden'},
    attribute name {'redirect_uri'},
    attribute value {'https://gmack.nz/_login'}
   },

  element input {
    attribute type {'hidden'},
    attribute name {'state'},
    attribute value {'jwiusuerujs'}
   }
  }
};


declare
function feed:footer( $map as map(*)) {
  element footer {
    attribute title { 'page footer' },
    attribute role  { 'contentinfo' },
    element a {
      attribute href {'/'},
      attribute title {'home page'},
      $map('domain')
    },
    ' is the website',
     '(v' || $map('pkg-version') || ')',
    'owned, authored and operated by ' ,
    element a {
      attribute href {'.'},
      attribute title {'author'},
      $map('card-name')
    }
  }

};

declare
function feed:recent-entries( $map as map(*)) {
    for $entry at $i in xmldb:xcollection($map('data-posts'))/*
    order by xs:dateTime($entry/published) descending
    let $kindOfPost := feed:getKindOfPost( $entry/uid/string())
    let $tags := $entry/category
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
 };


declare
function feed:rep-card( $map as map(*)) {
element div {
  attribute id {'rep-card'},
  attribute class {'h-card'},
  element figure {
    qt:substitute( $map('card') ,
       <img class='u-photo'
            width='180'
            height='180'
            alt='name'
            src="photo" />),
    element figcaption {
      qt:substitute( $map('card'),
        <a class="p-name u-url u-uid"
            rel="me"
            href="url">
        name
        </a>),
    element br {},
    qt:substitute( $map('card'),
          <em class="p-note">
          note
          </em>
          )
        }
      },
      element div {
        element a {
          attribute class { 'u-email' },
          attribute href { 'u-email' },
          element figure {
            attribute class { 'contact-info' },
            element img {
              attribute width { '16' },
              attribute height { '16' },
              attribute alt { $map('card')('email') },
              attribute src { '/icons/mail' }
            },
            element figcaption { $map('card')('email') }
          }
        }
      },
      element div {
        element figure {
          attribute class { 'h-adr' },
          element img {
            attribute width { '16' },
            attribute height { '16' },
            attribute alt { $map('card')('name') },
            attribute src { '/icons/geolocation' }
          },
          element figcaption {
            element span {
              attribute class { 'p-street-address'  },
              $map('card')('street-address')
            }, ', ' ,
            element span {
              attribute class { 'p-locality'  },
              $map('card')('locality')
            }, ', ',
            element span {
              attribute class { 'p-country-name'  },
              $map('card')('country-name')
            }
          }
        }
      },
       element div {
        attribute class { 'link-to-profiles' },
        qt:forEach( $map('profiles'),
            <a href="url"
            rel="me">
            <img width='16'
            height='16'
            alt='name'
            src="icon" />
            </a>
            )
      }
    }
};


declare
function feed:render( $map as map(*)) {
  element html {
    attribute lang {'en'},
    feed:head( $map ),
    element body {
      feed:header( $map ),
      element main {
        attribute class {'h-feed'},
        feed:recent-entries( $map )
      },
      element aside {
        feed:rep-card( $map )
        },
      feed:footer( $map )
      }
    }
};

