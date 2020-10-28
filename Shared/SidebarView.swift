//
//  SidebarView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.08.20.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var api: APIRepresentative
    @Binding var selectedApp: TelemetryApp?
    @State var isCreatingANewApp: Bool = false
    
    var body: some View {
        List(selection: $selectedApp) {
            
            Section(header: Text("Apps")) {
                
                ForEach(Array(api.apps), id: \.self) { app in
                    if app.isMockData {
                        
                        NavigationLink(
                            destination: InsightGroupList(app: app),
                            label: {
                                Label(app.name, systemImage: "app.badge")
                            }
                        )
                        .redacted(reason: .placeholder)
                    } else {
                        NavigationLink(
                            destination: InsightGroupList(app: app),
                            label: {
                                Label(app.name, systemImage: "app.badge")
                            }
                        )
                    }
                }
            }
            
            Section(header: Text("You")) {
                
                if let apiUser = api.user {
                    
                    NavigationLink(destination: UserSettingsView(), label: {
                        Label("\(apiUser.firstName) \(apiUser.lastName)", systemImage: "person.circle")
                    })
                    
                    
                    NavigationLink(destination: OrganizationSettingsView(), label: {
                        Label(apiUser.organization?.name ?? "Unknown Org", systemImage: "app.badge")
                    })
                } else {
                    Label("firstName lastName", systemImage: "person.circle").redacted(reason: .placeholder)
                    Label("organization.name", systemImage: "app.badge").redacted(reason: .placeholder)
                }
            }
            
            if api.user?.organization?.isSuperOrg == true {
                Section(header: Text("Administration")) {
                    NavigationLink(
                        destination: BetaRequestsList(),
                        label: {
                            Label("Beta Requests", systemImage: "app.badge")
                        }
                    )
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("All Apps")
        .onAppear {
            selectedApp = api.apps.first
        }
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                HStack {
                    Button(action: {
                        isCreatingANewApp = true
                    }) {
                        Label("New App", systemImage: "plus.app.fill")
                    }
                    .sheet(isPresented: $isCreatingANewApp) {
                        NewAppView(isPresented: $isCreatingANewApp)
                    }
                }
            }
        }
    }
}
