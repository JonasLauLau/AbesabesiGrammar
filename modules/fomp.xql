

xquery version "3.1";

module namespace fomp="http://www.example.org/abesabesi/formMeaningPair";
import module namespace gram="http://www.example.org/abesabesi/grammarEntry" at "grammar-entry.xql";
declare default element namespace "http://www.tei-c.org/ns/1.0";


(:~
 : This module has been created to follow a form-function approach. It is currently not used. Prefixes have to be changed
:)


declare function fomp:section-head($id as xs:string){
    let $section:= $gram:doc/TEI/text/body//div[@xml:id = $id]
    return gram:text($section/head)
};

declare function fomp:section-number($id as xs:string){
    let $section:= $gram:doc/TEI/text/body//div[@xml:id = $id]
    return data($section/@n)
    };

declare function fomp:entry($entry as node()){
    let $subtype-div := data($entry/../@subtype)
    let $subtype := if ($subtype-div) then $subtype-div else fomp:find-subtype($entry)
    return
       <div class="w3-container w3-padding-16 w3-white w3-margin-bottom">
            <div class="jl-bar">
                {fomp:get-entry-header($entry, $subtype)}
            </div>
            <hr/>
            <table class="w3-table">
                {fomp:get-entry-middle($entry, $subtype)}
                <tr style="border-bottom:1px solid #eee; margin:20px 0">
                    <td colspan="100%"></td>
                </tr>
              {fomp:get-entry-footer($entry)}
            </table>
        </div>
};

declare function fomp:find-subtype($node as node()){
    if ($node/form/form[@type ='allomorph'])
    then
        (:for simple forms:)
        "form"
    else if ($node/form/form[@type = 'formula'])
    then
        (:for constructions:)
        "construction"
    else
        (:for simple functions:)
        "function"
};

declare function fomp:get-entry-header($entry as node(), $subtype as xs:string){
    if ($subtype = "form")
    then
        fomp:form-header($entry)
    else if ($subtype = "construction")
    then
        fomp:construction-header($entry)
    else if ($subtype = "function")
    then
        fomp:function-header($entry)
    else
        fomp:default-header($entry)
};

declare function fomp:get-entry-middle($entry as node(), $subtype as xs:string){
    if ($subtype = "form")
    then
        fomp:form-middle($entry)
    else if ($subtype = "construction")
    then
        fomp:construction-middle($entry)
    else if ($subtype = "function")
    then
        fomp:function-middle($entry)
    else
        fomp:default-middle($entry)
};

declare function fomp:get-entry-footer($entry as node()){
    if ($entry/xr[@type = "construction"])
    then
        for $construction in $entry/xr[@type = "construction"]
        let $location := substring(data($construction/ptr/@target), 2)
        return
            if ($construction = ($entry/xr[@type = "construction"][1]))
            then
                <tr><td><b>Component of</b></td>
                <td><a class="intext-button" href="grammar-entry.html?section={$location}">{fomp:section-head($location)}</a></td></tr>
            else
                <tr><td></td><td><a class="intext-button" href="grammar-entry.html?section={$location}">{fomp:section-head($location)}</a></td></tr>
    else if ($entry/xr[@type = "component"])
    then
        for $construction in $entry/xr[@type = "component"]
        let $location := substring(data($construction/ptr/@target), 2)
        return
            if ($construction = $entry/xr[@type = "component"][1])
            then
                <tr><td><b>Components</b></td>
                <td><a class="intext-button" href="grammar-entry.html?section={$location}">{fomp:section-head($location)}</a></td></tr>
            else
                <tr><td></td><td><a class="intext-button" href="grammar-entry.html?section={$location}">{fomp:section-head($location)}</a></td></tr>
    else
        ()
    
};

declare function fomp:form-header($entry as node()){
    <span>
        {
            for $form in $entry/form/form[@type='allomorph']
            let $allomorph := 
                 if ($form is $entry/form/form[@type='allomorph'][1])
                then
                    data($form/orth)
                else
                    concat(" | ", data($form/orth))
            return 
                if ($form/pron) 
                then 
                    <span class="jl-bar" title="Allomorphs">
                        <h1 class="jl-dict-entry">{$allomorph}</h1>
                        <h5 class="jl-dict-entry" title="IPA"> [{data($form/pron)}] </h5>        
                    </span>
                else data($allomorph)
            }
        {fomp:get-morphological-info($entry)}
    </span>
};

