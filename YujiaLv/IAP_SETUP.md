# App Store Connect 内购配置说明

本文档说明如何在 App Store Connect（下称 ASC）为 **Kenis / YujiaLv** 配置直播礼物的内购项目。

- Bundle ID：`com.yujia.YujiaLv`
- 商品类型：**消耗型（Consumable）** —— 每赠送一次礼物扣一次费
- 商品数量：7 个

代码侧**已经接好**（StoreKit 2 真实内购），本文档只需要你在 ASC 里把商品建出来。
商品建好之前，App 会走「商品不可用」的报错路径，不会放行免费解锁。

---

## 一、先做前置条件（最容易漏，漏了就白忙）

内购要能跑起来，**必须先满足下面两条**，否则无论代码怎么改、商品怎么建，`Product.products(for:)` 都只会返回空数组。

### 1. 签署《付费应用协议》并激活

**路径：** ASC → **Business（商务）** → **Agreements, Tax, and Banking（协议、税务和银行业务）**

- 由 **Account Holder（账户持有人）** 签署 **Paid Applications Agreement（付费应用协议）**
- 填写 **银行账户信息** 和 **税务信息**
- 确认协议状态变成 **Active**（生效）

> 银行与税务审核可能需要数小时到数天。协议不是 Active 时，Sandbox 拿不到任何商品 —— 这是「代码没问题但就是拉不到商品」的头号原因。

### 2. 确认账号权限

创建 / 编辑内购需要以下任一角色：Account Holder、Admin、App Manager、Developer、Marketing。
**提交审核**需要：Account Holder、Admin 或 App Manager。

---

## 二、创建 7 个消耗型商品

**路径：** ASC → **Apps（我的 App）** → 选中你的 App → 左侧边栏 **Monetization（变现）** → **In-App Purchases（内购）** → 点 **添加（+）**

### ⚠️ 两个不可逆的选择，做之前务必确认

| 项目 | 说明 |
|---|---|
| **类型必须选 Consumable** | 商品**创建后类型不可更改**。选错了只能删掉重建（而删掉的 Product ID 也不能再用）。 |
| **Product ID 必须与代码逐字一致** | Product ID **创建后不可更改**，且一旦用过就永久占用 —— 即使商品被删除，这个 ID 也不能再给别的商品用。 |

### 逐个创建以下 7 个商品

| # | Product ID（必须逐字一致） | Reference Name | Display Name | 价格 |
|---|---|---|---|---|
| 1 | `kenis.gift.rose` | Rose | Rose | $0.99 |
| 2 | `kenis.gift.star` | Star | Star | $2.99 |
| 3 | `kenis.gift.ace` | Ace | Ace | $6.99 |
| 4 | `kenis.gift.diamond` | Diamond | Diamond | $10.99 |
| 5 | `kenis.gift.rocket` | Rocket | Rocket | $15.99 |
| 6 | `kenis.gift.fire` | Fire | Fire | $20.99 |
| 7 | `kenis.gift.trophy` | Trophy | Trophy | $29.99 |

**每个商品的创建流程：**

1. **选类型** → `Consumable`
2. 填 **Reference Name**（内部用，不在 App Store 展示，≤64 字符）和 **Product ID**（上表的值）→ **Create**
3. **Availability（供应范围）** → 选择要销售的国家/地区
4. **Price（价格）** → 选上表对应的价格档位 → 按需针对特定地区调价 → **Confirm**
5. **App Store Information → Localization** → **Add localization** → 选语言（建议至少 en-US），填：
   - **Display Name**：展示给用户的名称（同上表）
   - **Description**：展示给用户的描述，例如 `Send a Rose in a live stream.`
6. **Reviewer Information** → 上传 **Screenshot（截图）**
   - **这是必填项**，缺了无法提交审核。截一张礼物面板的图即可（能看到礼物和价格的界面）
   - **Review Notes** 选填
7. **Save**

### 关于价格档位

上表的 7 个价格都是 App Store 美区的标准 `.99` 档位，正常都能选到。
如果你要卖的区（比如中国大陆区）没有恰好一致的档位，**选最接近的档位，然后告诉我实际价格** —— 我会同步改代码里的占位价和 `GiftProducts.storekit`，保持三处一致。

### 提交审核

