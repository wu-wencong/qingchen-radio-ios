# 清晨音乐台 iOS（在线编译 → 未签名 IPA → 自签安装）

用 GitHub 的免费 Mac 机器编译，产出**未签名 IPA**，再用 Sideloadly 用自己的 Apple ID 签名装到 iPhone。
不需要 Mac，不需要开发者账号。

---

## 一、上传到 GitHub

1. 打开 https://github.com ，登录（没有就注册，免费）。
2. 右上角 `+` → **New repository**
   - Repository name：`qingchen-radio-ios`
   - 选 **Private**（私有）
   - 不要勾选 Add README / .gitignore / license
   - 点 **Create repository**
3. 页面出现 "Quick setup"，点 **uploading an existing file** 链接。
4. 把**本文件夹里所有的东西**（`project.yml`、`QingchenRadio` 文件夹、`README.md`）拖进页面。
   - 注意：拖的是文件夹**里面的内容**，让 `project.yml` 直接躺在仓库根目录
   - Chrome / Edge 支持拖文件夹，会保留目录结构
   - `.github` 这个隐藏文件夹**拖不上去，必须手动建**（见下一步）
5. 点 **Commit changes**。

## 二、手动创建流水线文件（关键）

1. 回到仓库首页，点 **Add file** → **Create new file**
2. 文件名输入（斜杠会自动建目录）：
   ```
   .github/workflows/build-ipa.yml
   ```
3. 把本工程里 `build-ipa.yml` 的内容整段粘进去（用记事本打开 `.github/workflows/build-ipa.yml` 复制）
4. 点 **Commit changes**

## 三、跑编译

1. 点仓库顶部 **Actions** 标签。
2. 如果出现绿色按钮 `I understand my workflows, go ahead and enable them`，点它。
3. 左侧选 **Build IPA** → 右侧 **Run workflow** → 绿色 **Run workflow**。
4. 等 3～6 分钟。刷新页面，会出现一条带绿勾的运行记录。
5. 点进去，拉到最底部 **Artifacts** → 下载 `QingchenRadio-unsigned-ipa`。
6. 解压得到 `QingchenRadio.ipa`。

> 以后改了代码（比如换电台地址），只要在网页上编辑 `Station.swift`，提交后会自动重新编译，直接下载新的 ipa 即可。

## 四、装到 iPhone（Windows）

1. 装 **iTunes**（必须从 apple.com 下载的桌面版，不要用 Microsoft Store 版），装完再装 **iCloud**（可选但建议）。
2. 装 **Sideloadly**：https://sideloadly.io
3. iPhone 用数据线连电脑，手机上点「信任此电脑」。
4. 打开 Sideloadly：
   - 顶部设备会自动识别出你的 iPhone
   - 把 `QingchenRadio.ipa` 拖进 **IPA** 输入框
   - **Apple ID** 填你的 Apple ID
   - 点 **Start**
5. 弹出输入密码（建议先在 appleid.apple.com 生成「App 专用密码」再用，避免触发二次验证）。
6. 装好后手机上：**设置 → 通用 → VPN 与设备管理 → 开发者 App** → 点你的 Apple ID → **信任**。
7. 回桌面打开 App，会自动播放「清晨音乐台」。

## 五、必须知道的限制（免费 Apple ID 签名）

| 项目 | 限制 |
|---|---|
| 有效期 | **7 天**，到期 App 打不开，重跑一次 Sideloadly 即可（不丢数据） |
| App 数量 | 最多同时装 **3 个** 自签 App |
| 续签 | 想自动续签可装 **AltStore**，同一 WiFi 下自动重签 |
| 证书 | 不需要 99 美元开发者账号 |

## 六、这一版做了什么

- 4 个电台：清晨音乐台 / 891 线上音乐台 / 怀集音乐之声 / FM99.9 犀牛音乐
- **启动即自动播放**主台（清晨音乐台）
- 后台播放：锁屏、切到别的 App 都不停（`UIBackgroundModes: audio`）
- 锁屏 / 车机屏显示台名、台标，支持 **上一台 / 播放暂停 / 下一台**
- **蓝牙车机、方向盘按键**走系统远程控制，能切台（前提是车机把方控映射成媒体键）
- 断线自动重试 2 次，失败提示换台
- 深色界面，金色高亮，选中台有跳动音频条

## 七、已知小风险

- `891 线上音乐台` 是裸 AAC 流（不是 HLS），iOS 上多数情况能直接播；万一播放器打不开，我再给你换成 HLS 包装或备用源。
- 犀牛音乐用的是喜马拉雅 2572 的纯音频流。

## 八、文件说明

```
project.yml                      XcodeGen 工程描述（App 名、包名、后台播放权限都在这）
QingchenRadio/
  QingchenRadioApp.swift         入口
  Station.swift                  ★ 电台列表：改这里就能增删台
  RadioPlayer.swift              播放核心：AVPlayer + 锁屏 + 车机控制
  ContentView.swift              界面
  Assets.xcassets/               台标 + App 图标（1024）
.github/workflows/build-ipa.yml  编译流水线
```
