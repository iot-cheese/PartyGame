//
//  DrawingCanvasView.swift
//  PartyGame
//
//  Created by GitHub Copilot on 2026/02/15.
//

import SwiftUI
import PencilKit

enum DrawingTool {
    case pen
    case eraser
}

struct DrawingCanvasView: View {
    @Binding var drawing: UIImage?
    @State private var canvasView = PKCanvasView()
    @State private var currentTool: DrawingTool = .pen
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom toolbar
            HStack(spacing: 20) {
                Button(action: {
                    currentTool = .pen
                    canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
                }) {
                    VStack {
                        Image(systemName: "pencil")
                            .font(.title2)
                        Text("ペン")
                            .font(.caption)
                    }
                    .foregroundColor(currentTool == .pen ? .blue : .gray)
                    .frame(width: 80, height: 60)
                    .background(currentTool == .pen ? Color.blue.opacity(0.1) : Color.clear)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    currentTool = .eraser
                    canvasView.tool = PKEraserTool(.bitmap)
                }) {
                    VStack {
                        Image(systemName: "eraser.fill")
                            .font(.title2)
                        Text("消しゴム")
                            .font(.caption)
                    }
                    .foregroundColor(currentTool == .eraser ? .blue : .gray)
                    .frame(width: 80, height: 60)
                    .background(currentTool == .eraser ? Color.blue.opacity(0.1) : Color.clear)
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    canvasView.drawing = PKDrawing()
                    drawing = nil
                }) {
                    VStack {
                        Image(systemName: "trash")
                            .font(.title2)
                        Text("全消し")
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                    .frame(width: 80, height: 60)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            
            // Canvas
            CanvasViewRepresentable(canvasView: $canvasView, onDrawingChanged: { image in
                drawing = image
            })
        }
    }
}

struct CanvasViewRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var onDrawingChanged: (UIImage?) -> Void
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .white
        canvasView.delegate = context.coordinator
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        // Hide the default tool picker
        canvasView.isOpaque = false
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasViewRepresentable
        
        init(_ parent: CanvasViewRepresentable) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
            parent.onDrawingChanged(image)
        }
    }
}
