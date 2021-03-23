xquery version "3.1";

module namespace term="http://www.example.org/abesabesi/terms";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.example.org/abesabesi/config" at "config.xqm";
import module namespace gram="http://www.example.org/abesabesi/grammarEntry" at "grammar-entry.xql";
import module namespace igt="http://www.example.org/abesabesi/igt" at "igt.xql";

declare default element namespace "http://www.tei-c.org/ns/1.0";
declare variable $term:terms := doc("/db/apps/Abesabesi/resources/data/terminology.xml");
declare variable $term:abbreviations := doc("/db/apps/Abesabesi/resources/data/glossary.xml");

(:~
 : This module accesses the terminology database (terminology.xml) and displays the index in index-list.html
:)

(:-----------------------------------GET-FUNCTIONS-----------------------------------------------
    these are auxiliary functions that return terms or particular parts of it
    as XML nodes. They never return strings.
:)

declare function term:get-term($id as xs:string)
{
   $term:terms/TEI/text/body//item[@xml:id = $id]
};

declare function term:get-abbr($id as xs:string)
{
    $term:abbreviations/TEI/text/body//item[@xml:id = $id]
};

declare function term:get-ancestors($term as node())
{
   $term/ancestor::item
};




(:-----------------------------------PRINT-FUNCTIONS-----------------------------------------------
    these are auxiliary functions are equivalents of the GET-FUNCTIONS but always return 
    the string value of particular parts of a term 
:)

declare function term:print-label($term as node())
{
   data($term/term)
};

declare function term:print-gloss($term as node())
{
   data($term/gloss)
};

declare function term:requestID () as xs:string 
{
    request:get-parameter('entry', 'full')
};

(:-----------------------------------TEMPLATE-FUNCTIONS-----------------------------------------------
    these are template functions that are called from glossary.html and index.html to render the abbreviations list and the index.
:)

declare function term:abbreviations($node as node(), $model as map(*))
{
    let $items := $term:abbreviations/TEI/text/body/list/item
    return
    <div class="w3-padding-16 w3-bar-block w3-white w3-margin-bottom">
    <table>
        {
        for $item in $items
            let $abbr := $item/abbr
            let $expan := $item/expan
            order by $abbr
            return
                <tr>
                    <td class="w3-padding">{data($abbr)}</td><td>-</td>
                    <td class="w3-padding">{data($expan)}</td>
                </tr>
        }
        </table>
    </div>
};

declare function term:index($node as node(), $model as map(*)) 
{
   let $entry-id:= term:requestID()
   return
        if ($entry-id = 'full')
        then
           term:indexFull()
        else
           term:indexEntry($entry-id)
};

declare function term:indexFull()
{
    let $indexes := $term:terms/TEI/text/body/list/item
    return 
        <ul class="toc">
            {
            for $term in $indexes
            order by $term
            return
                term:index-child($term)
            }
        </ul>
};

declare function term:index-child($term as node()){
    let $item := $term/gloss
    let $list := $term/list
    let $id := $term/@xml:id
    return
     <li>
         <a href="index-list.html?entry={data($id)}" class="w3-button" title="{$item/text()}">{data($term/term)}</a>
            {term:textReferences($id)}
            {
                let $exampleIndexes := igt:get-term($id) 
                return
                    if ($exampleIndexes)
                    then
                        <span>Examples: {term:exampleReferences($id)}</span>
                    else ()     
            }
            { 
            if ($list)
            then
                <ul class="toc">
                    {
                    for $label in $list/item
                    order by $label
                    return
                        term:index-child($label)
                    }
                </ul>
            else ()
            }
     </li>
};

(: browses grammar entries and looks whether they contain references of a particular term. 
 : Returns buttons for every grammar entry that contains the reference.
:)
declare function term:textReferences($id as xs:string)
{
    let $textIndexes := gram:get-term($id)
    for $usedIndex in $textIndexes 
        let $div := $usedIndex/ancestor::div[1]
        return 
            <a class="w3-button" href="grammar-entry.html?section={$div/@xml:id}">
                {
                if ($usedIndex/parent::index)
                then
                    <b>{string($div/@n)}</b>
                else
                    string($div/@n)
                }
            </a>
};

(: browses examples and looks whether they contain references of a particular term. 
 : Returns buttons for every example that contains the reference.
:)
declare function term:exampleReferences($id as xs:string)
{ 
    let $exampleIndexes := igt:get-term($id)
    for $usedIndex in $exampleIndexes 
        let $cit := $usedIndex/../..
        return 
           <a class="w3-button" href="examples.html#{data($cit/@xml:id)}">{data($cit/@xml:id)}</a>
};

declare function term:indexEntry($id as xs:string)
{
    let $entry:= term:get-term($id)
    let $term:= $entry/term
    let $gloss:= $entry/gloss
    let $ancestors := $entry/ancestor::item
    let $textIndexes := gram:get-term($id)
    let $exampleIndexes := igt:get-term($id)
    return
        <div>
            <table class="w3-table">
                <tr><td>Term</td><td>{string($term)}
                    {
                        if ($ancestors)
                        then
                            <span> ({
                                for $ancestor in $ancestors
                                    return data($ancestor/term)
                            })</span>
                        else
                            ()
                    }
                    </td>
                </tr>      
                <tr>
                    <td>Gloss</td><td>{string($gloss)}</td>
                </tr>     
                {   
                    if ($textIndexes)
                    then
                        <tr> <td>Appears in Section</td> <td> {
                        term:textReferences($id)}</td></tr>
                     else()
                }
                {
                    if ($exampleIndexes)
                    then
                        <tr> <td>Appears in Example</td> <td> {
                        term:exampleReferences($id)}</td></tr>
                    else()
                }
            </table>
            <a class="w3-button" style="float:right; color:#aaa" href="index-list.html">All Indexes</a>
        </div>
};
