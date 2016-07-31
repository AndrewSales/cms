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
           let $fn := tokenize($doc/base-uri(), '/')[last()]
           where $fn = $cms:collConfig/collection/user[
             if($user = 'admin')
             then true()
             else @name = $user
           ]/file/@url
           return <div><a href='toc?url={$fn}'>{$fn}</a></div>
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
         (:TODO: make it work for actual ToCs - call XSLT on TEI/text//div? :)
         for $f in doc($cms:collBase || '/' || $url)/*/*:facsimile
           let $id := $f/@xml:id/data()
           return <div><a href='page?url={$url}&amp;id={$id}'>{$id}</a></div>
       }
     </body>
   </html>
};

(:TODO: titles:)
declare 
  %rest:path("/ContentBase/title") 
  %rest:query-param("url", "{$url}")
  %rest:query-param("id", "{$id}")
  %output:method("html")
function cms:work($url, $id) 
as element(html)
{
  <html>
     <head>
       <title>{$url} - title view</title>
     </head>
     <body>       
       <h1>{$url}</h1>
       {
         (:TODO: make it work for actual titles:)
         
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

declare 
  %rest:path("/ContentBase/login")
  %output:method("html")
function cms:login()
{
  

<html lang="en">
  <head>
    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content=""/>
    <meta name="author" content=""/>
    <link rel="icon" href="../../favicon.ico"/>

    <title>Signin Template for Bootstrap</title>

    <!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous"/>

<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous"/>

<!-- Custom styles for this template -->
    <link href="{resolve-uri('signin.css', static-base-uri())}" rel="stylesheet"/>

<!-- Latest compiled and minified JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>

  <body>

    <div class="container">

      <form class="form-signin" action='checkLogin' method='post'>
        <h2 class="form-signin-heading">Please sign in</h2>
        <label for="inputEmail" class="sr-only">Email address</label>
        <input type="email" id="inputEmail" class="form-control" placeholder="Email address" required='' autofocus=''/>
        <label for="inputPassword" class="sr-only">Password</label>
        <input type="password" id="inputPassword" class="form-control" placeholder="Password" required=''/>
        <div class="checkbox">
          <label>
            <input type="checkbox" value="remember-me"/> Remember me
          </label>
        </div>
        <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
      </form>

    </div> <!-- /container -->


    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <script src="../../assets/js/ie10-viewport-bug-workaround.js"></script>
  </body>
</html>

};

declare 
  %rest:path("/ContentBase/login")
  %output:method("html")
function cms:checkLogin()
{
  
};