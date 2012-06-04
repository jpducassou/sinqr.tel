//sqrt_basics
/*
Define setObject on localStorage
getObject = null if key not present instead of throwing Illegal access exception.
*/
var sqrt = {
  getSiteRoot:function() {
    return "http://www.sinqrtel.com";
  },
  getSiteObjectInfoPath:function() {
    return "/objectinfo/";
  },
  //function sqrt_sortTimeStamps(a,b) {return parseInt(a[0]) - parseInt(b[0]);}
  getTimeStamp:function() {
    return Math.round((new Date()).getTime() / 1000 );
  },
  sumAndUpdateScoresToTimeStamp:function( scoreArray, timeStamp ) {
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
  },
  getObjectInfo:function( objectName, success ) {
    $.getJSON( sqrt_getSiteRoot() + sqrt_getSiteObjectInfoPath() + objectName, success );
  },
  addLocalScore:function( scoreArray, score, timeStamp ) {
    scoreArray.push( [timeStamp, score] );
  },
  storeScore:function( scoreArray ) {
    localStorage.setItem('score', JSON.stringify(scoreArray ));
  },
  loadScore:function() {
    return JSON.parse(this.getItem('score'));
  },
}