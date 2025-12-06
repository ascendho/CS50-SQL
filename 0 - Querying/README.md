# Querying

## 一、课程概述
- **课程主题**：数据库基础与SQL入门，核心围绕数据的存储、管理与查询展开。
- **主讲人**：Carter Zenke、David J. Malan（哈佛大学）
- **核心工具**：以SQLite为入门数据库，后续将学习MySQL和PostgreSQL
- **课程目标**：掌握数据库基本概念、SQL基础查询语法，能通过SQL操作数据

## 二、数据库核心概念
### 1. 数据库定义
- 本质：一种结构化组织数据的方式，支持**增（Create）、查（Read）、改（Update）、删（Delete）** 四大核心操作。
- 数据库管理系统（DBMS）：用于与数据库交互的工具，提供图形界面或文本语言支持，常见示例包括MySQL、Oracle、PostgreSQL、SQLite、MongoDB等。
- 与电子表格的区别：数据库在**规模（支持亿级数据）、更新能力（每秒多并发更新）、查询速度（优化算法检索）** 上远超电子表格，电子表格仅适用于小规模数据处理。

### 2. 表的结构特性
- 表（Table）：存储特定类型的数据集（如书籍信息、员工薪资），是数据库的核心组成单元。
- 行（Row）：代表数据集中的单个条目（如一本书、一个员工）。
- 列（Column）：代表条目的某个属性（如书名、作者、薪资月份）。
- 示例：古代寺庙员工薪资表（有行列结构）、现代书籍信息表（书名+作者列）。

### 3. DBMS选择因素
- 成本：商业软件（如Oracle）vs 免费开源软件（如SQLite、MySQL）。
- 支持度：开源软件需自行配置，商业软件通常提供专业技术支持。
- 轻量化：SQLite无需复杂部署，适合入门和轻量应用；MySQL/PostgreSQL功能更全，但资源消耗更高。

## 三、SQL基础
### 1. SQL简介
- 全称：结构化查询语言（Structured Query Language）。
- 用途：与数据库交互，实现数据的增删改查。
- 特性：结构化语法、含专用关键字、支持数据查询。
- 标准与兼容性：遵循ANSI/ISO标准，不同DBMS（如SQLite、MySQL）支持SQL子集，语法可能存在差异。

### 2. SQLite入门准备
- 环境：使用CS50.dev的Visual Studio Code，内置SQLite环境。
- 终端操作Tips：
  - 清屏：Ctrl + L。
  - 查看历史命令：上箭头键。
  - 多行查询：回车可换行继续输入。
  - 退出SQLite：输入.quit。

## 四、SQL核心查询语法
### 1. SELECT：数据查询基础
- 功能：从表中选择指定行/列数据。
- 语法示例：
  - 选择表中所有行和列：`SELECT * FROM "longlist";`（*表示所有列）。
  - 选择指定列：`SELECT "title" FROM "longlist";`（仅查询书名）。
  - 选择多列：`SELECT "title", "author" FROM "longlist";`（查询书名和作者）。
- 注意事项：表名和列名（SQL标识符）建议用双引号包裹，字符串用单引号区分。

### 2. LIMIT：限制结果数量
- 功能：指定查询结果返回的行数，适用于大数据集快速预览。
- 语法示例：`SELECT "title" FROM "longlist" LIMIT 10;`（返回前10个书名）。

### 3. WHERE：条件筛选
- 功能：根据指定条件筛选行，仅返回条件为真的记录。
- 核心运算符：
  - 比较运算符：=（等于）、!=/<>（不等于）、<（小于）、>（大于）、<=（小于等于）、>=（大于等于）。
  - 逻辑运算符：AND（且）、OR（或）、NOT（非），可通过括号调整运算优先级。
- 语法示例：
  - 筛选2023年入围书籍：`SELECT "title", "author" FROM "longlist" WHERE "year" = 2023;`。
  - 筛选非精装书：`SELECT "title", "format" FROM "longlist" WHERE "format" != 'hardcover';`（hardcover为字符串，用单引号）。
  - 组合条件：`SELECT "title", "format" FROM "longlist" WHERE ("year" = 2022 OR "year" = 2023) AND "format" != 'hardcover';`。

