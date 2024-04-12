//
//  ContentView.swift
//  RecognoscereApp
//
//  Created by Pedro Sousa on 18/02/24.
//

import SwiftUI
import Charts

struct ContentView: View {
    @State var controller = Controller()
    @State var showStochastic: Bool = true

    var body: some View {
        Text("No Interface")
        .onAppear {
            controller.run()
        }
//        ZStack {
//            charts
//            toggle
//        }
    }

//    @ViewBuilder var toggle: some View {
//        VStack {
//            HStack {
//                Toggle(isOn: $showStochastic, label: {
//                    Text("Simple")
//                })
//                .toggleStyle(.switch)
//
//                Text("Stochastic")
//
//                Spacer()
//            }
//            Spacer()
//        }
//        .padding()
//    }

//    @ViewBuilder
//    var charts: some View {
//        ZStack {
//            dataChart
//            simpleChart
////            if showStochastic {
////                stochasticChart
////            } else {
////                simpleChart
////            }
//        }
//    }

//    @ViewBuilder
//    var dataChart: some View {
//        Chart {
//            ForEach(0..<Controller.data.count, id: \.self) { index in
//                PointMark(x: .value("input", Controller.data[index][0]),
//                          y: .value("output", Controller.data[index][1]))
//                .foregroundStyle(Controller.inputTest.contains(Controller.data[index][0]) ? Color.red : Color.blue)
//            }
//        }
//    }
//
//    @ViewBuilder
//    var simpleChart: some View {
//        if controller.simpleReady {
//            Chart {
//                LineMark(x: .value("", -4),
//                         y: .value("", (try? controller.simple.predict([-4]).first) ?? 0))
//                LineMark(x: .value("", 4),
//                         y: .value("", (try? controller.simple.predict([4]).first) ?? 0))
//            }
//            .foregroundStyle(Color.yellow)
//        }
//    }

//    @ViewBuilder
//    var stochasticChart: some View {
//        if controller.stochasticReady {
//            Chart {
//                LineMark(x: .value("", -4),
//                         y: .value("", controller.stochastic.predict(-4)))
//                LineMark(x: .value("", 4),
//                         y: .value("", controller.stochastic.predict(4)))
//            }
//            .foregroundStyle(Color.green)
//        }
//    }
}

#Preview {
    ContentView()
}
