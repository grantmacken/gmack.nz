xquery version "3.1";
(: import module namespace xdb="http://exist-db.org/xquery/xmldb"; :)
(: The following external variables are set by the repo:deploy function :)
(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

declare variable $domain  := substring-after( string($target), '/apps/');
declare variable $config  := 'xmldb:exist:///db/system/config/db';
declare variable $config_apps  := $config || '/apps';
declare variable $config_app   := $config_apps || '/' ||  $domain;
declare variable $config_data  := $config || '/data/' || $domain;
declare variable $config_data_docs  :=  $config_data || '/docs';
declare variable $app_data     :=  'xmldb:exist:///db/data/' || $domain;
declare variable $docs         :=   $app_data  || '/docs';

try {
(
  util:log-system-out( ' ------------------------------------------------------ '  ),
  util:log-system-out( 'INSTALL: target ' || $target   ),
  util:log-system-out( 'INSTALL: directory ' || $dir   ),
  util:log-system-out( 'INSTALL: - create data collections'),
  xmldb:create-collection( 'xmldb:exist:///db','data' ),
  xmldb:create-collection( 'xmldb:exist:///db/data' , $domain ),
  xmldb:create-collection( $app_data , 'docs' ),
  xmldb:create-collection( $app_data , 'media' ),
  xmldb:create-collection( $docs, 'pages' ),
  xmldb:create-collection( $docs, 'posts' ),
  xmldb:create-collection( $docs, 'recycle' ),
  xmldb:create-collection( $docs, 'uploads' ),
  xmldb:create-collection( $docs, 'mentions' ),
  util:log-system-out( 'INSTALL: - create config collections'),
  xmldb:create-collection( $config, 'data' ),
  xmldb:create-collection( $config || '/data/', $domain  ),
  xmldb:create-collection( $config_data, 'docs' ),
  xmldb:create-collection( $config_apps, $domain ),
  util:log-system-out( 'INSTALL: - enable db triggers upon creating, updating, moving and deleting docs'),
  xmldb:store-files-from-pattern($config_data_docs, $dir, 'data-collection.xconf'),
  util:log-system-out( 'INSTALL: - enable restXQ for data views'),
  xmldb:store-files-from-pattern($config_app, $dir, 'collection.xconf')
)
} catch * {
  util:log-system-out( 'ERROR INSTALL: ' || $err:description   )
}
