# 智慧仓储管理系统（smart-warehouse-wms）

> GitHub 仓库名：`smart-warehouse-wms` · Smart Warehouse Management System (WMS)

基于 Spring Boot 4 + MySQL 的库存管理系统：商品、入库、出库、预警、用户与统计，前端为单页应用，后端提供 REST API 并带会话登录。

英文简介（可直接用于 GitHub About）：`Smart warehouse management system (WMS) built with Spring Boot 4 and MySQL — goods, inbound/outbound, stock alerts, dashboards and role-based access.`

## 技术栈

| 层 | 选型 |
|---|---|
| 语言 / 构建 | Java 17，Maven 3.9 |
| 框架 | Spring Boot 4.1.0（Spring MVC / Spring Data JPA / Spring Security） |
| 数据库 | MySQL 8.0（运行），H2（单元测试） |
| 模板 | Thymeleaf（仅一个 `index.html`） |
| 前端 | 原生 JS + Bootstrap 5.3（弹窗）+ Lucide 0.468（图标）+ Chart.js 4.4（全部本地化） |

## 一键启动

首次使用先完成下面的「建库 / 导入演示数据」；之后直接双击 `start.bat`，或在项目目录执行：

```powershell
.\start.ps1                  # 默认部署到 Tomcat，访问 http://127.0.0.1:8081/
.\start.ps1 -Mode embedded   # 用内嵌 Tomcat，访问 http://127.0.0.1:8080/
.\start.ps1 -Rebuild         # 强制重新打包
.\start.ps1 -NoBrowser       # 不自动打开浏览器
.\stop.ps1                   # 停止（Tomcat + 内嵌应用）
```

脚本会：

1. 检查并启动 MySQL 服务（3306）；
2. 源码比 `target` 产物新时自动 `mvn -DskipTests package`；
3. 停止旧 Tomcat / 旧内嵌进程，部署并启动；
4. 健康检查通过后打开浏览器。

前端页面由 Spring Boot 直接托管，**不需要单独启动 npm / 前端服务**。日志在 `logs/app.log`。

默认不打印 SQL；需要看 SQL 时用 dev profile 启动：

```powershell
mvn spring-boot:run -Dspring-boot.run.profiles=dev
# 或 java -jar target\smart-warehouse-0.0.1-SNAPSHOT.jar --spring.profiles.active=dev
```

> 脚本里的 Java / Tomcat 路径写在 `start.ps1` 顶部，换机器时改这两行即可。
>
> 这是**独立脚本**：直接双击 `start.bat` 或在终端运行即可。不要把它作为自动化工具的后台任务运行，否则任务被回收时 Tomcat 可能一起退出，并产生任务完成通知。

## 快速开始

### 1. 建库

```sql
CREATE DATABASE smart_warehouse DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
```

连接信息在 `src/main/resources/application.properties`，默认：

```
jdbc:mysql://127.0.0.1:3306/smart_warehouse
用户名 root / 密码 1234
```

### 2. 启动

```powershell
mvn spring-boot:run
```

打开 <http://127.0.0.1:8080>。首次启动由 JPA 自动建表（`ddl-auto=update`）。

### 3. 导入演示数据（可选）

```powershell
$mysql = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
$dir   = "C:/Users/31529/Documents/Java & jsp/IDEA/smart-warehouse/db"

# 基础数据：10 个 SKU + 10 入 / 8 出 + 3 个用户
& $mysql -h 127.0.0.1 -P 3306 -uroot -p1234 --default-character-set=utf8mb4 -e "source $dir/seed-demo.sql"

# 扩充数据：再加 20 个 SKU + 20 入 / 20 出 + 5 个用户 + 11 月统计
& $mysql -h 127.0.0.1 -P 3306 -uroot -p1234 --default-character-set=utf8mb4 -e "source $dir/seed-more-data.sql"
```

两个脚本都使用 `INSERT IGNORE` + 固定主键，可重复执行。脚本末尾会按 `goods.warehouse` 回填单据/流水的仓库，因此**需先启动一次应用**（JPA 会创建 `warehouse` 列）再导入。导入后在页面点「手动检查预警」生成预警记录。

