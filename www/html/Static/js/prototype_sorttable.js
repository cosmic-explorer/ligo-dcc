/*===========================================================================
  SORTABLE TABLES by Inventive Labs
  * Uses Prototype 1.5+ (http://prototype.conio.net/)

  Sort a table by clicking on a column heading. To make a table sortable,
  give it a class of 'sortable':

  <table class="sortable">
    <tr>
      <th sort="integer">ID</th>
      <th>Summary</th>
      <th sort="date">Occurred on</th>
    </tr>
    <tr> (some cells...) </tr>
  </table>

  The 'sort' attribute of the table cell headers determines the way that 
  the column is sorted. The default is case-insensitive alphabetical comparison.

  Note: during the sort, every other row is given a class of 'alt' - you can
  use this to alternate background colours & etc.

  Based on tableSort.js by Inigo Surguy (http://surguy.net). This file is made 
  available under the same Creative Commons Attribution-ShareAlike 2.5 license:
  http://creativecommons.org/licenses/by-sa/2.5/
---------------------------------------------------------------------------*/
SortableTable = function (table) {
  var me = this; 

  this.table = table;
  this.rows = $A(table.rows).map(function(r) { return $(r) });
  this.headerRow = this.rows.shift(); 
  this.headers = Selector.findChildElements(this.headerRow, ['th']);

  this.headers.each(function(th) {
    var span = $(document.createElement('span'));
    $A(th.childNodes).each(function(c) { span.appendChild(c); });
    th.appendChild(span);
    span.onclick = function () { me.sortOnColumn(th, span) }
  });
}

SortableTable.find = function () {
  $$('table.sortable').each(function(table) { new SortableTable(table) })
}

SortableTable.prototype.simpleCompare = function(a,b) { 
  return a < b ? -1 : a == b ? 0 : 1; 
};

SortableTable.prototype.compareComposer = function(normalizeFn) { 
  var me = this;
  return function(a,b) {return me.simpleCompare(normalizeFn(a), normalizeFn(b))}
}

// Add any new comparison functions you need to this switch statement.
SortableTable.prototype.compareFunction = function (sType) { 
  switch (sType) {
    case "caseSensitive": 
      return this.simpleCompare;
    case "integer": 
      // Extracts the first numeric part of a string
      return this.compareComposer(function(a) { 
        return parseInt(a.replace(/^.*?(\d+).*$/,"$1")) 
      });
    case "float":
      // Similar, but permits floating points (.)
      return this.compareComposer(function(a) { 
        return parseFloat(a.replace(/^.*?([\d\.]+).*$/,"$1")) 
      });
    case "date": 
      // Expects an ISO date format "13 MAR 2006 10:17:02 GMT"
      return this.compareComposer(Date.parse)
    default:
      return this.compareComposer(function(a) { return a.toLowerCase(); });
  }
}

SortableTable.prototype.sortOnColumn = function (th, span) {
  // figure out which column this is
  var pos = $A(this.headerRow.cells).indexOf(th);

  // do the sort
  var sortFn = this.compareFunction(th.getAttribute('sort'));
  span.order = span.order || 1;
  this.rows.sort(
    function (rowA, rowB) { 
      return span.order * sortFn(rowA.getCellText(pos), rowB.getCellText(pos)); 
    }
  );
  span.order *= -1;

  // rearrange the rows based on sort results
  var alt = 0;
  var tbody = this.table.tBodies[0];
  this.rows.each(function(row) { 
    if ((alt += 1) % 2) { 
      if (!row.hasClassName('alt')) { row.addClassName('alt') } 
    } else {
      row.removeClassName('alt');
    }
    tbody.appendChild(row);
  });
}

Element.addMethods({
  getText:function(e){return e.text = e.text||e.textContent||e.innerText||''},
  getCellText: function(row, pos) { 
    row.cellTexts = row.cellTexts || [];
    row.cellTexts[pos] = row.cellTexts[pos] || row.down("td", pos).getText(); 
    return row.cellTexts[pos];
  }
});

Event.observe(window, 'load', SortableTable.find, false);
