(window as any).renderTimelineStats = (
    chartId: string,
    dataTable: any[][],
    mbRange: number,
    mbLimit: number,
    mbTicks: number[],
    dayTicks: number[] ) => {
  function drawChart() {
    const data = new google.visualization.DataTable();
    data.addColumn("number", "Day");
    data.addColumn("number", "2 Month Ago");
    data.addColumn("number", "Last Month");
    data.addColumn("number", "Now");
    data.addRows(dataTable);

    const options: google.visualization.LineChartOptions = {
      title: "SIM Stats Log",

      backgroundColor: "aliceblue",
      width: 960,
      height: 540,

      lineWidth: 2,
      colors: ["#FFFF7F", "#BFFFBF", "#7FFF7F"],
      curveType: "none",

      pointShape: "circle",
      pointSize: 0,
      pointsVisible: true,

      chartArea: {
        backgroundColor: "mintcream",
        width: 840,
        height: 440,
        left: 100,
        top: 30,
      },

      hAxis: {
        gridlines: {
          color: "whitesmoke",
        },
        ticks: dayTicks,
        slantedText: true,
        slantedTextAngle: 90,
        showTextEvery: 1,
        textStyle: {
          color: "black",
        },
      },

      vAxis: {
        baseline: mbLimit,
        baselineColor: "#FFBF7F",
        gridlines: {
          color: "whitesmoke",
        },
        ticks: mbTicks,
        maxValue: mbRange,
        minValue: 0,
        showTextEvery: 1,
        textStyle: {
          color: "black",
        },
      },

      crosshair: {
        color: "cyan",
        trigger: "both",
      },

      legend: {
        position: "in",
        alignment: "start",
      },
    };

    const chart = new google.visualization.LineChart(document.getElementById(chartId));
    chart.draw(data, options);
  }

  google.charts.load('current', {'packages':['corechart']});
  google.charts.setOnLoadCallback(drawChart);
};

