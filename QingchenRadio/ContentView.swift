import SwiftUI

struct ContentView: View {
    @EnvironmentObject var radio: RadioPlayer

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
                    VStack(spacing: 10) {
                        ForEach(radio.stations) { s in
                            StationRow(station: s,
                                       selected: radio.index == s.id,
                                       playing: radio.isPlaying && radio.index == s.id)
                                .contentShape(Rectangle())
                                .onTapGesture { radio.tune(to: s.id) }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
                .padding(.top, 16)
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
                Text("清晨音乐台")
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

// MARK: - 电台行

struct StationRow: View {
    let station: Station
    let selected: Bool
    let playing: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(station.art)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 0.5)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(.system(size: 15.5, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(station.subtitle)
                    .font(.system(size: 11.5))
                    .foregroundColor(Color(hex: 0x7E8CA1))
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            if playing {
                EqualizerBars()
                    .padding(.trailing, 6)
            } else {
                Text("\(station.kbps)k")
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundColor(Color(hex: 0x69768A))
                    .padding(.trailing, 4)
            }

            Image(systemName: playing ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 27))
                .foregroundColor(selected ? Color(hex: 0xD8B26A) : Color(hex: 0x3D4A5D))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .fill(Color.white.opacity(selected ? 0.075 : 0.032))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
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
        .frame(height: 15)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                on = true
            }
        }
    }

    private func bar(_ ratio: CGFloat) -> some View {
        Capsule()
            .fill(Color(hex: 0xD8B26A))
            .frame(width: 3, height: 15 * (on ? ratio : ratio * 0.4))
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