导入完成后：30 个 SKU、库存 5988、10 月 887/134、11 月 7075/1840、9 个用户。追加脚本只需执行一次，若之后手动加过 11 月单据，不要再重跑。

> 当前开发库另有 2 条界面补录入库（G002 各 10 件），所以实际库存 6008、11 月入库 7095；重新导入种子后回到 5988 / 7075。

### 4. 登录

| 账号 | 密码 | 角色 | 绑定仓库 |
|---|---|---|---|
| `admin` | `123456` | ADMIN | 不限 |
| `zhangwei` | `123456` | WAREHOUSE | 中心仓库 |
| `lina` | `123456` | WAREHOUSE | 中心仓库 |
| `guest` | `123456` | VIEWER（只读） | — |

扩充脚本另外创建了 `wangqiang`（中心仓库）、`zhaomin`（冷链仓）、`liuyang`（退货仓）、`chenjing`（管理员）、`sunlei`（二号仓），初始密码同为 `123456`。

演示数据里是明文密码，**首次登录成功后会自动升级为 BCrypt**，之后库里不再有明文。

## 部署到外部 Tomcat（可选）

默认用内嵌 Tomcat 11.0.22 运行；`mvn package` 同时会在 `target/` 下生成可部署的 WAR。

### 版本要求

- **Tomcat 11**（Servlet 6.1）。工作区已放好 `JavaWeb/apache-tomcat-11.0.27`。
- Tomcat 9 / 10 不能用：9.x 是 `javax.servlet`，10.1 只有 Servlet 6.0，本项目需要 6.1。

### 部署

```powershell
mvn -DskipTests package

$tc = "C:\Users\31529\Documents\Java & jsp\JavaWeb\apache-tomcat-11.0.27"
Copy-Item "target\smart-warehouse-0.0.1-SNAPSHOT.war" "$tc\webapps\ROOT.war" -Force

$env:CATALINA_HOME = $tc
$env:JAVA_HOME = "C:\Users\31529\Java\jdk-17.0.12"
& "$tc\bin\startup.bat"
```

也可以直接运行项目根目录的 `deploy-tomcat.ps1`（打包 + 拷贝 WAR 一步完成）。

访问 <http://127.0.0.1:8081/>；停止用 `shutdown.bat`。

- 必须部署为 **ROOT**：前端调用的是绝对路径 `/api/...`，放到 `/smart-warehouse` 下会 404。
- 端口在 `conf/server.xml` 的 `Connector` 上改（当前 8081，避免与内嵌 8080 冲突）。
- WAR 已排除 `tomcat-embed-*.jar`，Servlet 实现由容器提供。

## 功能

- **库存仪表板**：库存总量、低库存 SKU、本月出入库（含环比）、近 6 个月趋势、仓库/预警/分类分布、补货建议
- **商品管理**：增删改查、商品分类、按仓库/分类筛选、库存加减、CSV 导出
- **入库 / 出库**：生成单据 + 流水，库存与月统计在同一事务内更新，支持 CSV 导出
- **预警管理**：按最低/最高库存线生成预警，可逐条处理；仓库员只看/只处理本仓预警
- **补货建议**：仪表板列出低于最低线的商品，计算建议补货量，一键带商品打开入库弹窗
- **用户管理**：新增/删除用户、为仓库员绑定仓库，密码 BCrypt 存储、列表不回传密码；侧栏账号卡 →「修改密码」可改自己的密码，管理员可重置他人密码
- **库存统计**：4 个 KPI、库存/本月出入库图、月度统计表（含合计）、仓库/分类汇总、库存 Top 10、低库存清单
- **账号信息**：侧栏品牌与导航之间展示当前账号简卡（头像/用户名/角色/仓库/在线点），点击打开账号信息面板（含改密/退出）
- **操作日志**：管理员可查看最近 200 条审计记录（登录/退出、商品、库存、单据、预警、用户），支持筛选、分页和 CSV 导出
- **顶栏信息横幅**：顶栏只保留页面标题 + 一条概览横幅（库存总量 · 待处理预警 · 低库存 SKU）；点击弹出「待处理预警」清单，可逐条处理（只读账号仅可查看）；头像/改密/退出收进侧栏账号卡
- **仓库员工作台**：仓库员登录后只保留工作台、预警、商品、入库、出库 5 个菜单，隐藏统计/图表/分类筛选/导出，KPI 全部为本仓口径

