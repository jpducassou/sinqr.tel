/////////////////// Form Fields Display /////////////////////////////////////////////////////
function toggleDiv(elementName, parent) {
    var e = document.getElementById(elementName);
    if (e) {
        if ((e.style.display != 'block')) {
            e.style.display = 'block';
            e.style.position = "absolute";
            e.style.zIndex = "1";
            e.style.top = findPosY (parent) + 30 + "px";
            e.style.left = findPosX (parent) - 600 + "px";
        } else {
            e.style.display = 'none';
        }
    }
}

function toggleBlock(elementName) {
    var e = document.getElementById(elementName);
    if (e) {
        if ((e.style.display != 'block')) {
            e.style.display = 'block';
        } else {
            e.style.display = 'none';
        }
    }
}

function findPosX(obj) {
    var curleft = 0;
    if(obj.offsetParent)
        while(1) {
        curleft += obj.offsetLeft;
        if(!obj.offsetParent)
            break;
        obj = obj.offsetParent;
    } else if(obj.x) curleft += obj.x;
    return curleft;
}

function findPosY(obj)  {
    var curtop = 0;
    if(obj.offsetParent)
        while(1)  {
            curtop += obj.offsetTop;
            if(!obj.offsetParent)
                break;
            obj = obj.offsetParent;
    } else if(obj.y)   curtop += obj.y;
    return curtop;
}

function cloneRow(id){
    var node = document.getElementById(id);
     var clone = node.cloneNode(true);
    insertAfter (node, clone);
    crawlNode(clone, id);
}

function insertAfter(ref, node) {
    ref.parentNode.insertBefore(node, ref.nextSibling);
}


function parentContainer (node, level) {
    while (level > 0) {
        level = level - 1;
        return parentContainer (node.parentNode, level);
    }
    return node;
}

function crawlNode(node, idPrefix) {
    if (node.id) {
            node.id =  indexPlus (node.id, idPrefix);
    } else if (node.name) {
        node.name =  indexPlus (node.name, idPrefix);
    }

    if(node.hasChildNodes()) {
        for(var i=0; i<node.childNodes.length; i++) {
            crawlNode(node.childNodes[i], idPrefix);
        }
    }
}

function indexPlus (id, prefix) {
    return buldIndexName (id, prefix, 1);
}

function indexMinus (id, prefix) {
    return buldIndexName (id, prefix, -1);
}

function buldIndexName(id, prefix, num) {
    var index = parseInt(extractIndex(prefix));
    var newIndex = index + parseInt(num);
    var name = extractName(prefix);
    return id.replace (prefix, name + "" + (newIndex) + "");

}

function hideAddDelete(id) {

     var addNode = document.getElementById(id + ".Add");
     var deleteNode = document.getElementById(id + ".Delete");
     addNode.style.display = 'none';
     deleteNode.style.display = 'none';

     var previousNodeId =  indexPlus (id, id);
     var previousDeleteNode = document.getElementById(previousNodeId + ".Delete");
     previousDeleteNode.style.display = '';
}

function extractIndex (id) {
    var match = /([0-9]+)$/i.exec(id);
    return match[1];
}

function extractName (id) {
    var match = /^(\S+)[0-9]+$/i.exec(id);
    return match[1];
}

function showAddDelete(id) {

    if (isFirstIndex(id)) {
        var deleteNode = document.getElementById(id + ".Delete");
        deleteNode.style.display = '';
        return;
     }
    var previousNodeId =  indexMinus (id, id);
    var addNode = document.getElementById(previousNodeId + ".Add");
    var deleteNode = document.getElementById(previousNodeId + ".Delete");
    addNode.style.display = '';
    deleteNode.style.display = '';

}

function deleteRow(id){
    if (isFirstIndex(id)) return;
    var node = document.getElementById (id);
      node.parentNode.removeChild(node);
}

function isFirstIndex(id) {
     var match = /([0-9]+)$/i.exec(id);
     return match != null && match[1] != null && match[1] == 1;
}


function deleteContainer(node, parentLevel) {
    var parent = parentContainer(node, parentLevel);
    deleteRow(parent.id);
    showAddDelete(parent.id);
    return false;
}

function addContainer(node, parentLevel) {
    var parent = parentContainer(node, parentLevel);
    cloneRow(parent.id);
    hideAddDelete(parent.id);
    return false;
}
