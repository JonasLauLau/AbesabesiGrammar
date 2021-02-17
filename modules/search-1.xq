xquery version "3.1";

declare default element namespace "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=xhtml media-type=text/html";
declare variable $searchphrase := request:get-parameter("searchphrase", ());
declare variable $doc := doc("/db/apps/Abesabesi/resources/data/ekirom.xml");



<html>
    <head>
        <meta HTTP-EQUIV="Content-Type" content="text/html; charset=UTF-8"/>
        <title></title>
    </head>
    <body>
        <h1>blub</h1>
        <p>Search phrase: "{$searchphrase}"</p>
       <p>In headings:</p>
        <ul>
        {
            for $head in $doc/TEI/text/body//div/head[ft:query(., $searchphrase)] 
            let $div := $head/..
            return
                <li>
                    <a href="grammar-entry.html?section={$div/@xml:id}"> {string($head)}</a><br/>
                </li>
        }
        </ul>
        <p>In text:</p>
        <ul>
        {
            for $paragraph in doc("/db/apps/Abesabesi/resources/data/ekirom.xml")/TEI/text/body//div/p[ft:query(., $searchphrase)] 
            let $div := $paragraph/..
            return
                <li>
                    from: <a href="grammar-entry.html?section={$div/@xml:id}"> {string($div/head)}</a><br/>
                    <i>{string($paragraph)}</i>
                </li>
        }
        </ul>
    </body>
    <!--<div>
        <h1>{$page-title}</h1>
        <p>Search phrase: "{$searchphrase}"</p>
        <p>In headings:</p>
        <ul>
        {
            for $head in $doc/TEI/text/body//div/head[ft:query(., $searchphrase)] 
            let $div := $head/..
            return
                <li>
                    <a href="grammar-entry.html?section={$div/@xml:id}"> {string($head)}</a><br/>
                </li>
        }
        </ul>
        <p>In text:</p>
        <ul>
        {
            for $paragraph in doc("/db/apps/Abesabesi/resources/data/ekirom.xml")/TEI/text/body//div/p[ft:query(., $searchphrase)] 
            let $div := $paragraph/..
            return
                <li>
                    from: <a href="grammar-entry.html?section={$div/@xml:id}"> {string($div/head)}</a><br/>
                    <i>{string($paragraph)}</i>
                </li>
        }
        </ul>
</div> 
-->
</html>




