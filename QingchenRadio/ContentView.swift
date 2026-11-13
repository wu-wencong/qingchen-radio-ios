import SwiftUI

struct ContentView: View {
    @EnvironmentObject var radio: RadioPlayer

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: 0x121F35), Color(hex: 0x080D15), Color(hex: 0x05070B)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                header
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(radio.stations) { s in
                            StationCell(station: s,
                                        selected: radio.index == s.id,
                                        playing: radio.isPlaying && radio.index == s.id)
                                .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .onTapGesture { radio.tune(to: s.id) }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 118)
                }
                .padding(.top, 12)
            }

            VStack {
                Spacer()
                nowBar
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { radio.autoStart() }
    }

    // MARK: - 顶部

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 5) {
                Text("私人电台")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundColor(.white)
                HStack(spacing: 6) {
                    if radio.isBuffering {
                        ProgressView()
                            .scaleEffect(0.6)
                            .frame(width: 10, height: 10)
                    }
                    Text(radio.statusText)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: 0x8A97AB))
                        .lineLimit(1)
                }
            }
            Spacer()
            LiveBadge(active: radio.isPlaying)
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
    }

    // MARK: - 底部播放条

    private var nowBar: some View {
        HStack(spacing: 11) {
            Image(radio.current.art)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 42, height: 42)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(radio.current.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(radio.isBuffering ? "缓冲中…" : (radio.isPlaying ? "直播中 · LIVE" : "已暂停"))
                    .font(.system(size: 11))
                    .foregroundColor(radio.isPlaying ? Color(hex: 0xD8B26A) : Color(hex: 0x7E8CA1))
            }
            Spacer(minLength: 4)

            Button(action: { radio.prev() }) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 34, height: 34)
            }

            Button(action: { radio.toggle() }) {
                ZStack {
                    Circle()
                        .fill(Color(hex: 0xD8B26A))
                        .frame(width: 46, height: 46)
                    if radio.isBuffering {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: 0x08101C)))
                    } else {
                        Image(systemName: radio.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: 0x08101C))
                            .offset(x: radio.isPlaying ? 0 : 1)
                    }
                }
            }

            Button(action: { radio.next() }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 34, height: 34)
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(hex: 0x151E2C))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.07), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.55), radius: 20, x: 0, y: 8)
        )
        .padding(.horizontal, 13)
        .padding(.bottom, 6)
    }
}

// MARK: - 电台卡片（3 列网格）

struct StationCell: View {
    let station: Station
    let selected: Bool
    let playing: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(station.art)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(selected ? 0.16 : 0.08), lineWidth: 0.5)
                )

            Text(station.name)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundColor(selected ? .white : Color(hex: 0xC3CEDA))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, 5)

            // 固定高度：播放时是跳动的三根条，不播时留空，
            // 这样切换台的时候卡片高度不会跳。
            Group {
                if playing {
                    EqualizerBars()
                } else {
                    Color.clear
                }
            }
            .frame(height: 12)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 14)
        .padding(.bottom, 9)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(selected ? 0.075 : 0.032))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(selected ? Color(hex: 0xD8B26A).opacity(0.55) : Color.white.opacity(0.045),
                        lineWidth: selected ? 1.2 : 0.5)
        )
    }
}

// MARK: - 跳动音频条

struct EqualizerBars: View {
    @State private var on = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 2.5) {
            bar(0.5)
            bar(1.0)
            bar(0.7)
        }
        .frame(height: 12)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                on = true
            }
        }
    }

    private func bar(_ ratio: CGFloat) -> some View {
        Capsule()
            .fill(Color(hex: 0xD8B26A))
            .frame(width: 2.6, height: 12 * (on ? ratio : ratio * 0.4))
    }
}

// MARK: - LIVE 呼吸灯

struct LiveBadge: View {
    let active: Bool
    @State private var on = false

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(active ? Color(hex: 0xE5484D) : Color(hex: 0x4C586A))
                .frame(width: 6, height: 6)
                .opacity(active ? (on ? 1.0 : 0.35) : 1.0)
            Text("LIVE")
                .font(.system(size: 9.5, weight: .heavy))
                .tracking(1.2)
                .foregroundColor(active ? .white : Color(hex: 0x6B7889))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5.5)
        .background(Capsule().fill(Color.white.opacity(0.075)))
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                on = true
            }
        }
    }
}

// MARK: - 颜色

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
