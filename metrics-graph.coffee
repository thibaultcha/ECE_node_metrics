metrics = data.metrics

margin = {top: 20, right: 20, bottom: 30, left: 50}
width  = 960 - margin.left - margin.right
height = 500 - margin.top - margin.bottom

x = d3.time.scale().range [0, width]
y = d3.scale.linear().range [height, 0]
xAxis = d3.svg.axis().scale(x).orient "bottom"
yAxis = d3.svg.axis().scale(y).orient "left"

area = d3.svg.area()
  .x (m) ->
    return x m.timestamp
  .y0(height)
  .y1 (m) ->
    return y m.value

svg = d3.select("#graph").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

x.domain d3.extent metrics, (m) ->
  return m.timestamp
y.domain [0, d3.max metrics, (m) ->
  return m.value]

svg.append("path")
    .datum(metrics)
    .attr("class", "area")
    .attr("d", area)

svg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0, " + height + ")")
    .call(xAxis)
    .append("text")
      .text("Time")

svg.append("g")
    .attr("class", "y axis")
    .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .style("text-anchor", "end")
      .text("Value")