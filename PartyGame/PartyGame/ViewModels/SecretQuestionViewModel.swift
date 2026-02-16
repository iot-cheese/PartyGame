//
//  SecretQuestionViewModel.swift
//  PartyGame
//
//  Created by github_copilot on 2026/02/15.
//

import Foundation
import MultipeerConnectivity
import Combine

enum SecretQuestionPhase {
    case entry
    case lobby
    case questionInput
    case answering
    case results
}

struct SecretQuestionPeer: Identifiable, Codable {
    var id: String
    var name: String
}

// Ensure Hashable conformance for using in ForEach, etc.
extension SecretQuestionPeer: Hashable {}

struct QuestionData: Codable, Identifiable {
    var id: UUID = UUID()
    var text: String
    var senderId: String
    var yesCount: Int = 0
    var noCount: Int = 0
}

enum MessageType: String, Codable {
    case joinRequest
    case acceptJoin
    case startGame
    case submitQuestion
    case distributeCurrentQuestion
    case submitAnswer
    case finishAnswering
    case showResults
}

struct GameMessage: Codable {
    let type: MessageType
    let payload: Data?
}

class SecretQuestionViewModel: NSObject, ObservableObject {
    @Published var currentPhase: SecretQuestionPhase = .entry
    @Published var userName: String = "" {
        didSet {
            UserDefaults.standard.set(userName, forKey: "secretQuestionUserName")
        }
    }
    @Published var roomCode: String = ""
    @Published var isHost: Bool = false
    @Published var connectedPeers: [MCPeerID] = []
    @Published var errorMessage: String?
    
    // Game State
    @Published var timeLeft: Int = 30
    @Published var selectedQuestionTime: Int = 30 // Host selected time
    @Published var currentQuestionIndex: Int = 0
    @Published var questions: [QuestionData] = []
    @Published var currentQuestion: QuestionData?
    @Published var showAnswerButtons: Bool = false
    @Published var myQuestionText: String = ""
    @Published var hasSubmittedQuestion: Bool = false
    @Published var hasAnsweredCurrent: Bool = false
    @Published var isMyQuestion: Bool = false // Check if current question is mine
    
    private let serviceTypePrefix = "secret-"
    private var serviceType: String?
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private var myPeerId: MCPeerID?
    
    private var timer: AnyCancellable?
    
    override init() {
        super.init()
        let savedName = UserDefaults.standard.string(forKey: "secretQuestionUserName")
        if let name = savedName, !name.isEmpty, name.hasPrefix("匿名") {
             self.userName = name
        } else {
             // Generate a random anonymous name if not set or invalid
             self.userName = "匿名\(Int.random(in: 100...999))"
        }
    }
    
    func createRoom() {
        guard !userName.isEmpty, !roomCode.isEmpty else {
            errorMessage = "合言葉を入力してください"
            return
        }
        
        let validServiceType = generateServiceType(from: roomCode)
        guard validServiceType.count <= 15 else {
            errorMessage = "合言葉が長すぎます（短くしてください）"
            return
        }
        
        startHosting(serviceType: validServiceType)
    }
    
    func joinRoom() {
        guard !userName.isEmpty, !roomCode.isEmpty else {
            errorMessage = "合言葉を入力してください"
            return
        }
        
        let validServiceType = generateServiceType(from: roomCode)
        startJoining(serviceType: validServiceType)
    }
    
    private func generateServiceType(from code: String) -> String {
        // Simple sanitization: lowercase, maintain length constraint
        // Ideally should hash, but let's try to keep it readable if simple
        // Using "sec-" prefix to ensure unique for this game
        let allowed = CharacterSet.lowercaseLetters.union(CharacterSet.decimalDigits).union(CharacterSet(charactersIn: "-"))
        let sanitized = code.lowercased().components(separatedBy: allowed.inverted).joined()
        let prefix = "sec-"
        let maxLength = 15 - prefix.count
        let truncated = String(sanitized.prefix(maxLength))
        return prefix + truncated
    }
    
    private func startHosting(serviceType: String) {
        self.serviceType = serviceType
        self.isHost = true
        self.myPeerId = MCPeerID(displayName: userName)
        self.session = MCSession(peer: myPeerId!, securityIdentity: nil, encryptionPreference: .required)
        self.session?.delegate = self
        
        self.advertiser = MCNearbyServiceAdvertiser(peer: myPeerId!, discoveryInfo: ["roomName": roomCode], serviceType: serviceType)
        self.advertiser?.delegate = self
        self.advertiser?.startAdvertisingPeer()
        
        self.currentPhase = .lobby
        self.errorMessage = nil
    }
    