## 角色权限

| 功能 | ADMIN | WAREHOUSE | VIEWER |
|---|---|---|---|
| 仪表板 / 预警 / 商品 / 单据 / 统计（查看） | ✓ | ✓ | ✓ |
| 可操作仓库范围 | 全部仓库 | **仅绑定的一个仓库** | — |
| 库存加减、入库、出库、预警处理 | ✓ | ✓（本仓商品 / 本仓预警） | — |
| 商品新增 / 删除 / 修改预警线 | ✓ | — | — |
| 用户管理 / 绑定仓库 / 重置他人密码 | ✓ | — | — |
| 操作日志（审计） | ✓ | — | — |
| 修改自己的密码 | ✓ | ✓ | ✓ |

仓库员必须绑定一个仓库；入库/出库/库存加减都会校验商品所属仓库，跨仓返回 `403`，单据列表也只返回本仓数据。管理员不绑定仓库，可操作全部仓库。

仓库员登录后进入**精简工作台**：只保留「工作台、预警管理、商品管理、入库管理、出库管理」5 个菜单，隐藏库存统计、仪表盘图表、分类筛选和导出按钮；工作台只显示本仓库存、本月入库/出库、常用操作、本仓预警和补货建议。

预警同样按仓库隔离：仓库员只看到本仓预警，`手动检查` 只重算本仓（不影响其他仓库），处理别仓预警返回 `403`。管理员可查看/处理全部预警。

前端按角色隐藏菜单、按钮与表格列；后端用 `@PreAuthorize` 和仓库校验再兜底，越权请求返回 `403`。

## API

| 方法 | 路径 | 说明 |
|---|---|---|
| POST | `/api/auth/login` | 登录，`{username, password}` |
| POST | `/api/auth/logout` | 退出 |
| GET | `/api/auth/me` | 当前用户；未登录 401 |
| POST | `/api/auth/password` | 修改自己的密码，`{oldPassword, newPassword}`（至少 6 位） |
| GET/POST | `/api/goods` | 商品列表（仓库员只返回本仓，管理员/只读返回全部）/ 新增 |
| DELETE | `/api/goods/{id}` | 删除商品 |
| POST | `/api/goods/{id}/stock` | 加减库存，`{delta}`；超减 400 |
| GET/POST | `/api/inbound` | 入库单列表 / 创建 |
| GET/POST | `/api/outbound` | 出库单列表 / 创建；库存不足 400 |
| GET | `/api/statistics/dashboard` | 仪表板汇总；`warningTotal`（预警总数）/ `warningPending`（未处理）按仓库收敛，含 `trend` 近 6 个月数据 |
| GET | `/api/warnings` | 预警列表；仓库员只返回本仓 |
| POST | `/api/warnings/check` | 重算预警；仓库员只重算本仓；同一商品同类型只保留最新一条，不堆重复历史 |
| POST | `/api/warnings/{id}/process` | 处理预警；跨仓 403 |
| GET/POST/DELETE | `/api/users`、`/api/users/{id}` | 用户管理 |
| PUT | `/api/users/{id}/warehouse` | 管理员给仓库员绑定仓库，`{warehouse}` |
| POST | `/api/users/{id}/password` | 管理员重置密码，`{newPassword}`；非管理员 403 |
| GET | `/api/logs` | 管理员查看最近 200 条操作日志 |

除 `/api/auth/login` 外，`/api/**` 均需登录；未登录返回 `401 {"message":"未登录或会话已过期"}`。

## 数据表

| 表 | 说明 |
|---|---|
| `goods` | 商品与当前库存、预警线、商品分类 |
| `inbound_order` / `outbound_order` | 出入库单据 |
| `inbound_record` / `outbound_record` | 出入库流水 |
| `operation_log` | 操作审计日志 |
| `monthly_stat` | 月度出入库汇总（`stat_month` 唯一） |
| `sys_user` | 用户与角色 |
| `warning_record` | 预警记录 |

