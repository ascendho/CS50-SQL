# Scaling

## 一、课程概述
- **课程主题**：数据库规模化应用，核心围绕“主流DBMS（MySQL/PostgreSQL）使用”“数据库扩展策略”“安全防护”三大核心，替代轻量的SQLite，适配大规模数据场景。
- **主讲人**：Carter Zenke、David J. Malan（哈佛大学）
- **核心工具**：MySQL（数据库服务器，支持高并发、细粒度类型）、PostgreSQL（功能更全面的数据库服务器）
- **核心区别**：SQLite是“嵌入式数据库”（本地文件存储），MySQL/PostgreSQL是“数据库服务器”（独立硬件运行，支持网络连接、内存存储，查询更快）
- **课程目标**：掌握MySQL/PostgreSQL的表设计、存储过程、访问控制，理解数据库扩展（垂直/水平）与安全防护（SQL注入）

## 二、MySQL核心用法
### 1. 连接与数据库基础操作
- **连接命令**：`mysql -u root -h 127.0.0.1 -P 3306 -p`
  - `-u`：指定用户（root为管理员）。
  - `-h`：数据库地址（127.0.0.1为本地主机）。
  - `-P`：端口（MySQL默认3306）。
  - `-p`：提示输入密码。
- **核心命令**：
  - 查看所有数据库：`SHOW DATABASES;`。
  - 创建数据库：`CREATE DATABASE `mbta`;`（用反引号标识标识符，替代SQLite的双引号）。
  - 切换数据库：`USE `mbta`;`。
  - 查看所有表：`SHOW TABLES;`。
  - 查看表结构：`DESCRIBE `cards`;`（或`DESC `cards`;`）。

### 2. 数据类型（细粒度，比SQLite更丰富）
#### （1）整数类型（按存储大小划分）
| 类型       | 存储大小 | 有符号范围                | 无符号范围（最大值翻倍） |
|------------|----------|---------------------------|--------------------------|
| TINYINT    | 1字节    | -128 ~ 127                | 0 ~ 255                  |
| SMALLINT   | 2字节    | -32,768 ~ 32,767          | 0 ~ 65,535               |
| MEDIUMINT  | 3字节    | -8,388,608 ~ 8,388,607    | 0 ~ 16,777,215           |
| INT        | 4字节    | -2,147,483,648 ~ 2,147,483,647 | 0 ~ 4,294,967,295      |
| BIGINT     | 8字节    | -2⁶³ ~ 2⁶³-1              | 0 ~ 2⁶⁴-1                |

#### （2）字符串类型
- CHAR：固定长度字符串（适用于长度确定的内容，如性别）。
- VARCHAR：可变长度字符串（适用于长度不确定的内容，如站名，需指定最大长度，如`VARCHAR(32)`）。
- TEXT：长文本（分TINYTEXT/TEXT/MEDIUMTEXT/LONGTEXT，适用于段落、书籍等）。
- ENUM：枚举类型（仅允许从预定义列表选一个值，如地铁线路`ENUM('blue', 'green', 'orange', 'red')`）。
- SET：集合类型（允许从预定义列表选多个值，如电影类型）。

#### （3）其他类型
- 日期时间：DATE（日期）、TIME（时间）、DATETIME（日期+时间）、TIMESTAMP（高精度时间戳）。
- 数值：FLOAT（单精度浮点数）、DOUBLE PRECISION（双精度浮点数）、DECIMAL(M,N)（固定精度小数，M为总位数，N为小数位数，如`DECIMAL(5,2)`表示最大999.99）。

### 3. 表创建与约束
#### （1）示例1：创建地铁卡表（`cards`）
```sql
CREATE TABLE `cards` (
  `id` INT AUTO_INCREMENT,  -- 自动递增主键（替代SQLite的自动生成）
  PRIMARY KEY(`id`)
);
```
- 关键：`AUTO_INCREMENT`让主键自动生成（无需手动指定），支持`UNSIGNED`关键字（无符号整数，扩大最大值）。

#### （2）示例2：创建车站表（`stations`）
```sql
CREATE TABLE `stations` (
  `id` INT AUTO_INCREMENT,
  `name` VARCHAR(32) NOT NULL UNIQUE,  -- 站名：可变长度、非空、唯一
  `line` ENUM('blue', 'green', 'orange', 'red') NOT NULL,  -- 线路：枚举类型
  PRIMARY KEY(`id`)
);
```

