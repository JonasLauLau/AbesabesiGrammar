
// (:        // Get the Sidebar:)
var mySidebar = document.getElementById("mySidebar");
var toolbarElements = document.getElementsByClassName("jl-toolbar");
var contentElements = document.getElementsByClassName("jl-content");

// (:        // Get the DIV with overlay effect:)
var overlayBg = document.getElementById("myOverlay");

var grammarSwitch = document.getElementById("grammar-switch");
var grammarAlt = document.getElementById("grammar-alternatives");

var gm = document.getElementById("grammar-main");
var tm = document.getElementById("texts-main");
var dm = document.getElementById("dictionary-main");

var modals = document.getElementsByClassName('modal');

//var vid = document.getElementById('video21');
//vid.addEventListener("error", hideElement('videoButton21'));

//Video
//document.getElementById("video").currentTime = 40;

function hideElement(id) {
    var element = document.getElementById(id);
    element.visibility = ('hidden');
}


// Toggle between showing and hiding the sidebar, and add overlay effect
function w3_open() {
    if (mySidebar.style.display === 'block') {
        mySidebar.style.display = 'none';
        overlayBg.style.display = "none";
    } else {
        mySidebar.style.display = 'block';
        overlayBg.style.display = "block";
    }
}

// Close the sidebar with the close button
function w3_close() {
    mySidebar.style.display = "none";
    overlayBg.style.display = "none";
}



function myAccFunc(id) {
    var x = document.getElementById(id);
    if (x.className.indexOf("w3-show") == -1) {
        x.className += " w3-show";
        x.previousElementSibling.className += " w3-teal";
    } else {
        x.className = x.className.replace(" w3-show", "");
        x.previousElementSibling.className =
        x.previousElementSibling.className.replace(" w3-teal", "");
    }
}

function showLevelBeneath(element) {
    element.nextElementSibling.style.display = "block";
    element.innerHTML = "<i class='fa fa-caret-down'/>";
    element.setAttribute("onClick", "javascript: hideLevelBeneath(this);");
    element.title = "Hide subsections";
}

function hideLevelBeneath(element) {
    element.nextElementSibling.style.display = "none";
    element.innerHTML = "<i class='fa fa-caret-right'/>";
    element.setAttribute("onClick", "javascript: showLevelBeneath(this);");
    element.title = "Show subsections";
}

function changeToRightDirection(element) {
    element.innerHTML = "<i class='fa fa-long-arrow-alt-right w3-large'/>";
    element.setAttribute("onClick", "javascript: changeToLeftDirection(this);");
}

function changeToLeftDirection(element) {
    element.innerHTML = "<i class='fa fa-long-arrow-alt-left w3-large'/>";
    element.setAttribute("onClick", "javascript: changeToBothDirections(this);");
}

function changeToBothDirections(element) {
    element.innerHTML = "<i class='fa fa-arrows-alt-h w3-large'/>";
    element.setAttribute("onClick", "javascript: changeToRightDirection(this);");
}

/*
function openMain(id) {
var i;
var x = document.getElementsByClassName("jl-main");
for (i = 0; i < x.length; i++) {
x[i].style.display = "none";
}
document.getElementById(id).style.display = "block";
}

function openDictionary() {

grammarSwitch.innerHTML = "<i class='fa fa-list-alt fa-fw'></i> Dictionary";
grammarAlt.innerHTML = '<a href="index.html" class="w3-bar-item w3-button"><i class="fa fa-archive fa-fw"></i>  Grammar</a> <a href="texts.html" class="w3-bar-item w3-button" ><i class="fa fa-book-reader fa-fw"></i> Texts</a>';

}

function openGrammar() {

grammarSwitch.innerHTML = '<i class="fa fa-archive fa-fw"></i>  Grammar';
grammarAlt.innerHTML = '<a href="dictionary.html" class="w3-bar-item w3-button" ><i class="fa fa-list-alt fa-fw"></i> Dictionary</a> <a href="texts.html" class="w3-bar-item w3-button"><i class="fa fa-book-reader fa-fw"></i> Texts</a>';

}

function openTexts() {

grammarSwitch.innerHTML = '<i class="fa fa-book-reader fa-fw"></i> Texts';
grammarAlt.innerHTML = '<a href="index.html" class="w3-bar-item w3-button"><i class="fa fa-archive fa-fw"></i>  Grammar</a> <a href="dictionary.html" class="w3-bar-item w3-button"><i class="fa fa-list-alt fa-fw"></i> Dictionary</a>';

}

 */

function isURL(url) {
    var urlparts = window.location.href.split("/");
    var file = urlparts[urlparts.length - 1];
    if (file === url || file === url + "#") {
        return true
    } else {
        return false
    }
}

/*
function adjustAcc(){

if (isURL("texts.html")){
openTexts();
}
else if ( isURL("dictionary.html")){
openDictionary();
}
else {
openGrammar();
}
}
 */
