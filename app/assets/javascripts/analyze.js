function complete(data) {
  //console.log(JSON.stringify(data));
  
  $("#pony_winner").html(data.winner.name);
  $("#pony_desc").html(data.winner.description);
  $("#pony_img").attr('src', '../images/ponies/' + data.winner.short_name + '.png');
  
  for(var i = 0; i < data.tweets.length; i++) {
    var html = data.tweets[i].pony + " (" + data.tweets[i].percent + "%): " + data.tweets[i].text;
    if($("#tweets").html() != "")
      $("#tweets").html($("#tweets").html()+"<br />");
    $("#tweets").html($("#tweets").html()+html);
  }
  
  var chart_data = new google.visualization.DataTable();
  chart_data.addColumn('string', 'Pony');
  chart_data.addColumn('number', 'Score');
  chart_data.addRows(data.stats);
  // Set chart options
  var options = {
    'title':'Pony Statistics',
    'height':$("#pony_img").attr('height'),
    'backgroundColor':'#FAAFBA',
    'chartArea':{'width':'100%','height':'100%'},
    'legend':{'alignment':'center'},
    'pieSliceText':'percentage',
    'pieSliceBorderColor':'#6C2DC7',
    'tooltip':{'text':'percentage'}
  };

  // Instantiate and draw our chart, passing in some options.
  var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
  chart.draw(chart_data, options);
  
  $("#analyzing").hide();
  $("#results").show();
}

$(document).ready(function() {
  $.getJSON("analyze", complete);
});