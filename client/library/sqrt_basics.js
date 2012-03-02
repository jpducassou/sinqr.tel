//sqrt_basics
/*
Define setObject on localStorage
getObject = null if key not present instead of throwing Illegal access exception.
*/
Storage.prototype.setObject = function(key, value) {
    this.setItem(key, JSON.stringify(value));
}

Storage.prototype.getObject = function(key) {
    var value = this.getItem(key);
    if (value==undefined) {
      return value;
    } else {
      //ERROR on undefined: "return value && JSON.parse(value);"
      return JSON.parse(value);
    }
}

function sqrt_getSiteRoot() {
    return "http://www.sinqrtel.com";
}

function sqrt_getSiteObjectInfoPath() {
    return "/objectinfo/";
}

function sqrt_sortTimeStamps(a,b) {return parseInt(a[0]) - parseInt(b[0]);}
function sqrt_getTimeStamp() { return Math.round((new Date()).getTime() / 1000 ); };
function sqrt_sumAndUpdateScoresToTimeStamp( scoreArray, timeStamp ) {
  var sum = 0;
  var scoreIterator = 0;
  while( scoreIterator < scoreArray.length ) {
    if ( scoreArray[scoreIterator][0] > timeStamp ) {
      sum+=scoreArray[scoreIterator][1];
      scoreIterator++;
    } else {
      //delete one, iterator should not be incremented
      scoreArray.splice(scoreIterator,1);
    }
  }
  return sum;
}

function sqrt_getObjectInfo( hash ) {
  $.getJSON( sqrt_getSiteRoot() + sqrt_getSiteObjectInfoPath() + hash );
}

function sqrt_addLocalScore( scoreArray, score, timeStamp ) {
  scoreArray.push( [timeStamp, score] );
}

function sqrt_storeScore( scoreArray ) {
  localStorage.setObject( 'score', scoreArray );
}
