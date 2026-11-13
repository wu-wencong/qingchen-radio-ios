import Foundation

/// 一路音源。同一个台常挂在两家 CDN 上，内容一样，
/// 某一家解析不了时自动换下一路，用户无感。
struct Source {
    let name: String
    let urlString: String
    let kbps: Int

    var url: URL { URL(string: urlString)! }
}

struct Station: Identifiable {
    let id: Int
    let name: String
    let subtitle: String
    let art: String
    let sources: [Source]

    /// 主源码率，卡片上显示用
    var kbps: Int { sources.first?.kbps ?? 0 }

    var url: URL { sources[0].url }

    // 12 台，顺序与安卓手机版 / 车机版 / TV 版完全一致
    static let all: [Station] = [
        Station(id: 0,
                name: "清晨音乐台",
                subtitle: "晨间轻音乐",
                art: "st_01",
                sources: [
                    Source(name: "主线路", urlString: "https://ls.qingting.fm/live/4915.m3u8", kbps: 66),
                    Source(name: "备用线路", urlString: "https://live.xmcdn.com/live/1011/64.m3u8", kbps: 65)
                ]),

        Station(id: 1,
                name: "891 线上音乐台",
                subtitle: "华语流行",
                art: "st_02",
                sources: [
                    Source(name: "fm891", urlString: "https://live.fm891.net/192k.aac", kbps: 200)
                ]),

        Station(id: 2,
                name: "河北音乐广播",
                subtitle: "石家庄",
                art: "st_03",
                sources: [
                    Source(name: "卫星", urlString: "https://satellitepull.cnr.cn/live/wxhebyygb/playlist.m3u8", kbps: 230),
                    Source(name: "蜻蜓", urlString: "https://lhttp.qtfm.cn/live/1649/64k.mp3", kbps: 64)
                ]),

        Station(id: 3,
                name: "北京音乐广播",
                subtitle: "北京",
                art: "st_04",
                sources: [
                    Source(name: "官方", urlString: "https://brtv-radiolive.rbc.cn/alive/fm974.m3u8", kbps: 107),
                    Source(name: "蜻蜓", urlString: "https://lhttp.qtfm.cn/live/332/64k.mp3", kbps: 64)
                ]),

        Station(id: 4,
                name: "上海动感101",
                subtitle: "上海",
                art: "st_05",
                sources: [
                    Source(name: "蜻蜓 AAC", urlString: "https://ls.qingting.fm/live/274.m3u8", kbps: 65),
                    Source(name: "蜻蜓 MP3", urlString: "https://lhttp.qtfm.cn/live/274/64k.mp3", kbps: 64)
                ]),

        Station(id: 5,
                name: "广东音乐之声",
                subtitle: "广州",
                art: "st_06",
                sources: [
                    Source(name: "卫星", urlString: "https://satellitepull.cnr.cn/live/wxgdyyzs/playlist.m3u8", kbps: 231),
                    Source(name: "蜻蜓", urlString: "https://lhttp.qtfm.cn/live/1260/64k.mp3", kbps: 64)
                ]),

        Station(id: 6,
                name: "上海 Love Radio",
                subtitle: "上海",
                art: "st_07",
                sources: [
                    Source(name: "阿基米德", urlString: "https://rscdn.ajmide.com/r_2/nglive_2.m3u8", kbps: 218),
                    Source(name: "蜻蜓 AAC", urlString: "https://ls.qingting.fm/live/273.m3u8", kbps: 65),
                    Source(name: "蜻蜓 MP3", urlString: "https://lhttp.qtfm.cn/live/273/64k.mp3", kbps: 64)
                ]),

        Station(id: 7,
                name: "上海经典947",
                subtitle: "经典金曲",
                art: "st_08",
                sources: [
                    Source(name: "阿基米德", urlString: "https://rscdn.ajmide.com/r_10/nglive_10.m3u8", kbps: 212),
                    Source(name: "蜻蜓", urlString: "https://ls.qingting.fm/live/267.m3u8", kbps: 65)
                ]),

        Station(id: 8,
                name: "深圳飞扬971",
                subtitle: "深圳",
                art: "st_09",
                sources: [
                    Source(name: "卫星", urlString: "https://satellitepull.cnr.cn/live/wxszfy971/playlist.m3u8", kbps: 231),
                    Source(name: "蜻蜓", urlString: "https://lhttp.qtfm.cn/live/1271/64k.mp3", kbps: 64)
                ]),

        Station(id: 9,
                name: "厦门音乐广播",
                subtitle: "厦门",
                art: "st_10",
                sources: [
                    Source(name: "蜻蜓 AAC", urlString: "https://ls.qingting.fm/live/1739.m3u8", kbps: 65),
                    Source(name: "蜻蜓 MP3", urlString: "https://lhttp.qtfm.cn/live/1739/64k.mp3", kbps: 64)
                ]),

        // 只走 HLS 单源：64k MP3 备源会在首连超时后被降级使用，声音发闷
        Station(id: 10,
                name: "怀集音乐之声",
                subtitle: "广东怀集",
                art: "st_11",
                sources: [
                    Source(name: "主线路", urlString: "https://ls.qingting.fm/live/4804.m3u8", kbps: 67)
                ]),

        Station(id: 11,
                name: "FM99.9 犀牛音乐",
                subtitle: "石家庄鹿泉",
                art: "st_12",
                sources: [
                    Source(name: "喜马拉雅", urlString: "https://live.xmcdn.com/live/2572/64.m3u8", kbps: 64),
                    Source(name: "蜻蜓 AAC", urlString: "https://ls.qingting.fm/live/20211668/64k.m3u8", kbps: 64)
                ])
    ]
}