    private func startJoining(serviceType: String) {
        self.serviceType = serviceType
        self.isHost = false
        self.myPeerId = MCPeerID(displayName: userName)
        self.session = MCSession(peer: myPeerId!, securityIdentity: nil, encryptionPreference: .required)
        self.session?.delegate = self
        
        self.browser = MCNearbyServiceBrowser(peer: myPeerId!, serviceType: serviceType)
        self.browser?.delegate = self
        self.browser?.startBrowsingForPeers()
        
        self.currentPhase = .lobby // Or a specialized "Searching" state
        self.errorMessage = "部屋を探しています..."
    }
    
    func startGame() {
        guard isHost else { return }
        // Send selected time with start message
        let payload = try? JSONEncoder().encode(selectedQuestionTime)
        sendToAll(MessageType.startGame, payload: payload)
        startQuestionInputPhase(duration: selectedQuestionTime)
    }
    
    private func startQuestionInputPhase(duration: Int = 30) {
        DispatchQueue.main.async { [weak self] in
            self?.currentPhase = .questionInput
            self?.timeLeft = duration
            self?.questions = []
            self?.myQuestionText = ""
            self?.hasSubmittedQuestion = false
            self?.startTimer(duration: duration) {
                // Time up for questions
                self?.submitQuestion() // Auto submit if anything typed
                if self?.isHost == true {
                     self?.processQuestions()
                }
            }
        }
    }
    
    func submitQuestion() {
        guard !hasSubmittedQuestion else { return }
        hasSubmittedQuestion = true
        
        // Use a unique ID or rely on senderId if unique per game
        let question = QuestionData(text: myQuestionText.isEmpty ? "質問なし" : myQuestionText, senderId: myPeerId?.displayName ?? "Unknown", yesCount: 0, noCount: 0)
        
        if isHost {
            questions.append(question)
            checkAllQuestionsReceived()
        } else {
            if let data = try? JSONEncoder().encode(question) {
                sendToHost(MessageType.submitQuestion, payload: data)
            }
        }
    }
    
    private func checkAllQuestionsReceived() {
        // Host logic: check if questions count matches peers + host
        if questions.count == connectedPeers.count + 1 {
            // All received
            timer?.cancel()
            processQuestions()
        }
    }
    
    private func processQuestions() {
        // Host logic: shuffle and start answering
        questions.shuffle()
        currentQuestionIndex = 0
        startAnsweringPhase()
    }
    
    private func startAnsweringPhase() {
        guard currentQuestionIndex < questions.count else {
            finishGame()
            return
        }
        
        let question = questions[currentQuestionIndex]
        if let data = try? JSONEncoder().encode(question) {
            sendToAll(MessageType.distributeCurrentQuestion, payload: data)
            setupAnswering(question: question)
        }
    }
    
    private func setupAnswering(question: QuestionData) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currentPhase = .answering
            self.currentQuestion = question
            self.timeLeft = 8
            self.showAnswerButtons = true
            self.hasAnsweredCurrent = false
            
            // Check if it is my question
            self.isMyQuestion = (question.senderId == self.myPeerId?.displayName)
            