#### （3）示例3：创建刷卡记录表（`swipes`）
```sql
CREATE TABLE `swipes` (
  `id` INT AUTO_INCREMENT,
  `card_id` INT,
  `station_id` INT,
  `type` ENUM('enter', 'exit', 'deposit') NOT NULL,  -- 刷卡类型：进站/出站/充值
  `datetime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- 默认当前时间戳
  `amount` DECIMAL(5,2) NOT NULL CHECK(`amount` != 0),  -- 金额：非0、保留2位小数
  PRIMARY KEY(`id`),
  FOREIGN KEY(`card_id`) REFERENCES `cards`(`id`),  -- 外键关联地铁卡
  FOREIGN KEY(`station_id`) REFERENCES `stations`(`id`)  -- 外键关联车站
);
```
- 表结构说明：外键列在`DESCRIBE`中标记为`MUL`（允许重复值）。

### 4. 表修改（ALTER TABLE）
MySQL支持更灵活的表结构修改，如扩展ENUM类型选项：
```sql
-- 给车站表的line列添加silver线路
ALTER TABLE `stations`
MODIFY `line` ENUM('blue', 'green', 'orange', 'red', 'silver') NOT NULL;
```
- 关键：用`MODIFY`关键字修改列类型（SQLite无此功能）。

### 5. 存储过程（Stored Procedures）
- 定义：封装重复执行的SQL逻辑，类似编程语言的函数，支持参数传递。
- 核心步骤：修改语句分隔符（避免MySQL误判`;`为结束符）→ 创建存储过程 → 恢复分隔符。

#### （1）无参数存储过程（示例：查询未软删除的藏品）
```sql
-- 1. 修改分隔符为//
delimiter //

-- 2. 创建存储过程
CREATE PROCEDURE `current_collection`()
BEGIN
  SELECT `title`, `accession_number`, `acquired`
  FROM `collections`
  WHERE `deleted` = 0;  -- 软删除标记：0=未删除
END//

-- 3. 恢复分隔符为;
delimiter ;

-- 调用存储过程
CALL current_collection();
```

#### （2）带参数存储过程（示例：卖出藏品并记录交易）
```sql
-- 创建交易表
CREATE TABLE `transactions` (
  `id` INT AUTO_INCREMENT,
  `title` VARCHAR(64) NOT NULL,
  `action` ENUM('bought', 'sold') NOT NULL,
  PRIMARY KEY(`id`)
);

-- 创建带参数的存储过程（sold_id为藏品ID）
delimiter //
CREATE PROCEDURE `sell`(IN `sold_id` INT)
BEGIN
  -- 1. 软删除藏品
  UPDATE `collections` SET `deleted` = 1 WHERE `id` = `sold_id`;
  -- 2. 记录交易
  INSERT INTO `transactions` (`title`, `action`)
  VALUES ((SELECT `title` FROM `collections` WHERE `id` = `sold_id`), 'sold');
END//
delimiter ;

-- 调用：卖出ID=2的藏品
CALL `sell`(2);
```
- 支持的逻辑控制：`IF/ELSEIF/ELSE`、`LOOP`、`REPEAT`、`WHILE`（可实现复杂业务逻辑）。

## 三、PostgreSQL核心用法
### 1. 连接与基础命令
- **连接命令**：`psql postgresql://postgres@127.0.0.1:5432/postgres`（默认端口5432）。
- **核心命令**：
  - 查看所有数据库：`\l`。
  - 创建数据库：`CREATE DATABASE "mbta";`（支持双引号标识标识符）。
  - 切换数据库：`\c "mbta"`。
  - 查看所有表：`\dt`。
  - 查看表结构：`\d "cards"`。
  - 退出：`\q`。

### 2. 数据类型（与MySQL的关键区别）
- 整数类型：可选较少（SMALLINT/INT/BIGINT），支持无符号整数（最大值翻倍）。
- 自增主键：用`SERIAL`类型（替代MySQL的`AUTO_INCREMENT`），自动生成连续整数。
- 字符串类型：VARCHAR（无CHAR/SET，ENUM需自定义）、TEXT（长文本）。
- 枚举类型：需先自定义类型，再用于列（区别于MySQL的直接定义）。
- 数值类型：用`NUMERIC(M,N)`替代MySQL的`DECIMAL(M,N)`（固定精度小数）。
- 日期时间：TIMESTAMP（时间戳）、DATE（日期）、TIME（时间）、INTERVAL（时间间隔，如“2小时”）。

### 3. 表创建示例
#### （1）创建地铁卡表（`cards`）
```sql
CREATE TABLE "cards" (
  "id" SERIAL,  -- 自增主键
  PRIMARY KEY("id")
);
```

#### （2）创建自定义枚举类型（刷卡类型）
```sql
-- 先自定义枚举类型swipe_type
CREATE TYPE "swipe_type" AS ENUM('enter', 'exit', 'deposit');
```

