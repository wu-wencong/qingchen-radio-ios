import Foundation

struct Station: Identifiable {
    let id: Int
    let name: String
    let subtitle: String
    let kbps: Int
    let art: String
    let urlString: String

    var url: URL { URL(string: urlString)! }

    static let all: [Station] = [
        Station(id: 0,
                name: "清晨音乐台",
                subtitle: "晨间轻音乐 · 主台",
                kbps: 66,
                art: "mark",
                urlString: "https://ls.qingting.fm/live/4915.m3u8"),

        Station(id: 1,
                name: "891 线上音乐台",
                subtitle: "华语流行 · 高码率",
                kbps: 140,
                art: "st891",
                urlString: "https://live.fm891.net/192k.aac"),

        Station(id: 2,
                name: "怀集音乐之声",
                subtitle: "粤语怀旧 · 广东",
                kbps: 67,
                art: "sthj",
                urlString: "https://ls.qingting.fm/live/4804.m3u8"),

        Station(id: 3,
                name: "FM99.9 犀牛音乐",
                subtitle: "音乐 · 鹿泉融媒",
                kbps: 64,
                art: "stlq",
                urlString: "https://live.xmcdn.com/live/2572/64.m3u8")
    ]
}
