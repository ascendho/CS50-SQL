# Designing

## 一、课程概述
- **课程主题**：数据库 schema 设计核心（含规范化、表关系定义）、表创建语法、数据类型、约束规则及表结构修改，聚焦“从零构建可扩展的关系型数据库”。
- **主讲人**：Carter Zenke、David J. Malan（哈佛大学）
- **核心工具**：SQLite，示例数据库`mbta.db`（模拟波士顿地铁系统，含骑手、车站、刷卡记录等实体）
- **课程目标**：掌握数据库设计流程（需求拆解→规范化→表创建→约束设置→结构迭代），理解SQLite数据类型特性与约束机制

## 二、数据库设计核心流程
### 1. 需求拆解与Schema设计
- **定义**：Schema 是数据库的“骨架”，包含表结构、列定义、数据类型、约束及表间关系。
- **设计步骤**：
  1. 明确业务实体（如波士顿地铁系统的“骑手”“车站”“刷卡记录”）。
  2. 为每个实体设计表及列（如`stations`表含`id`“编号”、`name`“站名”、`line`“线路”）。
  3. 定义实体间关系（如骑手与车站是多对多关系）。
  4. 用`CREATE TABLE`语法实现表结构，用约束保证数据完整性。

### 2. 规范化（Normalization）
- **定义**：通过拆分表减少数据冗余的过程，核心原则是“一个实体对应一个表，实体属性仅存储在该表中”。
- **冗余问题示例**：初始设计的单表含骑手姓名、车站名、刷卡信息，导致同一骑手/车站的信息重复存储。
- **规范化解决方案**：
  - 将“骑手”拆分为`riders`表（存`id`、`name`）。
  - 将“车站”拆分为`stations`表（存`id`、`name`、`line`）。
  - 用关联表（`visits`）存储两者的多对多关系，避免重复数据。
- **核心价值**：提高数据一致性（修改骑手姓名仅需改一处）、减少存储开销。

### 3. 表间关系设计（延续Lecture 1）
- **示例场景**：骑手（`riders`）与车站（`stations`）的关系。
  - 关系类型：多对多（一个骑手可访问多个车站，一个车站可接待多个骑手）。
  - ER图表示：用“visits”关联表连接，ER图标注规则（乌鸦脚符号）：
    - 骑手（Rider）→ 至少访问1个车站（竖线+乌鸦脚）。
    - 车站（Station）→ 可接待0个或多个骑手（圆圈+乌鸦脚）。
- **设计灵活性**：关系约束由设计者决定（如可强制“车站必须有至少1个骑手”，需通过约束实现）。

## 三、表创建基础：CREATE TABLE
### 1. 基本语法
```sql
CREATE TABLE 表名 (
  "列1名" [数据类型/约束],
  "列2名" [数据类型/约束],
  ...
  [表约束]
);
```
- **示例1**：创建骑手表
  ```sql
  CREATE TABLE riders (
    "id" INTEGER,
    "name" TEXT
  );
  ```
- **示例2**：创建车站表（含线路信息）
  ```sql
  CREATE TABLE stations (
    "id" INTEGER,
    "name" TEXT,
    "line" TEXT  -- 存储车站所属地铁线路
  );
  ```
- **示例3**：创建关联表（骑手-车站多对多关系）
  ```sql
  CREATE TABLE visits (
    "rider_id" INTEGER,  -- 引用riders.id
    "station_id" INTEGER  -- 引用stations.id
  );
  ```
- **关键命令**：
  - 查看数据库所有表结构：`.schema`（SQLite特有命令，非SQL关键字）。
  - 查看指定表结构：`.schema 表名`（如`.schema stations`）。

### 2. 语法注意事项
- 列名与表名建议用双引号包裹（SQL标识符规范）。
- 括号内列定义可缩进（非强制，但提升可读性）。
- 表创建后无终端输出，需用`.schema`验证。

## 四、SQLite数据类型体系
### 1. 五大存储类（Storage Classes）
SQLite不严格区分“数据类型”，而是通过“存储类”定义数据存储方式，支持自动类型转换，五大存储类如下：

