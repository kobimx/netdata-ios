//
//  ServerDetailView.swift
//  netdata
//
//  Created by Arjun Komath on 12/7/20.
//

import SwiftUI
import Combine

struct ServerDetailView: View {
    var server: NDServer;
    var serverAlarms: ServerAlarms;
    var alarmStatusColor: Color;
    
    @StateObject var viewModel = ServerDetailViewModel()
    
    @State private var showAlarmsSheet = false
    @State private var showChartsSheet = false
    
    var body: some View {
        List {
            Section(header: makeSectionHeader(text: "CPU (%)")) {
                HStack {
                    VStack {
                        Meter(progress: viewModel.cpuUsageGauge)
                            .redacted(reason: self.viewModel.cpuUsage.labels.count < 1 ? .placeholder : .init())
                        
                        if (server.serverInfo != nil && viewModel.cpuUsage.labels.count > 0) {
                            Spacer()
                            
                            AbsoluteUsageData(stringValue: server.serverInfo?.cores_total,
                                              title: "cores",
                                              showArrows: false)
                        }
                    }
                    
                    self.getiPadSpacer()
                    
                    DataGrid(labels: viewModel.cpuUsage.labels,
                             data: viewModel.cpuUsage.data,
                             dataType: .percentage,
                             showArrows: false)
                }
            }
            .readableGuidePadding()
            
            Section(header: makeSectionHeader(text: "Load")) {
                DataGrid(labels: viewModel.load.labels,
                         data: viewModel.load.data,
                         dataType: .absolute,
                         showArrows: false)
            }
            .readableGuidePadding()
            
            Section(header: makeSectionHeader(text: "Memory (MiB)")) {
                HStack {
                    Meter(progress: viewModel.ramUsageGauge)
                        .redacted(reason: viewModel.ramUsage.labels.count < 1 ? .placeholder : .init())
                    
                    self.getiPadSpacer()
                    
                    DataGrid(labels: viewModel.ramUsage.labels,
                             data: viewModel.ramUsage.data,
                             dataType: .absolute,
                             showArrows: false)
                }
            }
            .readableGuidePadding()
            
            Section(header: makeSectionHeader(text: "Disk Space (GiB)")) {
                HStack {
                    Meter(progress: viewModel.diskSpaceUsageGauge)
                        .redacted(reason: viewModel.diskSpaceUsage.labels.count < 1 ? .placeholder : .init())
                    
                    self.getiPadSpacer()
                    
                    DataGrid(labels: viewModel.diskSpaceUsage.labels,
                             data: viewModel.diskSpaceUsage.data,
                             dataType: .absolute,
                             showArrows: false)
                }
            }
            .readableGuidePadding()
            
            Section(header: makeSectionHeader(text: "Disk I/O (KiB/s)")) {
                DataGrid(labels: viewModel.diskIO.labels,
                         data: viewModel.diskIO.data,
                         dataType: .absolute,
                         showArrows: true)
            }
            .readableGuidePadding()
            
            Section(header: makeSectionHeader(text: "Network (kilobits/s)")) {
                DataGrid(labels: viewModel.network.labels,
                         data: viewModel.network.data,
                         dataType: .absolute,
                         showArrows: true)
            }
            .readableGuidePadding()
        }
        .onAppear {
            self.viewModel.fetch(baseUrl: server.url)
            
            // hide scroll indicators
            UITableView.appearance().showsVerticalScrollIndicator = false
        }
        .onDisappear {
            self.viewModel.destroy()
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle(Text(server.name))
        .navigationBarItems(trailing:
                                HStack(spacing: 16) {
                                    Button(action: {
                                        self.showChartsSheet = true
                                    }) {
                                        Image(systemName: "chart.pie")
                                            .imageScale(.small)
                                            .foregroundColor(.accentColor)
                                    }
                                    .buttonStyle(BorderedBarButtonStyle())
                                    .sheet(isPresented: $showChartsSheet, content: {
                                        ChartsListView(serverCharts: viewModel.serverCharts, serverUrl: server.url)
                                    })
                                    
                                    Button(action: {
                                        self.showAlarmsSheet = true
                                    }) {
                                        Image(systemName: "bell")
                                            .imageScale(.small)
                                            .foregroundColor(self.alarmStatusColor)
                                    }
                                    .buttonStyle(BorderedBarButtonStyle())
                                    .accentColor(self.alarmStatusColor)
                                    .sheet(isPresented: $showAlarmsSheet, content: {
                                        AlarmsListView(serverAlarms: self.serverAlarms)
                                    })
                                }
        )
    }
    
    func makeSectionHeader(text: String) -> some View {
        Text(text)
            .sectionHeaderStyle()
    }
    
    func getiPadSpacer() -> AnyView? {
        #if targetEnvironment(macCatalyst)
        return AnyView(Spacer(minLength: 36))
        #else
        return UIDevice.current.userInterfaceIdiom == .pad ? AnyView(Spacer(minLength: 36)) : nil
        #endif
    }
}

