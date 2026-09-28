# Kenis 素材清单 & 替换指南

> 本文档用于指导你准备图片、视频素材。当前 App 使用**占位资源**（SF Symbols 图标 + 纯色渐变 + 模拟数据）运行，
> 你按下方清单整理好素材后，直接拖入 `YujiaLv/Assets.xcassets`（同名即可），**无需改动任何代码**，App 会自动加载真实素材。

---

## 一、品牌视觉（供 AI 生成参考）

| 项 | 值 |
|----|----|
| 应用名 | Kenis |
| 主色 | 网球荧光黄绿 `#C6F432` |
| 辅色 | 草地绿 `#4CAF50` / 深绿 `#1E5A3A` |
| 背景 | 浅灰白 `#F7F8FA`，深色文字 `#1B1B2F` |
| 风格 | 欧美极简、运动活力、浅色底、大圆角卡片、留白充足 |

---

## 二、图片资源清单

> 图片统一为 **PNG**。命名严格按下列文件名（不含扩展名），拖入 Assets.xcassets 时新建 Image Set，名称保持一致。

### 1. App 图标（必做）
| 文件名 | 尺寸 | 用途 | AI 提示词（英文） |
|--------|------|------|------------------|

### 2. 直播封面（首页直播列表，6 张，横版 16:9）
| 文件名 | 尺寸 | 用途 | AI 提示词（英文，可替换场景） |
|--------|------|------|------------------|
| `live_cover_01` | 1920×1080 | 直播封面 | "Tennis coach demonstrating forehand swing on outdoor court, cinematic wide shot, bright daylight, dynamic action, green court, shallow depth of field, photorealistic, horizontal 16:9" |
| `live_cover_02` | 1920×1080 | 直播封面 | "Tennis coach teaching backhand technique to student, professional tennis academy, warm sunlight, action freeze, photorealistic, horizontal 16:9" |
| `live_cover_03` | 1920×1080 | 直播封面 | "Close-up of tennis serve motion, athlete throwing ball upward, motion energy, stadium background, photorealistic, horizontal 16:9" |
| `live_cover_04` | 1920×1080 | 直播封面 | "Tennis volley practice at the net, coach and player rally, indoor court with bright lights, photorealistic, horizontal 16:9" |
| `live_cover_05` | 1920×1080 | 直播封面 | "Footwork agility training with cones on tennis court, young athlete, dynamic low angle, photorealistic, horizontal 16:9" |
| `live_cover_06` | 1920×1080 | 直播封面 | "Baseline groundstroke rally, tennis ball frozen mid-air, clay court, golden hour light, photorealistic, horizontal 16:9" |

### 3. 教练头像（6 张，正方形）
| 文件名 | 尺寸 | 用途 | AI 提示词（英文，可替换人物） |
|--------|------|------|------------------|
| `coach_avatar_01` | 512×512 | 教练头像 | "Professional headshot of a friendly male tennis coach in his 30s, polo shirt, confident smile, clean light gray background, photorealistic, square 1:1" |
| `coach_avatar_02` | 512×512 | 教练头像 | "Professional headshot of a female tennis coach in her 30s, athletic wear, warm smile, clean light background, photorealistic, square 1:1" |
| `coach_avatar_03` | 512×512 | 教练头像 | "Professional headshot of a senior male tennis coach in his 40s, experienced look, sports cap, light background, photorealistic, square 1:1" |
| `coach_avatar_04` | 512×512 | 教练头像 | "Professional headshot of a young male tennis instructor, energetic, sporty, clean background, photorealistic, square 1:1" |
| `coach_avatar_05` | 512×512 | 教练头像 | "Professional headshot of a female tennis instructor, ponytail, athletic, smiling, light background, photorealistic, square 1:1" |
| `coach_avatar_06` | 512×512 | 教练头像 | "Professional headshot of a male tennis coach, mature, friendly, polo shirt, light background, photorealistic, square 1:1" |