| 存储类 | 描述 | 适用场景 |
|--------|------|----------|
| Null | 空值（无数据） | 缺失的可选字段（如骑手未提供姓名） |
| Integer | 整数（0/1/2/3/4/6/8字节，SQLite自动适配） | 编号（id）、计数等无小数场景 |
| Real | 浮点数（小数） | 金额、评分等需精度的数值（注意：二进制存储可能有精度损失） |
| Text | 字符串 | 名称、描述、文本信息（如站名、线路名） |
| Blob | 二进制大对象 | 图片、音频等二进制数据 |

- **示例思考**：存储地铁票价的选择：
  - Integer：存“10”（代表10美分），需约定单位，无歧义。
  - Text：存“$0.10”，可读性强，但无法直接做数学运算。
  - Real：存“0.10”，支持运算，但可能有精度误差（如0.1+0.2≠0.3）。

### 2. 类型亲和性（Type Affinities）
- **定义**：SQLite列不强制存储单一数据类型，而是有“类型亲和性”——会尝试将输入值转换为列的亲和类型（如整数亲和列接收文本“25”，会自动转为整数25）。
- **五大类型亲和性**：Text、Numeric（自动适配整数/浮点数）、Integer、Real、Blob。
- **规则示例**：
  - 整数亲和列（INTEGER）：输入文本“25”→ 转换为整数25。
  - 文本亲和列（TEXT）：输入整数25→ 转换为文本“25”。
  - 未指定亲和性：默认为Numeric（自动判断输入为整数或浮点数）。

## 五、约束规则（Constraints）
约束是对表/列数据的“强制规则”，保证数据完整性（无错误、无冗余、逻辑一致），分为**表约束**和**列约束**。

### 1. 表约束（作用于整个表）
| 约束类型 | 作用 | 语法示例 |
|----------|------|----------|
| PRIMARY KEY | 定义主键（唯一标识表中记录，非空+唯一） | `PRIMARY KEY("id")`（为riders表id列设主键） |
| FOREIGN KEY | 定义外键（引用其他表的主键，建立表间关联） | `FOREIGN KEY("rider_id") REFERENCES "riders"("id")` |
| PRIMARY KEY(多列) | 复合主键（多列组合唯一，适用于无单一主键场景） | `PRIMARY KEY("rider_id", "station_id")`（visits表，限制同一骑手不可重复访问同一车站） |

- **示例**：添加主键和外键约束的完整表定义
  ```sql
  -- 骑手表（id为主键）
  CREATE TABLE riders (
    "id" INTEGER,
    "name" TEXT,
    PRIMARY KEY("id")  -- 表约束：id为主键（非空+唯一）
  );
  
  -- 车站表（id为主键）
  CREATE TABLE stations (
    "id" INTEGER,
    "name" TEXT,
    "line" TEXT,
    PRIMARY KEY("id")
  );
  
  -- 关联表（外键引用骑手和车站主键）
  CREATE TABLE visits (
    "rider_id" INTEGER,
    "station_id" INTEGER,
    FOREIGN KEY("rider_id") REFERENCES "riders"("id"),  -- 外键约束
    FOREIGN KEY("station_id") REFERENCES "stations"("id")
  );
  ```
- **默认主键**：SQLite表若未显式定义主键，会自动生成隐含的`rowid`列（自增整数，可查询）。

### 2. 列约束（作用于指定列）
| 约束类型 | 作用 | 语法示例 |
|----------|------|----------|
| NOT NULL | 列值不可为NULL（必须提供数据） | `name TEXT NOT NULL`（车站名必填） |
| UNIQUE | 列值唯一（无重复） | `name TEXT UNIQUE`（车站名不可重复） |
| DEFAULT | 列值未提供时，使用默认值 | `datetime NUMERIC DEFAULT CURRENT_TIMESTAMP`（默认取当前时间戳） |
| CHECK | 列值必须满足指定条件 | `type TEXT CHECK("type" IN ('enter', 'exit', 'deposit'))`（刷卡类型仅3种可选） |

- **示例**：添加列约束的车站表
  ```sql
  CREATE TABLE stations (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,  -- 非空+唯一（车站名必填且不重复）
    "line" TEXT NOT NULL,  -- 非空（线路必须指定）
    PRIMARY KEY("id")
  );
  ```
- **关键说明**：
  - 主键列默认隐含`NOT NULL`和`UNIQUE`，无需显式添加。
  - `CHECK`约束支持复杂条件（如`amount NUMERIC CHECK("amount" != 0)`，刷卡金额不可为0）。
  - 其他DBMS（如MySQL）支持`BOOLEAN`类型，SQLite无，可用`INTEGER`（0=假，1=真）替代。