            self.startTimer(duration: 8) {
                if self.isHost == true {
                    self.finishCurrentQuestion()
                }
            }
        }
    }
    
    func submitAnswer(answer: Bool) {
        // Can't answer own question
        if isMyQuestion { return }
        guard !hasAnsweredCurrent else { return }
        hasAnsweredCurrent = true
        
        if isHost {
            recordAnswer(yes: answer)
        } else {
            let answerData = ["yes": answer]
            if let data = try? JSONEncoder().encode(answerData) {
                sendToHost(MessageType.submitAnswer, payload: data)
            }
        }
    }
    
    private func recordAnswer(yes: Bool) {
        guard let q = currentQuestion else { return }
        // Find in master list
        if let index = questions.firstIndex(where: { $0.id == q.id }) {
            if yes { questions[index].yesCount += 1 }
            else { questions[index].noCount += 1 }
            // Update current for host view potentially
            currentQuestion = questions[index]
            
            checkAllAnswersReceived(for: questions[index])
        }
    }
    
    private func checkAllAnswersReceived(for question: QuestionData) {
        // Total expected answers = Total Players - 1 (The question asker)
        let totalPlayers = connectedPeers.count + 1
        let expectedAnswers = max(totalPlayers - 1, 1) // Avoid 0 if solo testing
        let currentAnswers = question.yesCount + question.noCount
        
        if currentAnswers >= expectedAnswers {
            finishCurrentQuestion()
        }
    }
    
    private func finishCurrentQuestion() {
        timer?.cancel()
        // Host: move to next
        currentQuestionIndex += 1
        startAnsweringPhase()
    }
    
    private func finishGame() {
        if let data = try? JSONEncoder().encode(questions) {
            sendToAll(MessageType.showResults, payload: data)
            showResultsPhase(questions: questions)
        }
    }
    
    private func showResultsPhase(questions: [QuestionData]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Filter to show only my question
            self.questions = questions.filter { $0.senderId == self.myPeerId?.displayName }
            self.currentPhase = .results
            self.timer?.cancel()
        }
    }
    
    func resetGame() {
        // Back to lobby
        stopSession() // Actually maybe just back to entry?
        currentPhase = .entry
        questions = []
    }
    
    func quitLobby() {
        stopSession()
        currentPhase = .entry
        errorMessage = nil
        questions = []
        myQuestionText = ""
        hasSubmittedQuestion = false
    }

    func returnToLobby() {
        currentPhase = .lobby
        errorMessage = nil
        // Reset game state for next round if needed
        questions = []
        myQuestionText = ""
        hasSubmittedQuestion = false
        // DO NOT stop session, stay connected
    }
    
    private func startTimer(duration: Int, completion: @escaping () -> Void) {
        timer?.cancel() // Cancel previous
        timeLeft = duration
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeLeft > 0 {
                    self.timeLeft -= 1
                } else {
                    self.timer?.cancel()
                    completion()
                }
            }
    }
    
    // MARK: - Multipeer Helpers
    
    private func sendToHost(_ type: MessageType, payload: Data?) {
        guard let session = session, !session.connectedPeers.isEmpty else { return }
        // Assuming first peer is host if not isHost?
        // Actually browser connects to advertiser. Advertiser is Host.
        // So for joiners, they should send to all connected peers (which is just the host usually).
        sendToAll(type, payload: payload)
    }
    
    private func sendToAll(_ type: MessageType, payload: Data?) {
        guard let session = session, !session.connectedPeers.isEmpty else { return }
        let message = GameMessage(type: type, payload: payload)
        if let data = try? JSONEncoder().encode(message) {
            try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
    }
    
    private func stopSession() {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        session?.disconnect()
        connectedPeers = []
    }
}

// MARK: - MCSessionDelegate
extension SecretQuestionViewModel: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            self?.connectedPeers = session.connectedPeers
            if state == .connected {
               if self?.currentPhase == .entry {
                    self?.currentPhase = .lobby // Go to lobby when connected
                    self?.errorMessage = nil // Clear "Searching..."
               }
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = try? JSONDecoder().decode(GameMessage.self, from: data) else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.handleMessage(message, from: peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - Message Handling
extension SecretQuestionViewModel {
    func handleMessage(_ message: GameMessage, from peerID: MCPeerID) {
        switch message.type {
        case .startGame:
            let duration = (try? JSONDecoder().decode(Int.self, from: message.payload ?? Data())) ?? 30
            startQuestionInputPhase(duration: duration)
            
        case .submitQuestion:
            if isHost, let payload = message.payload, let question = try? JSONDecoder().decode(QuestionData.self, from: payload) {
                questions.append(question)
                checkAllQuestionsReceived()
            }
            
        case .distributeCurrentQuestion:
            if let payload = message.payload, let question = try? JSONDecoder().decode(QuestionData.self, from: payload) {
                setupAnswering(question: question)
            }
            
        case .submitAnswer:
            if isHost, let payload = message.payload, let answerData = try? JSONDecoder().decode([String: Bool].self, from: payload), let ans = answerData["yes"] {
                recordAnswer(yes: ans)
            }
            
        case .showResults:
            if let payload = message.payload, let results = try? JSONDecoder().decode([QuestionData].self, from: payload) {
                showResultsPhase(questions: results)
            }
            
        default: break
        }
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension SecretQuestionViewModel: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Auto-accept everything for now
        invitationHandler(true, self.session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension SecretQuestionViewModel: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // Auto-invite if found
        guard let session = session else { return }
        // check info if needed
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}
