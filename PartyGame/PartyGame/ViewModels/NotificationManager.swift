import Foundation
import Combine

struct NotificationItem: Codable, Identifiable {
    let id: String
    let title: String
    let body: String
    let date: String
    var isRead: Bool = false // Local property, default false
    
    enum CodingKeys: String, CodingKey {
        case id, title, body, date
    }
}

class NotificationManager: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    @Published var unreadCount: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let storageKey = "readNotificationIds"
    // Ideally this URL should exist. Example:
    private let dataURLString = "https://sato-monaka.github.io/PartyGame/notifications.json"
    
    init() {
        // Load stored read status? But we need notifications first.
        // Actually we might want to fetch on init or when view appears.
    }
    
    func fetchNotifications() {
        guard let url = URL(string: dataURLString) else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Cache policy to ignore local cache
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 10.0
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("Notification Fetch Error: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    // Fallback to demo data if network fails
                    self?.loadDemoData()
                    return
                }
                
                guard let data = data else {
                    print("Notification Error: No data received")
                    self?.errorMessage = "No data received"
                    self?.loadDemoData()
                    return
                }
                
                do {
                    let items = try JSONDecoder().decode([NotificationItem].self, from: data)
                    print("Notification Success: Loaded \(items.count) items")
                    self?.processNotifications(items)
                } catch {
                    print("Notification Parse Error: \(error)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Received JSON: \(jsonString)")
                    }
                    self?.errorMessage = "Failed to parse: \(error.localizedDescription)"
                    self?.loadDemoData()
                }
            }
        }.resume()
    }
    
    private func loadDemoData() {
        let demoJSON = """
        [
          {
            "id": "1",
            "title": "リリース記念！",
            "body": "サメゲーをインストールしてくれてありがとう！楽しんでね！",
            "date": "2024-01-01"
          },
          {
            "id": "2",
            "title": "新ゲーム追加のお知らせ",
            "body": "秘密の質問ゲームを追加しました！みんなで遊んでみてね。",
            "date": "2024-02-15"
          }
        ]
        """
        if let data = demoJSON.data(using: .utf8),
           let items = try? JSONDecoder().decode([NotificationItem].self, from: data) {
            self.processNotifications(items)
        }
    }
    
    private func processNotifications(_ items: [NotificationItem]) {
        let readIds = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        
        self.notifications = items.map { item in
            var newItem = item
            newItem.isRead = readIds.contains(item.id)
            return newItem
        }.sorted(by: { $0.id > $1.id })
        
        updateUnreadCount()
    }
    
    func markAsRead(_ item: NotificationItem) {
        if let index = notifications.firstIndex(where: { $0.id == item.id }) {
            notifications[index].isRead = true
            saveReadStatus()
            updateUnreadCount()
        }
    }
    
    func markAllAsRead() {
        for i in 0..<notifications.count {
            notifications[i].isRead = true
        }
        saveReadStatus()
        updateUnreadCount()
    }
    
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }
    
    private func saveReadStatus() {
        let readIds = notifications.filter { $0.isRead }.map { $0.id }
        UserDefaults.standard.set(readIds, forKey: storageKey)
    }
}
