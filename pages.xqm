xquery version "3.0";
module namespace cms = "http://www.andrewsales.com/xquery"; 

declare variable $cms:collConfig := doc('/ContentBase/collection/config/user-edit-permissions.xml');
declare variable $cms:collBase := $cms:collConfig/collection/@xml:base;

declare 
  %rest:path("/ContentBase/collection") 
  %output:method("html")
function cms:collection() 
as element(html)
{
  let $user := user:current()
  return
   <html>
     <head>
       <title>ContentBase</title>
     </head>
     <body>       
       <h1>Documents for <code>{$user}</code></h1>
       {
         for $doc in collection($cms:collBase)
           let $uri := tokenize($doc/base-uri(), '/')[last()]
           where $uri = $cms:collConfig/collection/user[
             if($user = 'admin')
             then true()
             else @name = $user
           ]/file/@url
           return <div><a href='toc?url={$uri}'>{$uri}</a></div>
       }
     </body>
   </html>
};

declare 
  %rest:path("/ContentBase/toc") 
  %rest:query-param("url", "{$url}")
  %output:method("html")
function cms:toc($url) 
as element(html)
{
  <html>
     <head>
       <title>{$url} - Table of contents</title>
     </head>
     <body>       
       <h1>{$url}</h1>
       {
         (:TODO: make it work for actual ToCs:)
         for $f in doc($cms:collBase || '/' || $url)/*/*:facsimile
           let $id := $f/@xml:id/data()
           return <div><a href='page?url={$url}&amp;id={$id}'>{$id}</a></div>
       }
     </body>
   </html>
};

(:TODO: how do we pass the XML for this facsimile?:)
declare 
  %rest:path("/ContentBase/page") 
  %rest:query-param("id", "{$id}")
  %rest:query-param("url", "{$url}")
  %output:method("html")
function cms:page($url, $id) 
as element(html)
{
  <html>
     <head>
       <title>{$url}, page {$id}</title>
     </head>
     <body>       
       <h1>{$url}</h1>
       <h2>{$id}</h2>
       {
         (:TODO: make it work for actual pages:)
         let $facs := doc($cms:collBase || '/' || $url)/*/*:facsimile[@xml:id=$id]
         return
           <div>
             <a href='https://path/to/images/{$facs/*:graphic/@url}'>
             {$facs/*:graphic/@url/data()}
             </a>
           </div>
       }
     </body>
   </html>
};