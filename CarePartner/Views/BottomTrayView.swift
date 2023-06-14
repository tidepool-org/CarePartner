//
//  BottomTrayView.swift
//  CarePartner
//
//  Created by Nathaniel Hamming on 2023-06-12.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import SwiftUI

protocol TrayContent: View {
    var visibleContentHeight: CGFloat { get }
    var discoverableContentHeight: CGFloat { get }
}

struct BottomTrayView<Content: TrayContent>: View {
    let backgroundColor: Color
    var content: () -> Content
    
    @State private var offset: CGFloat
    @State private var isClosing: Bool?
    
    private let visibleContentHeight: CGFloat
    private let discoverableContentHeight: CGFloat
    
    init(backgroundColor: Color = Color(.systemGroupedBackground), startClosed: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.backgroundColor = backgroundColor
        self.content = content
        self.visibleContentHeight = content().visibleContentHeight
        self.discoverableContentHeight = content().discoverableContentHeight
        self.offset = startClosed ? content().discoverableContentHeight : 0
    }
    
    private var isClosed: Bool { offset == discoverableContentHeight }
    private var isOpen: Bool { offset == 0 }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                trayHandle
                content()
            }
            .contentShape(Rectangle())
        }
        .padding(.horizontal, 17)
        .padding(.top, 22)
        .edgesIgnoringSafeArea(.bottom)
        .background(backgroundColor)
        .offset(x: 0, y: offset)
        .gesture(tapGesture)
        .gesture(dragGesture)
    }
    
    private var trayHandle: some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerSize: CGSize(width: 3, height: 3), style: .circular)
                .foregroundColor(Color(.init(gray: 0.8, alpha: 0.9)))
                .frame(width: 66, height: 4)
                .padding(.top, -10)
            Spacer()
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let moved = value.translation.height
                var newOffset: CGFloat? = nil
                if  moved >= 0, !isClosed {
                    // closing tray
                    newOffset = min(discoverableContentHeight, moved)
                } else if moved < 0, !isOpen {
                    // opening tray
                    newOffset = max(0, discoverableContentHeight+moved)
                    guard abs(offset - newOffset!) < 100 else {
                        // still opening, but moved now < 0 which creates a large jump in the offset. So open all the way
                        offset = 0
                        return
                    }
                }
                
                guard let newOffset = newOffset,
                      newOffset != offset
                else { return }
                
                isClosing = newOffset > offset
                offset = newOffset
            }
            .onEnded { value in
                guard let isClosing = isClosing else { return }
                self.isClosing = nil
                withAnimation {
                    offset = isClosing ? discoverableContentHeight : 0
                }
            }
    }
    
    private var tapGesture: some Gesture {
        TapGesture().onEnded(toggleTrayState)
    }
    
    private func toggleTrayState() {
        withAnimation(.default) {
            offset = offset > 0 ? 0 : discoverableContentHeight
        }
    }
}

struct BottomTrayView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            BottomTrayView() {
                PriviewTrayContentView()
            }
        }
    }
}

struct PriviewTrayContentView: TrayContent {
    let discoverableContentHeight: CGFloat = 110.0
    let visibleContentHeight: CGFloat = 10.0
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Visible content")
                Divider()
                Text("Discoverable content")
            }
            Button(action: { }) {
                HStack(alignment: .center) {
                    Spacer()
                    Text("Press me!")
                        .padding(10)
                    Spacer()
                }
            }
        }
    }
}