### 4. 用户头像（7 张，正方形，用于帖子/评论/聊天）
| 文件名 | 尺寸 | 用途 | AI 提示词（英文，可替换人物） |
|--------|------|------|------------------|
| `user_avatar_01` ~ `user_avatar_07` | 512×512 | 用户头像 | 依次使用不同性别、年龄、发色、服装的欧美年轻运动爱好者头像，风格统一："Casual profile photo of a young [man/woman] sports enthusiast, natural smile, soft light, clean neutral background, photorealistic, square 1:1" |

### 5. 帖子图片（5 张，用于帖子列表/详情）
| 文件名 | 尺寸 | 用途 | AI 提示词（英文，可替换场景） |
|--------|------|------|------------------|
| `post_image_01` | 1080×1350 | 帖子配图 | "Tennis court at sunrise, empty green court, beautiful light, cinematic, photorealistic, 4:5" |
| `post_image_02` | 1080×1350 | 帖子配图 | "New tennis racket close-up on court bench, shallow depth of field, product photography, 4:5" |
| `post_image_03` | 1080×1350 | 帖子配图 | "Group of friends playing tennis, candid joyful moment, sunny day, photorealistic, 4:5" |
| `post_image_04` | 1080×1350 | 帖子配图 | "Tennis trophies and medals on shelf, achievement, warm light, photorealistic, 4:5" |
| `post_image_05` | 1080×1350 | 帖子配图 | "Tennis shoes and ball on court, minimal composition, photorealistic, 4:5" |


### 6. 场馆图片（6 张，横版）
| 文件名 | 尺寸 | 用途 | AI 提示词（英文，可替换场景） |
|--------|------|------|------------------|
| `court_01` ~ `court_06` | 1280×720 | 网球场馆图 | 依次使用不同场馆（户外红土场 / 室内硬地场 / 草地场 / 灯光夜场 / 多片球场全景 / 高端俱乐部会所），风格统一："Beautiful tennis club court, [surface type], wide angle, bright and inviting, photorealistic, 16:9" |

---

## 三、视频资源清单

> 视频统一为 **MP4（H.264）**，横版 16:9
> 命名严格按下列文件名，拖入 Assets.xcassets（或后续替换为网络/本地路径）。

### 直播视频（6 个，代表首页「直播」内容）
| 文件名 | 对应直播 | 内容建议 |
|--------|----------|----------|
| `live_video_01` | live1 | 正手击球教学示范 |
| `live_video_02` | live2 | 反手击球教学示范 |
| `live_video_03` | live3 | 发球动作分解教学 |
| `live_video_04` | live4 | 网前截击教学 |
| `live_video_05` | live5 | 步法移动训练 |
| `live_video_06` | live6 | 底线相持对打 |

> 加载说明：视频支持两种放置方式（任选其一即可被 App 识别）——
> 1) 拖入 `Assets.xcassets`（作为数据集 Data Set，名称同上）；
> 2) 放进 `YujiaLv/live/` 目录（已加入 Target，扩展名 `.mp4` / `.mov`，文件名需与上表一致）。
>
> 直播播放页在竖屏下按 16:9 完整显示横屏画面（画面居中、上下留黑），不做裁切放大。



---

## 四、图标说明（无需提供）

App 内所有功能图标统一使用 **SF Symbols**（系统自带），无需提供素材：
- 首页 `house.fill`、教练 `person.2.fill`、发布 `plus.circle.fill`、场馆 `sportscourt.fill`、我的 `person.crop.circle`
- 聊天 `message.fill`、搜索 `magnifyingglass`、通知 `bell`、点赞 `heart`、评论 `bubble.left`、分享 `square.and.arrow.up`、二维码 `qrcode`、视频通话 `video.fill`

---

## 五、替换步骤

1. 打开 `YujiaLv.xcodeproj`。
2. 在 `Assets.xcassets` 中新建对应名称的 **Image Set / Data Set**。
3. 把图片/视频文件拖入（文件名 = 本文档中的资源名）。
4. 直接运行，App 会自动加载真实素材，无需改代码。