## 六、表结构修改：ALTER TABLE
当业务需求变化时，用`ALTER TABLE`修改现有表结构（SQLite支持的核心操作如下）：

| 操作类型 | 语法 | 示例 |
|----------|------|------|
| 重命名表 | `ALTER TABLE 旧表名 RENAME TO 新表名;` | `ALTER TABLE "visits" RENAME TO "swipes";`（关联表改为刷卡记录表） |
| 添加列 | `ALTER TABLE 表名 ADD COLUMN 列名 数据类型 [约束];` | `ALTER TABLE "swipes" ADD COLUMN "type" TEXT;`（添加刷卡类型列） |
| 重命名列 | `ALTER TABLE 表名 RENAME COLUMN 旧列名 TO 新列名;` | `ALTER TABLE "swipes" RENAME COLUMN "type" TO "swipetype";` |
| 删除列 | `ALTER TABLE 表名 DROP COLUMN 列名;` | `ALTER TABLE "swipes" DROP COLUMN "swipetype";` |

### 1. 实操示例：迭代地铁数据库表结构
需求变更：将“骑手”改为“地铁卡（CharlieCard）”，记录刷卡类型、时间、金额：
1. 删除旧表`riders`（需先处理外键依赖，否则报错）：
   ```sql
   DROP TABLE "riders";  -- 若riders.id被其他表引用，需先删除外键列
   ```
2. 创建新表`cards`（地铁卡实体）：
   ```sql
   CREATE TABLE "cards" (
     "id" INTEGER,
     PRIMARY KEY("id")  -- 地铁卡编号为主键
   );
   ```
3. 重命名`visits`表为`swipes`（刷卡记录）：
   ```sql
   ALTER TABLE "visits" RENAME TO "swipes";
   ```
4. 为`swipes`表添加列（适配新需求）：
   ```sql
   ALTER TABLE "swipes" ADD COLUMN "card_id" INTEGER;  -- 引用cards.id
   ALTER TABLE "swipes" ADD COLUMN "type" TEXT NOT NULL CHECK("type" IN ('enter', 'exit', 'deposit'));  -- 刷卡类型（进站/出站/充值）
   ALTER TABLE "swipes" ADD COLUMN "datetime" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP;  -- 刷卡时间（默认当前时间）
   ALTER TABLE "swipes" ADD COLUMN "amount" NUMERIC NOT NULL CHECK("amount" != 0);  -- 金额（非0）
   ```
5. 调整外键约束（更新schema.sql文件，推荐方式）：
   ```sql
   CREATE TABLE "swipes" (
     "id" INTEGER,
     "station_id" INTEGER,
     "card_id" INTEGER,
     "type" TEXT NOT NULL CHECK("type" IN ('enter', 'exit', 'deposit')),
     "datetime" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
     "amount" NUMERIC NOT NULL CHECK("amount" != 0),
     PRIMARY KEY("id"),
     FOREIGN KEY("station_id") REFERENCES "stations"("id"),
     FOREIGN KEY("card_id") REFERENCES "cards"("id")
   );
   ```

### 2. 注意事项
- 修改表结构后，需用`.schema`验证变更。
- 推荐做法：将完整schema写入`schema.sql`文件，迭代时直接修改文件，重新执行创建命令（比多次`ALTER TABLE`更高效）。
- 删除表/列前需确认无依赖（如删除`riders`表前，需先删除`visits`表的`rider_id`外键列）。

## 七、关键问题与注意事项
1. **设计决策灵活性**：表间关系（如车站是否允许0骑手）、约束规则（如是否必填）由设计者根据业务场景决定，无绝对标准。
2. **SQLite与其他DBMS差异**：SQLite的类型亲和性、隐含`rowid`、`ALTER TABLE`功能（部分DBMS支持更多操作）与MySQL/PostgreSQL略有不同，移植时需微调语法。
3. **默认类型亲和性**：未指定数据类型的列，默认亲和性为Numeric（自动适配整数/浮点数）。
4. **外键约束影响**：删除被外键引用的表（如`riders`）时，需先删除引用它的外键列（如`visits.rider_id`），否则报错。
5. **复合主键适用场景**：仅当“多列组合才能唯一标识记录”时使用（如`visits`表若限制同一骑手不可重复访问同一车站，可设`PRIMARY KEY("rider_id", "station_id")`）。