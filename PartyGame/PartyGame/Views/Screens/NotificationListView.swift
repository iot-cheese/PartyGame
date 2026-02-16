//
//  NotificationListView.swift
//  PartyGame
//
//  Created by Daniel on 2026/02/16.
//

import SwiftUI

struct NotificationListView: View {
    @ObservedObject var notificationManager: NotificationManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                if notificationManager.isLoading {
                    ProgressView("読み込み中...")
                } else if notificationManager.notifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("お知らせはありません")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(notificationManager.notifications) { item in
                                NotificationCard(item: item)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationBarTitle("お知らせ", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title2)
            })
            .onAppear {
                // Fetch latest notifications just in case
                notificationManager.fetchNotifications()
                
                // Mark all as read after a short delay so user can see "NEW" badge briefly
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    notificationManager.markAllAsRead()
                }
            }
        }
    }
}

struct NotificationCard: View {
    let item: NotificationItem
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                // Icon or Indicator
                ZStack {
                    Circle()
                        .fill(item.isRead ? Color.gray.opacity(0.1) : Color.blue.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "bell.fill")
                        .foregroundColor(item.isRead ? .gray : .blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        if !item.isRead {
                            Text("NEW")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(4)
                        }
                        
                        Text(item.date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(isExpanded ? nil : 2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                if !isExpanded {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            if isExpanded {
                Divider()
                Text(item.body)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
    }
}


