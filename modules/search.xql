xquery version "3.1";

module namespace search="http://www.example.org/abesabesi/search";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.example.org/abesabesi/config" at "config.xqm";
import module namespace gram="http://www.example.org/abesabesi/grammarEntry" at "grammar-entry.xql";

declare default element namespace "http://www.tei-c.org/ns/1.0";
declare variable $search:searchphrase := request:get-parameter("searchphrase", ());
declare variable $search:grammar := doc("/db/apps/Abesabesi/resources/data/ekirom.xml");

 declare function search:searchphrase($node as node(), $model as map(*))
{
    $search:searchphrase
};


 declare function search:headings($node as node(), $model as map(*))
{
    let $headings := $search:grammar/TEI/text/body//div/head[ft:query(., $search:searchphrase)] 
    return
    if ($headings)
    then
        <ul class="toc">
             {
                 for $head in $headings
                 let $div := $head/..
                 return
                     <li>
                         <a class="w3-button" href="grammar-entry.html?section={$div/@xml:id}">{string($div/@n)}&#160;{string($head)}</a><br/>
                     </li>
             }
         </ul>
    else
        <span>No results</span>
};


 declare function search:text($node as node(), $model as map(*))
{
    let $paragraphs := $search:grammar/TEI/text/body//div/p[ft:query(., $search:searchphrase)] 
    return
    if ($paragraphs)
    then
        for $paragraph in $paragraphs
        let $div := $paragraph/..
        return
            <div>
                <h6>From Section &#160;<a class="intext-button" href="grammar-entry.html?section={$div/@xml:id}"> {string($div/@n)}&#160;{string($div/head)}</a></h6>
                {gram:paragraph($paragraph)}
            </div>   
    else
        <span>No results</span>
};

declare function search:index($node as node(), $model as map(*))
{
    let $indexes := $search:grammar/TEI/text/body//index/term[fn:contains(data(@ref),$search:searchphrase)]
    return
    if ($indexes)
    then
     <ul class="toc">
        {
            for $index in $indexes 
            let $div := $index/../..
            return
            <li>
                <a class="w3-button" href="grammar-entry.html?section={$div/@xml:id}"> {string($div/@n)}&#160;{string($div/head)}</a><br/>
            </li> 
        }
     </ul>
     else
        <span>No results</span>
};

