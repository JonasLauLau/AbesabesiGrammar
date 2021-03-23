xquery version "3.1";

module namespace bib="http://www.example.org/abesabesi/bibliography";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.example.org/abesabesi/config" at "config.xqm";

declare namespace en="https://endnote.com/";

declare variable $bib:bibliography:= doc("/db/apps/Abesabesi/resources/data/bibliography.xml");


(:~
 : This module accesses the bibliography database (bibliography.xml) and displays the bibliography at bibliography.html
:)



declare function bib:requestID () as xs:string 
{
    request:get-parameter('entry', 'full')
};


(:-----------------------------------TEMPLATE-FUNCTIONS-----------------------------------------------
    these functions are called at bibliography.html and render the full bibliography and parts of it.
:)

declare function bib:bibliography($node as node(), $model as map(*)) 
{
   let $entry-id:= bib:requestID()
   return
        if ($entry-id = 'full')
        then
            bib:bibliographyFull()
        else
            bib:bibliographyEntry($entry-id)
};
        
declare function bib:bibliographyFull()
{
let $records:= $bib:bibliography//en:record
    return
        <ol class="toc">
            {for $record in $records
                return
                    <li>
                        <a class="jl-txt" style="display:inline-block; padding: 20px 20px; text-indent: -20px;"  href="bibliography.html?entry={data($record/@xml:id)}">
                            {bib:bibauthor($record)} ({bib:bibdate($record)}). {bib:bibtitle($record)}
                        </a>
                    </li>}
        </ol>
};

declare function bib:bibliographyEntry($entry-id as xs:string)
{
    let $entry:= $bib:bibliography//en:record[@xml:id=$entry-id]
    let $ref-type:= data($entry/en:ref-type)
    return
        <div>
            <table class="w3-table">
                <tr>
                    <td>Author</td><td>{bib:bibauthor($entry)}</td>
                </tr>
                <tr>
                    <td>Year</td><td>{bib:bibdate($entry)}</td>
                </tr>
                <tr>
                    <td>Title</td><td>{bib:bibtitle($entry)}</td>
                </tr>
                {        
                if ($ref-type=1)
                then
                    bib:bibBook($entry)
                else if ($ref-type=0)
                then
                    bib:bibJournal($entry)
                else if ($ref-type=3)
                then
                    bib:bibProceedings($entry)
                else if ($ref-type=7)
                then
                    bib:bibSection($entry)
                else if ($ref-type=16)
                then
                    bib:bibWeb($entry)
                else()
                }                     
            </table>
            <a class="w3-button" style="float:right; color:#aaa" href="bibliography.html">Full Bibliography</a>
        </div>
};
 
 (:-----------------------------------BIBPARTS-FUNCTIONS-----------------------------------------------
    these functions generate parts of the reference: author, date, title, etc.
:)


declare function bib:bibauthor($record as node()) 
{
    let $author:= $record/en:contributors/en:authors/en:author
    return
        <span class="jl-txt">{data($author)}</span>
         
};

declare function bib:bibdate($record as node()) 
{
    let $date:= $record/en:dates/en:year
    return
        <span class="jl-txt">{data($date)}</span>
};

declare function bib:bibtitle($record as node()) 
{
    let $title:= $record/en:titles/en:title
    return
        <i class="jl-txt">{data($title)}</i>
};

declare function bib:bibBook ($entry as node())
{
    <tr>
        <td>Publisher</td><td class="jl-txt">{data($entry/en:pub-location)}: {data($entry/en:publisher)}</td>
    </tr>                    
};

declare function bib:bibJournal ($entry as node())
{
    <tr>
        <td>Journal</td><td class="jl-txt">{data($entry/en:periodical/en:full-title)}, {data($entry/en:volume)}, pp. {data($entry/en:pages)}</td>
    </tr>                    
};

declare function bib:bibWeb ($entry as node())
{
    let $url := data($entry/en:urls/en:web-urls/en:url)
    return
    <div>
    <tr>
        <td>Publication</td><td class="jl-txt">{data($entry/en:periodical/en:full-title)}</td>
    </tr> 
    <tr>
        <td>Website</td><td><a href="{$url}">{$url}</a></td>
    </tr>
    </div>
};

declare function bib:bibSection ($entry as node())
{
    let $url := data($entry/en:urls/en:web-urls/en:url)
    return
    <div>
        <tr>
            <td>Book</td><td class="jl-txt">{data($entry/en:periodical/en:full-title)}, pp. {data($entry/en:pages)}</td>
        </tr> 
        <tr>
            <td>Editors</td><td class="jl-txt">{data($entry/en:contributors/en:secondary-authors/en:author)}</td>
        </tr>
        <tr>
            <td>Publisher</td><td class="jl-txt">{data($entry/en:pub-location)}: {data($entry/en:publisher)}</td>
        </tr>
    </div>
};

declare function bib:bibProceedings ($entry as node())
{
    <tr>
        <td>Publication</td><td class="jl-txt">{data($entry/en:periodical/en:full-title)}</td>
    </tr> 
};