- **每一类型的第一个消耗型内购，必须随一个新版 App 一起提交**。第一个获批后，同类型后续商品才能单独提交、不需要新版本。
- 在 In-App Purchases 页面勾选商品 → **Add for Review** → **Submit to Review**。单次提交最多 200 个商品。

---

## 三、代码侧对应的位置（如需核对）

| 内容 | 文件 |
|---|---|
| 商品 ID / 名称 / 占位价 | `YujiaLv/Models/LiveGift.swift` |
| 本地测试用商品配置 | `GiftProducts.storekit`（仓库根目录） |
| StoreKit 2 购买逻辑 | `YujiaLv/Stores/GiftStore.swift` |

**三处的 Product ID 必须完全一致。** 可以用下面这段脚本核对代码与本地配置：

```bash
cd /Users/hades/Desktop/Code/26/待用/Live/0924-1/YujiaLv
python3 -c "
import json,re
ids=[p['productID'] for p in json.load(open('GiftProducts.storekit'))['products']]
code=re.findall(r'LiveGift\(id: \"([^\"]+)\"', open('YujiaLv/Models/LiveGift.swift').read())
print('storekit:', ids); print('代码    :', code)
print('一致:', ids == code)
"
```

---

## 四、测试

### 阶段一：本地测（不需要 ASC，随时可跑）

用仓库根目录的 `GiftProducts.storekit`，Xcode 会注入一套**仿真商品**，能弹出真实的系统购买框但不产生任何扣费。

1. Xcode 里 **Product → Scheme → Edit Scheme…** → **Run** → **Options**
2. **StoreKit Configuration** 选 `GiftProducts.storekit`
3. **Cmd+R** 运行 → 进直播 → 点礼物 → 点 Send → 应弹出系统购买框

### 阶段二：Sandbox 测（验证真实 ASC 配置）

**🔴 关键一步，漏了会以为没生效：** 先在 **Edit Scheme → Run → Options → StoreKit Configuration 改成 `None`**。
只要这里挂着 `.storekit` 文件，App 就一直在用本地仿真商品，**永远不会去问真实 App Store**。

然后：

1. **建 Sandbox 测试账号**：ASC → **Users and Access（用户和访问）** → **Sandbox** → **Testers** → **+**
   - 邮箱必须是**没有注册过 Apple ID 的地址**（用 `你的邮箱+test@gmail.com` 这种别名即可）
2. **设备上用沙盒账号购买**：不需要退出自己的 Apple ID，购买时会提示输入沙盒账号
   - 若提示条款变更之类的异常，新建一个沙盒测试账号通常能解决
3. 商品状态至少要是 **Ready to Submit**，Sandbox 才能取到
4. **元数据改动最多需要 1 小时**才会在 Sandbox 生效 —— 建完商品别立刻断言失败，等一会儿再试

---

## 五、排障对照表

| 现象 | 原因 |
|---|---|
| 礼物面板价格显示 `$0.99` 这类**占位价**，点 Purchase 弹「The gift store is unavailable right now」 | 商品没取到。依次检查：① 付费应用协议是否 Active ② 7 个商品是否都建了 ③ Product ID 是否与上表**逐字一致**（大小写、点号都不能差）④ 商品是否至少 Ready to Submit |
| 只有部分礼物可用 | 某个 Product ID 拼错了，或某个商品还没建完元数据 |
| 购买框弹出但报「Purchase couldn't be verified」 | 通常是沙盒账号问题；换一个沙盒测试账号 |
| 改了商品但 App 里没变化 | 元数据同步有延迟（最长 1 小时），或 scheme 里仍挂着 `.storekit` 配置 |
| 一直用的是假商品、没走真实扣费 | scheme 的 StoreKit Configuration 没设成 `None` |

**App 内的行为约定**（按需求确认过）：商品取不到时**明确报错、绝不放行免费解锁**，错误文案内联显示在购买弹窗里。

---

## 六、审核注意事项

- 内购商品必须**完整、最新、审核员可见可测**。审核员会用内置测试账号 `kenis` / `123456` 登录（见 `AppState.builtInAccounts`）。
- 确保审核期间商品处于可购买状态，否则可能被判为「内购不可用」而拒审。
- 内购与订阅不支持 Apple Watch；提交 watchOS 版本时要从提交中移除。