#### （3）创建刷卡记录表（`swipes`）
```sql
CREATE TABLE "swipes" (
  "id" SERIAL,
  "card_id" INT,
  "station_id" INT,
  "type" "swipe_type" NOT NULL,  -- 使用自定义枚举类型
  "datetime" TIMESTAMP NOT NULL DEFAULT now(),  -- 默认当前时间（now()函数）
  "amount" NUMERIC(5,2) NOT NULL CHECK("amount" != 0),  -- 固定精度小数
  PRIMARY KEY("id"),
  FOREIGN KEY("card_id") REFERENCES "cards"("id"),
  FOREIGN KEY("station_id") REFERENCES "stations"("id")
);
```

## 四、数据库扩展策略（Scalability）
### 1. 垂直扩展（Vertical Scaling）
- 定义：提升单台数据库服务器的硬件性能（如增加CPU、内存、磁盘）。
- 优势：实现简单，无需修改数据库架构。
- 局限：硬件性能有上限，无法应对超大规模并发。

### 2. 水平扩展（Horizontal Scaling）
- 定义：将负载分布到多台服务器，核心分为“复制”和“分片”两种方式。

#### （1）复制（Replication）
- 核心：多台服务器存储相同数据库副本，分“主服务器（Leader）”和“从服务器（Follower）”。
- 常见模型：单主从（Single-Leader）
  - 主服务器：处理所有写入操作（INSERT/UPDATE/DELETE）。
  - 从服务器：仅处理读取操作（SELECT），同步主服务器数据。
- 同步方式：
  - 同步复制：主服务器等待从服务器同步完成后，再返回写入结果（数据一致，但响应慢，适用于金融、医疗）。
  - 异步复制：主服务器写入后立即返回，异步同步到从服务器（响应快，可能有短暂数据不一致，适用于社交媒体）。

#### （2）分片（Sharding）
- 定义：将数据库按规则拆分到多台服务器（如按用户ID范围、地区拆分），每台服务器存储部分数据（分片）。
- 注意事项：
  - 避免“热点分片”：某台服务器被频繁访问，导致负载不均。
  - 需配合复制：防止单台服务器故障导致数据丢失（单点故障）。

## 五、安全防护
### 1. 访问控制（权限管理）
- 核心：创建专用用户，仅授予必要权限（避免使用root用户）。
- 操作示例：
  ```sql
  -- 1. 创建新用户carter，密码为password
  CREATE USER 'carter' IDENTIFIED BY 'password';
  
  -- 2. 授予用户carter访问rideshare数据库的analysis视图的SELECT权限
  GRANT SELECT ON `rideshare`.`analysis` TO 'carter';
  ```
- 效果：用户carter仅能查询`analysis`视图（匿名化数据），无法访问原表（含敏感PII数据）。

### 2. SQL注入攻击与防护
#### （1）攻击原理
- 恶意用户注入SQL代码，篡改查询逻辑。例如，登录接口的查询：
  - 正常查询：`SELECT `id` FROM `users` WHERE `user` = 'Carter' AND `password` = 'password';`。
  - 注入攻击：输入密码为`'password' OR '1' = '1'`，查询变为：
    ```sql
    SELECT `id` FROM `users` WHERE `user` = 'Carter' AND `password` = 'password' OR '1' = '1';
    ```
  - 结果：`'1' = '1'`恒为真，无需正确密码即可登录。

#### （2）防护方案：预处理语句（Prepared Statements）
- 核心：用占位符（`?`）替代直接拼接用户输入，自动过滤恶意代码。
- 操作示例：
  ```sql
  -- 1. 定义预处理语句（?为占位符）
  PREPARE `balance_check` FROM 'SELECT * FROM `accounts` WHERE `id` = ?';
  
  -- 2. 传入用户输入（模拟应用获取的ID）
  SET @id = 1;  -- @表示MySQL变量
  
  -- 3. 执行预处理语句
  EXECUTE `balance_check` USING @id;
  ```
- 效果：即使输入恶意值（如`'1 UNION SELECT * FROM `accounts`'`），预处理语句会自动“转义”，仅当作普通字符串处理，避免注入。

## 六、关键问题与注意事项
1. **MySQL与PostgreSQL的核心区别**：
   - 枚举类型：MySQL直接定义，PostgreSQL需先自定义类型。
   - 自增主键：MySQL用`AUTO_INCREMENT`，PostgreSQL用`SERIAL`。
   - 小数类型：MySQL用`DECIMAL`，PostgreSQL用`NUMERIC`。
   - 命令风格：MySQL用反引号，PostgreSQL支持双引号，基础命令（查看数据库/表）不同。
2. **存储过程的优势**：封装重复逻辑，减少网络传输（一次调用执行多步SQL）。
3. **扩展策略选择**：中小规模用垂直扩展，大规模高并发用水平扩展（单主从复制+分片）。
4. **安全最佳实践**：最小权限原则（避免过度授权）、禁用SQL拼接、使用预处理语句防注入。
5. **SQLite的局限性**：不支持高并发、无访问控制，仅适用于小规模应用；大规模场景优先选择MySQL/PostgreSQL。