function openTabLeft(tabName) {
    if (! isURL("index.html")) {
        window.open("index.html", "_self")
    }
    
    openTab(tabName);
}

function openTab(tabName) {
    var i;
    var x = document.getElementsByClassName("tab");
    for (i = 0; i < x.length; i++) {
        x[i].style.display = "none";
    }
    document.getElementById(tabName).style.display = "block";
}
function setMap() {
  if (isURL("index.html")) {
        var mymap = L.map('mapid').setView([7.601869, 5.853848], 5);
        
       L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
    attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
    maxZoom: 18,
            id: 'mapbox/streets-v11',
             tileSize: 512,
    zoomOffset: -1,
    accessToken: 'pk.eyJ1Ijoiam9uYXNsYXVsYXUiLCJhIjoiY2trZTBtZngxMDJpazJvcnhtNnBodHd4OCJ9.fdgILrdJy6eiw6kcHr_Kbg'
        }).addTo(mymap);
        var marker = L.marker([7.601869, 5.853848]).addTo(mymap);
    }
}

// When the user clicks on the button, open the modal
function openMod(id) {
    document.getElementById(id).style.display = "block";
}

function openMod(id, content) {
    document.getElementById(id).style.display = "block";
    document.getElementById("modCite-inner").dataset.template.id = content;
}

// When the user clicks on <span> (x), close the modal
function closeMod(id) {
    document.getElementById(id).style.display = "none";
}

// When the user clicks anywhere outside of the modal, close it
window.onclick = function (event) {
    
    for (i = 0; i < modals.length; i++) {
        if (event.target == modals[i]) {
            modals[i].style.display = "none";
        }
    }
}

function back() {
    history.go(-1);
}
function forward() {
    history.go(+ 1);
}

function hideToolbar() {
    for (i = 0; i < toolbarElements.length; i++) {
        
        toolbarElements[i].style.display = "none";
    }
    for (i = 0; i < contentElements.length; i++) {
        contentElements[i].className =
        contentElements[i].className.replace(" w3-twothird", "");
    }
    var toolbarButton = document.getElementById("toolbar-button");
    toolbarButton.className += " jl-pointer";
    toolbarButton.className = toolbarButton.className.replace(" w3-text-white", " w3-text-grey");
}

function showToolbar() {
    for (i = 0; i < toolbarElements.length; i++) {
        
        toolbarElements[i].style.display = "block";
    }
    for (i = 0; i < contentElements.length; i++) {
        contentElements[i].className += " w3-twothird";
    }
    var toolbarButton = document.getElementById("toolbar-button");
    toolbarButton.className = toolbarButton.className.replace(" jl-pointer", "");
    toolbarButton.className = toolbarButton.className.replace(" w3-text-grey", " w3-text-white");
}

function sortTable(n) {
    var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
    table = document.getElementById("dict-table");
    switching = true;
    // Set the sorting direction to ascending:
    dir = "asc";
    /* Make a loop that will continue until
    no switching has been done: */
    while (switching) {
        // Start by saying: no switching is done:
        switching = false;
        rows = table.rows;
        /* Loop through all table rows (except the
        first, which contains table headers): */
        for (i = 1; i < (rows.length - 1);
        i++) {
            // Start by saying there should be no switching:
            shouldSwitch = false;
            /* Get the two elements you want to compare,
            one from current row and one from the next: */
            x = rows[i].getElementsByTagName("TD")[n];
            y = rows[i + 1].getElementsByTagName("TD")[n];
            /* Check if the two rows should switch place,
            based on the direction, asc or desc: */
            if (dir == "asc") {
                if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
                    // If so, mark as a switch and break the loop:
                    shouldSwitch = true;
                    break;
                }
            } else if (dir == "desc") {
                if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
                    // If so, mark as a switch and break the loop:
                    shouldSwitch = true;
                    break;
                }
            }
        }
        if (shouldSwitch) {
            /* If a switch has been marked, make the switch
            and mark that a switch has been done: */
            rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
            switching = true;
            // Each time a switch is done, increase this count by 1:
            switchcount++;
        } else {
            /* If no switching has been done AND the direction is "asc",
            set the direction to "desc" and run the while loop again. */
            if (switchcount == 0 && dir == "asc") {
                dir = "desc";
                switching = true;
            }
        }
    }
    
    var ths = table.rows[0].getElementsByTagName("TH");
    var th = ths[n];
    for (var j = 0; j < ths.length; j++) {
        ths[j].getElementsByClassName("jl-sort-down")[0].style.display = "none";
        ths[j].getElementsByClassName("jl-sort-up")[0].style.display = "none";
    }
    if (dir == "asc") {
        th.getElementsByClassName("jl-sort-up")[0].style.display = "inline";
    } else if (dir == "desc") {
        th.getElementsByClassName("jl-sort-down")[0].style.display = "inline";
    }
}