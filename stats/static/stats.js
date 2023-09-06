function render_graphs(pastes_last_hour, pastes_last_8_hours, pastes_last_day, pastes_last_3_days, pastes_last_week,
                       pastes_last_month, all_pastes, public_pastes, available_pastes, expire_soon_pastes, all_permanent) {

  am5.ready(function () {

    var barchart_root = am5.Root.new("div_barchart");

    barchart_root.setThemes([
      am5themes_Animated.new(barchart_root)
    ]);
    var barchart = barchart_root.container.children.push(am5xy.XYChart.new(barchart_root, {
      panX: true,
      panY: true,
      wheelX: "panX",
      wheelY: "zoomX",
      pinchZoomX: true
    }));
    var barchart_cursor = barchart.set("cursor", am5xy.XYCursor.new(barchart_root, {}));
    barchart_cursor.lineY.set("visible", false);
    var barchart_xRenderer = am5xy.AxisRendererX.new(barchart_root, {minGridDistance: 30});
    barchart_xRenderer.labels.template.setAll({
      rotation: -90,
      centerY: am5.p50,
      centerX: am5.p100,
      paddingRight: 15
    });
    barchart_xRenderer.grid.template.setAll({
      location: 1
    })
    var barchart_xAxis = barchart.xAxes.push(am5xy.CategoryAxis.new(barchart_root, {
      maxDeviation: 0.3,
      categoryField: "country",
      renderer: barchart_xRenderer,
      tooltip: am5.Tooltip.new(barchart_root, {})
    }));
    var barchart_yAxis = barchart.yAxes.push(am5xy.ValueAxis.new(barchart_root, {
      maxDeviation: 0.3,
      renderer: am5xy.AxisRendererY.new(barchart_root, {
        strokeOpacity: 0.1
      })
    }));
    var barchart_series = barchart.series.push(am5xy.ColumnSeries.new(barchart_root, {
      name: "Series 1",
      xAxis: barchart_xAxis,
      yAxis: barchart_yAxis,
      valueYField: "value",
      sequencedInterpolation: true,
      categoryXField: "country",
      tooltip: am5.Tooltip.new(barchart_root, {
        labelText: "{valueY}"
      })
    }));
    barchart_series.columns.template.setAll({cornerRadiusTL: 5, cornerRadiusTR: 5, strokeOpacity: 0});
    barchart_series.columns.template.adapters.add("fill", function (fill, target) {
      return barchart.get("colors").getIndex(barchart_series.columns.indexOf(target));
    });
    barchart_series.columns.template.adapters.add("stroke", function (stroke, target) {
      return barchart.get("colors").getIndex(barchart_series.columns.indexOf(target));
    });
    // var pastes_last_hour = parseInt("{{ all_last_hour }}");
    // var pastes_last_8_hours = parseInt("{{ all_last_8_hours }}");
    // var pastes_last_day = parseInt("{{ all_last_day }}");
    // var pastes_last_3_days = parseInt("{{ all_last_3_days }}");
    // var pastes_last_week = parseInt("{{ all_last_week }}");
    // var pastes_last_month = parseInt("{{ all_last_month }}");
    var barchart_data = [{
      country: "Last hour",
      value: pastes_last_hour
    }, {
      country: "Last 8 hours",
      value: pastes_last_8_hours
    }, {
      country: "Last day",
      value: pastes_last_day
    }, {
      country: "Last 3 days",
      value: pastes_last_3_days
    }, {
      country: "Last week",
      value: pastes_last_week
    }, {
      country: "Last month",
      value: pastes_last_month
    }];
    barchart_xAxis.data.setAll(barchart_data);
    barchart_series.data.setAll(barchart_data);
    barchart_series.appear(1000);
    barchart.appear(1000, 100);

    var piechart_root = am5.Root.new("div_piechart");
    piechart_root.setThemes([
      am5themes_Animated.new(piechart_root)
    ]);
    var piechart = piechart_root.container.children.push(
        am5percent.PieChart.new(piechart_root, {
          endAngle: 270
        })
    );
    var piechart_series = piechart.series.push(
        am5percent.PieSeries.new(piechart_root, {
          valueField: "value",
          categoryField: "category",
          endAngle: 270
        })
    );
    piechart_series.states.create("hidden", {
      endAngle: -90
    });
    // var all_pastes = parseInt("{{ all_pastes }}");
    // var public_pastes = parseInt("{{ all_public }}");
    // var available_pastes = parseInt("{{ all_available }}");
    // var expire_soon_pastes = parseInt("{{ all_expire_soon }}");
    piechart_series.data.setAll([{
      category: "All private pastes",
      value: all_pastes - public_pastes
    }, {
      category: "Public pastes that expire soon",
      value: expire_soon_pastes
    }, {
      category: "Public permanent pastes",
      value: all_permanent
    }, {
      category: "Other public non-expired pastes",
      value: available_pastes - expire_soon_pastes - all_permanent
    }, {
      category: "Public expired pastes",
      value: public_pastes - available_pastes
    },]);
    piechart_series.appear(1000, 100);

  }); // end am5.ready()
}
function render_user_graphs(user_pastes_last_hour, user_pastes_last_8_hours, user_pastes_last_day, user_pastes_last_3_days, user_pastes_last_week,
                       user_pastes_last_month, user_all_pastes, user_public_pastes, user_available_pastes, user_expire_soon_pastes, user_permanent) {

  am5.ready(function () {

    var barchart_root = am5.Root.new("div_userbarchart");

    barchart_root.setThemes([
      am5themes_Animated.new(barchart_root)
    ]);
    var barchart = barchart_root.container.children.push(am5xy.XYChart.new(barchart_root, {
      panX: true,
      panY: true,
      wheelX: "panX",
      wheelY: "zoomX",
      pinchZoomX: true
    }));
    var barchart_cursor = barchart.set("cursor", am5xy.XYCursor.new(barchart_root, {}));
    barchart_cursor.lineY.set("visible", false);
    var barchart_xRenderer = am5xy.AxisRendererX.new(barchart_root, {minGridDistance: 30});
    barchart_xRenderer.labels.template.setAll({
      rotation: -90,
      centerY: am5.p50,
      centerX: am5.p100,
      paddingRight: 15
    });
    barchart_xRenderer.grid.template.setAll({
      location: 1
    })
    var barchart_xAxis = barchart.xAxes.push(am5xy.CategoryAxis.new(barchart_root, {
      maxDeviation: 0.3,
      categoryField: "country",
      renderer: barchart_xRenderer,
      tooltip: am5.Tooltip.new(barchart_root, {})
    }));
    var barchart_yAxis = barchart.yAxes.push(am5xy.ValueAxis.new(barchart_root, {
      maxDeviation: 0.3,
      renderer: am5xy.AxisRendererY.new(barchart_root, {
        strokeOpacity: 0.1
      })
    }));
    var barchart_series = barchart.series.push(am5xy.ColumnSeries.new(barchart_root, {
      name: "Series 1",
      xAxis: barchart_xAxis,
      yAxis: barchart_yAxis,
      valueYField: "value",
      sequencedInterpolation: true,
      categoryXField: "country",
      tooltip: am5.Tooltip.new(barchart_root, {
        labelText: "{valueY}"
      })
    }));
    barchart_series.columns.template.setAll({cornerRadiusTL: 5, cornerRadiusTR: 5, strokeOpacity: 0});
    barchart_series.columns.template.adapters.add("fill", function (fill, target) {
      return barchart.get("colors").getIndex(barchart_series.columns.indexOf(target));
    });
    barchart_series.columns.template.adapters.add("stroke", function (stroke, target) {
      return barchart.get("colors").getIndex(barchart_series.columns.indexOf(target));
    });
    // var pastes_last_hour = parseInt("{{ all_last_hour }}");
    // var pastes_last_8_hours = parseInt("{{ all_last_8_hours }}");
    // var pastes_last_day = parseInt("{{ all_last_day }}");
    // var pastes_last_3_days = parseInt("{{ all_last_3_days }}");
    // var pastes_last_week = parseInt("{{ all_last_week }}");
    // var pastes_last_month = parseInt("{{ all_last_month }}");
    var barchart_data = [{
      country: "Last hour",
      value: user_pastes_last_hour
    }, {
      country: "Last 8 hours",
      value: user_pastes_last_8_hours
    }, {
      country: "Last day",
      value: user_pastes_last_day
    }, {
      country: "Last 3 days",
      value: user_pastes_last_3_days
    }, {
      country: "Last week",
      value: user_pastes_last_week
    }, {
      country: "Last month",
      value: user_pastes_last_month
    }];
    barchart_xAxis.data.setAll(barchart_data);
    barchart_series.data.setAll(barchart_data);
    barchart_series.appear(1000);
    barchart.appear(1000, 100);

    var piechart_root = am5.Root.new("div_userpiechart");
    piechart_root.setThemes([
      am5themes_Animated.new(piechart_root)
    ]);
    var piechart = piechart_root.container.children.push(
        am5percent.PieChart.new(piechart_root, {
          endAngle: 270
        })
    );
    var piechart_series = piechart.series.push(
        am5percent.PieSeries.new(piechart_root, {
          valueField: "value",
          categoryField: "category",
          endAngle: 270
        })
    );
    piechart_series.states.create("hidden", {
      endAngle: -90
    });
    // var all_pastes = parseInt("{{ all_pastes }}");
    // var public_pastes = parseInt("{{ all_public }}");
    // var available_pastes = parseInt("{{ all_available }}");
    // var expire_soon_pastes = parseInt("{{ all_expire_soon }}");
    piechart_series.data.setAll([{
      category: "Your private pastes",
      value: user_all_pastes - user_public_pastes
    }, {
      category: "Your pastes that expire soon",
      value: user_expire_soon_pastes
    }, {
      category: "Your permanent pastes",
      value: user_permanent
    }, {
      category: "Your other non-expired pastes",
      value: user_available_pastes - user_expire_soon_pastes - user_permanent
    }, {
      category: "Your expired pastes",
      value: user_public_pastes - user_available_pastes
    },]);
    piechart_series.appear(1000, 100);

  }); // end am5.ready()
}