## 测试

```powershell
mvn test
```

测试使用 H2 内存库（`src/test/resources/application.properties`），不依赖本机 MySQL。

## 目录结构

```
src/main/java/com/warehouse/
├── config/        SecurityConfig、LegacyAwarePasswordEncoder
├── controller/    7 个 REST 控制器
├── service/       GoodsService、StockService、StatisticsService、WarningService
├── repository/    8 个 JpaRepository
├── entity/        8 个实体
└── exception/     BusinessException、GlobalExceptionHandler
src/main/resources/
├── templates/index.html   页面结构（侧栏 + 顶栏 + 视图 + 弹窗）
├── static/css/app.css     B 端设计系统主题
├── static/js/app.js       前端交互逻辑
├── static/vendor/         Bootstrap / Chart.js / Lucide（本地化）
└── application.properties
db/seed-demo.sql           基础演示数据
db/seed-more-data.sql      追加 20 个 SKU / 20 入 20 出 / 5 个用户
```

## 界面

- 登录页：`../../docs/ui-login.png`
- 库存仪表板：`../../docs/ui-dashboard.png`
- 仪表板补货建议：`../../docs/ui-dashboard-replenish.png`
- 库存统计：`../../docs/ui-stats.png`
- 账号信息：`../../docs/ui-user-info.png`
- 侧栏账号简卡：`../../docs/ui-sidebar-user.png`
- 操作日志：`../../docs/ui-logs.png`
- 统计明细：`../../docs/ui-stats-lower.png`
- 月度统计：`../../docs/ui-stats-monthly.png`
- 商品管理：`../../docs/ui-goods.png`
- 预警管理：`../../docs/ui-warnings.png`
- 入库记录：`../../docs/ui-inbound.png`
- 新增商品弹窗：`../../docs/ui-modal.png`
- 删除确认：`../../docs/ui-confirm.png`
- 修改密码：`../../docs/ui-password.png`
- 用户管理：`../../docs/ui-users.png`
- 仓库员工作台：`../../docs/ui-warehouse-workbench.png`
- 仓库员商品页：`../../docs/ui-warehouse-goods.png`
- 仓库员入库弹窗：`../../docs/ui-warehouse-inbound.png`
- 仓库员预警页：`../../docs/ui-warehouse-warnings.png`
- 绑定仓库：`../../docs/ui-bind-warehouse.png`
- 只读视角：`../../docs/ui-role-viewer.png`
- 移动端：`../../docs/ui-mobile.png`

## 设计规范

界面按 [b-end-design-system-skill](https://github.com/Ludi-Herry/b-end-design-system-skill) 重绘，规范副本见 `../../docs/design-system/`。

- 浅色 Slate 画布 + `#2563eb` 主色 + 0.5px 微边框 + 12px 卡片圆角
- Lucide 线性图标；页面标题 20/28 600，正文 14/20
- 列表页 = 筛选栏 + 数据表 + 分页；数值与时间右对齐
- 表格操作列使用 ghost 文本按钮；删除走静态遮罩确认框
- Badge 浅底深字；弹窗 520px、垂直 15vh；表单弹窗不可点击遮罩关闭

## 安全说明

- 密码使用 BCrypt；历史明文兼容仅在登录校验时生效，并自动升级。
- 入库 / 出库 / 库存调整的操作人取当前登录账号（服务端会话），客户端传入的 `operator` 不生效。
- 修改密码必须校验当前密码；管理员重置他人密码仅 `ROLE_ADMIN` 可用。
- 未登录访问 `/api/**` 返回 401 JSON，页面弹出登录框。
- CSRF 当前关闭（同源 SPA、默认本机部署）。若要放到公网，请开启 CSRF 并配合 `X-CSRF-TOKEN`，同时把数据库密码移出配置文件（环境变量或密钥管理）。
- 除管理员重置密码外，其余业务接口登录即可访问，尚未做更细的角色授权。