### 4. NULL：处理缺失数据
- 定义：表示数据缺失或不存在，不可用=或!=判断。
- 专用运算符：IS NULL（为空）、IS NOT NULL（不为空）。
- 语法示例：
  - 查询无译者的书籍：`SELECT "title", "translator" FROM "longlist" WHERE "translator" IS NULL;`。
  - 查询有译者的书籍：`SELECT "title", "translator" FROM "longlist" WHERE "translator" IS NOT NULL;`。

### 5. LIKE：模糊匹配
- 功能：根据字符串模式匹配数据，适用于不确定完整值的查询。
- 通配符：
  - %：匹配0个或多个任意字符。
  - _：匹配1个任意字符。
- 语法示例：
  - 书名包含“love”：`SELECT "title" FROM "longlist" WHERE "title" LIKE '%love%';`。
  - 书名以“The ”开头（仅“ The”后接空格，排除“Their”等）：`SELECT "title" FROM "longlist" WHERE "title" LIKE 'The %';`。
  - 书名是4个字符且以P开头：`SELECT "title" FROM "longlist" WHERE "title" LIKE 'P_re';`。
- 注意：SQLite中LIKE默认不区分大小写，=区分大小写（其他DBMS可能不同）。

### 6. Ranges：范围查询
- 功能：筛选数值型列的指定范围数据。
- 实现方式：
  - 用比较运算符：`WHERE "year" >= 2019 AND "year" <= 2022`（2019-2022年，含首尾）。
  - 用BETWEEN...AND：`WHERE "year" BETWEEN 2019 AND 2022`（与上述等价，含首尾）。
- 语法示例：
  - 评分≥4.0且票数>10000：`SELECT "title", "rating", "votes" FROM "longlist" WHERE "rating" > 4.0 AND "votes" > 10000;`。
  - 页数<300：`SELECT "title", "pages" FROM "longlist" WHERE "pages" < 300;`。

### 7. ORDER BY：结果排序
- 功能：按指定列对查询结果排序。
- 排序方式：
  - ASC：升序（默认，可省略）。
  - DESC：降序。
- 语法示例：
  - 按评分升序取前10（最低分10本）：`SELECT "title", "rating" FROM "longlist" ORDER BY "rating" LIMIT 10;`。
  - 按评分降序、票数降序取前10（最高分10本，票数破 tie）：`SELECT "title", "rating", "votes" FROM "longlist" ORDER BY "rating" DESC, "votes" DESC LIMIT 10;`。
  - 按书名字母序排序：`SELECT "title" FROM "longlist" ORDER BY "title";`。

### 8. 聚合函数
- 定义：对多行数据进行统计计算，返回单个聚合结果。
- 常用函数：
  | 函数 | 功能 | 示例 |
  |------|------|------|
  | AVG() | 计算平均值 | `SELECT AVG("rating") FROM "longlist";`（平均评分） |
  | ROUND() | 四舍五入 | `SELECT ROUND(AVG("rating"), 2) AS "average rating" FROM "longlist";`（平均评分保留2位小数，列重命名为average rating） |
  | MAX() | 取最大值 | `SELECT MAX("rating") FROM "longlist";`（最高评分） |
  | MIN() | 取最小值 | `SELECT MIN("rating") FROM "longlist";`（最低评分） |
  | SUM() | 求和 | `SELECT SUM("votes") FROM "longlist";`（总票数） |
  | COUNT() | 计数 | `SELECT COUNT(*) FROM "longlist";`（书籍总数，*表示所有行）；`SELECT COUNT("translator") FROM "longlist";`（非NULL译者数） |
  | DISTINCT | 去重计数 | `SELECT COUNT(DISTINCT "publisher") FROM "longlist";`（不重复出版商数） |
- 注意：COUNT()忽略NULL值；MAX()/MIN()用于字符串时，按字母序返回最后/第一个值，而非长度。

## 五、关键问题与注意事项
1. 标识符与字符串区分：表名/列名（标识符）用双引号，字符串用单引号。
2. 数据类型：数值型（整数、浮点数）无需引号，字符串需单引号。
3. 大小写敏感性：SQLite中SQL关键字大小写不敏感，但建议关键字大写、标识符小写（提高可读性）。
4. 数据库 schema：包含表结构、列名等信息，后续课程将学习如何查看。
5. 数据来源：示例数据库数据来自布克奖官网（2018-2023年长名单）和Goodreads（评分、票数等）。