declare function fomp:get-morphological-info($entry as node()){
    if ($entry/form/gramGrp/gram[@type = "pos"])
    then
        <i class="jl-dict-entry" title="POS">{data($entry/form/gramGrp/gram[@type = "pos"])}</i>
    else
        ()
};

declare function fomp:construction-header($entry as node()){
      for $formula in $entry/form/form[@type='formula']
      return
          <h1 class="jl-dict-entry">
          {gram:text($formula)}</h1>,
          <i class="jl-dict-entry">construction</i>
};

declare function fomp:function-header($entry as node()){
          <h1 class="jl-dict-entry">
          {data($entry/../head)}</h1>,
          <i class="jl-dict-entry">function</i>
};

declare function fomp:default-header($entry as node()){
          <h1 class="jl-dict-entry">
          {data($entry/parent::node/head)}</h1>,
          fomp:get-morphological-info($entry)
};


declare function fomp:form-middle($entry as node()){
    <tr>
        <th>Functions</th>
        <th>Glosses</th>
    </tr>,
    
    for $sense in $entry/sense
    let $location := substring(data($sense/@location), 2)
    return 
        <tr>
            <td><a class="intext-button" href="grammar-entry.html?section={$location}">{fomp:section-head($location)}</a></td>
            {if ($sense/gloss)
            then
                let $gloss-target := data($sense/gloss/@target)
                return
                    <td style="font-variant:small-caps" title="{fomp:get-item($gloss-target)}">
                        {fomp:get-label($gloss-target)}
                    </td>
            else
                ()
            }
        </tr>
};

declare function fomp:construction-middle($entry as node()){
      for $sense in $entry/sense
      let $location := substring(data($sense/@location), 2)
        return
            if ($sense = $entry/sense[1])
            then
                <tr>
                    <td><b>Functions</b></td>
                    <td><a class="intext-button" href="grammar-entry.html?section={$location}">{fomp:section-head($location)}</a></td>
                </tr>
            else
                <tr><td></td><td><a class="intext-button" href="grammar-entry.html?section={$location}">{fomp:section-head($location)}</a></td></tr>
};

declare function fomp:function-middle($entry as node()){
    <tr>
        <th>Forms</th>
        <th>Glosses</th>
    </tr>,
    
    for $form in $entry/form
    let $location := substring(data($form/@location), 2)
    return 
        <tr>
            <td><a class="intext-button" href="grammar-entry.html?section={$location}">{fomp:section-head($location)}</a></td>
            {if ($form/gloss)
            then
                let $gloss-target := data($form/gloss/@target)
                return
                    <td style="font-variant:small-caps" title="{fomp:get-item($gloss-target)}">
                        {fomp:get-label($gloss-target)}
                    </td>
            else
                <td> - </td>
            }
        </tr>
};

declare function fomp:default-middle($entry as node()){
    if ($entry/form/gloss)
    then
        fomp:function-middle($entry)
    else if ($entry/sense/gloss)
    then
        fomp:form-middle($entry)
    else
        ()
        
};

declare function fomp:resolve-pointer($target as xs:string)
{
    let $parts := fn:tokenize($target, "#")
    return
        if (fn:count($parts) = 2)
        then
            let $doc-name := data($parts[1])
            let $doc-uri := concat("/db/apps/Abesabesi/resources/data/" , $doc-name)
            let $id := data($parts[2])
            return doc($doc-uri)/TEI/text/body/list//item[@xml:id = $id]
        else
            ()
};

declare function fomp:get-label($target as xs:string){
    let $item := fomp:resolve-pointer($target)
    return
        data($item/abbr)
};

declare function fomp:get-item($target as xs:string){
    let $item := fomp:resolve-pointer($target)
    return
        data($item/expan)
};





