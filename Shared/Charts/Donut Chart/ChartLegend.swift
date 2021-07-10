//
//  ChartLegend.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 23.04.21.
//

import SwiftUI

struct DonutLegendEntry: View {
    let value: DonutLegendEntryValue
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(maxWidth: 10, maxHeight: 10)
            Text(value.xAxisValue)
                .foregroundColor(isSelected ? .cardBackground : .primary)
            Spacer()
            SmallValueView(value: value.yAxisValue, shouldFormatBigNumbers: true)
                .foregroundColor(isSelected ? .cardBackground : .primary)
                .smallValueStyle()
        }
        .subtitleStyle()
    }
}

struct DonutLegendEntryValue: Identifiable {
    let id: Int
    let xAxisValue: String
    let yAxisValue: Double
    let dataPoint: ChartDataPoint?
}

struct DonutLegend: View {
    let chartDataPoints: [ChartDataPoint]
    let isSelected: Bool
    
    @Binding var hoveringDataPoint: ChartDataPoint?
    
    private var donutLegendEntryValues: [DonutLegendEntryValue] {
        var values: [DonutLegendEntryValue] = []
        
        for (index, data) in chartDataPoints.enumerated() {
            let value = DonutLegendEntryValue(id: index, xAxisValue: data.xAxisValue, yAxisValue: data.yAxisDouble ?? 0, dataPoint: data)
            values.append(value)
        }
        
        let totalSum: Double = chartDataPoints.reduce(0.0) { result, chartDataPoint in
            result + (chartDataPoint.yAxisDouble ?? 0)
        }
        
        values.append(.init(id: -1, xAxisValue: "Total", yAxisValue: totalSum, dataPoint: nil))
        
        return values
    }
    
    func opacity(segmentCount: Double, index: Int) -> Double {
        (Double(1) / segmentCount) * (segmentCount - Double(index))
    }
    
    func color(for index: Int) -> Color {
        guard index >= 0 else { return Color.clear }
        return Color.accentColor.opacity(opacity(segmentCount: Double(donutLegendEntryValues.count), index: index))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(donutLegendEntryValues) { value in
                ZStack {
                    if value.dataPoint == hoveringDataPoint && value.dataPoint != nil {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.grayColor.opacity(0.3))
                            .frame(maxHeight: 22)
                    }
                    
                    DonutLegendEntry(value: value, color: color(for: value.id), isSelected: isSelected)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .opacity(value.id < 0 ? 0.5 : 1.0)
                }
                .onHover { hovering in
                    if hovering {
                        hoveringDataPoint = value.dataPoint
                    } else {
                        hoveringDataPoint = nil
                    }
                }
                #if os(iOS)
                    .onTapGesture {
                        hoveringDataPoint = value.dataPoint
                    }
                #endif
            }
        }
    }
}

struct DonutLegendPreviews: PreviewProvider {
    static var previews: some View {
        let chartDataPoints = [
            ChartDataPoint(xAxisValue: "test", yAxisValue: "12"),
            ChartDataPoint(xAxisValue: "test2", yAxisValue: "13"),
            ChartDataPoint(xAxisValue: "test3", yAxisValue: "16"),
            ChartDataPoint(xAxisValue: "test4", yAxisValue: "19"),
        ]
        
        DonutLegend(chartDataPoints: chartDataPoints, isSelected: false, hoveringDataPoint: .constant(chartDataPoints.last!))
            .previewLayout(.fixed(width: 145, height: 165))
    }
}
