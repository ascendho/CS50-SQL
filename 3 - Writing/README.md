# Writing

## 一、课程概述

- **课程主题**：数据操作核心（增删改，即CRUD中的CUD），聚焦“如何向数据库插入、删除、更新数据”，以及约束对数据操作的影响、CSV数据导入技巧。
- **主讲人**：Carter Zenke、David J. Malan（哈佛大学）
- **核心工具**：SQLite，示例数据库`mfa.db`（模拟波士顿美术馆MFA的藏品与艺术家数据，含`collections`“藏品表”、`artists`“艺术家表”、`created`“藏品-艺术家关联表”）
- **课程目标**：掌握`INSERT`（插入）、`DELETE`（删除）、`UPDATE`（更新）语法，理解数据约束的作用，学会CSV批量导入数据，解决外键依赖下的数据操作问题

## 二、核心基础：数据库Schema回顾
操作数据前需明确表结构，`mfa.db`核心表结构如下：
### 1. 藏品表（`collections`）
```sql
CREATE TABLE "collections" (
  "id" INTEGER,  -- 主键（自动生成或手动指定）
  "title" TEXT NOT NULL,  -- 藏品名称（必填）
  "accession_number" TEXT NOT NULL UNIQUE,  -- 馆藏编号（必填+唯一）
  "acquired" NUMERIC,  -- 收藏日期（可选，可存NULL）
  PRIMARY KEY("id")
);
```
### 2. 艺术家与关联表（多对多关系）
- 艺术家表（`artists`）：含`id`（主键）、`name`（艺术家姓名）。
- 关联表（`created`）：实现“一个艺术家可创作多件藏品，一件藏品可由多个艺术家创作”的多对多关系，含`artist_id`（外键，引用`artists.id`）、`collection_id`（外键，引用`collections.id`）。

## 三、数据插入：INSERT INTO
### 1. 基本语法
```sql
INSERT INTO 表名 ("列1", "列2", ...)
VALUES (值1, 值2, ...);
```
- **核心规则**：列名与值的顺序必须一致；字符串用单引号，数值/日期无需引号（日期建议按`'YYYY-MM-DD'`格式存储）。

### 2. 单条数据插入
#### （1）手动指定主键
```sql
INSERT INTO "collections" ("id", "title", "accession_number", "acquired")
VALUES (1, 'Profusion of flowers', '56.257', '1956-04-12');
```
- 验证插入结果：`SELECT * FROM "collections";`（返回新增行）。

#### （2）自动生成主键（推荐）
SQLite主键列若省略，会自动取“当前最大主键+1”作为新主键，避免手动输入错误：
```sql
INSERT INTO "collections" ("title", "accession_number", "acquired")
VALUES ('Farmers working at dawn', '11.6152', '1911-08-03');
```
- 插入后主键自动为`2`（承接上一条的`1`）。

### 3. 多条数据插入
用逗号分隔多个`VALUES`子句，批量插入（高效，避免多次执行`INSERT`）：
```sql
INSERT INTO "collections" ("title", "accession_number", "acquired")
VALUES
  ('Imaginative landscape', '56.496', NULL),  -- 收藏日期未知，存NULL
  ('Peonies and butterfly', '06.1899', '1906-01-01');
```
- 注意：若其中一条数据违反约束（如重复`accession_number`），**所有数据均插入失败**（原子性操作）。

### 4. CSV批量导入数据
CSV（逗号分隔值）是批量导入数据的常用格式，SQLite提供`.import`命令支持直接导入，分两种场景：

#### （1）CSV含主键列（直接导入）
- CSV文件（`mfa.csv`）格式（首行为列名）：
  ```
  id,title,accession_number,acquired
  1,Profusion of flowers,56.257,1956-04-12
  2,Farmers working at dawn,11.6152,1911-08-03
  ```
- 导入命令：
  ```sql
  .import --csv --skip 1 mfa.csv collections
  ```
  - `--csv`：指定文件类型为CSV。
  - `--skip 1`：跳过首行（列名行，避免插入表中）。

#### （2）CSV不含主键列（用临时表导入）
若CSV无`id`列（需SQLite自动生成主键），直接导入会因列数不匹配失败，需借助**临时表**中转：
1. 编辑CSV（删除`id`列）：
   ```
   title,accession_number,acquired
   Profusion of flowers,56.257,1956-04-12
   Farmers working at dawn,11.6152,1911-08-03
   ```
2. 导入CSV到临时表（`temp`为SQLite临时表，自动按CSV首行生成列名）：
   ```sql
   .import --csv mfa.csv temp  -- 无需--skip 1，SQLite自动识别表头
   ```
3. 从临时表插入数据到目标表（`collections`），主键自动生成：
   ```sql
   INSERT INTO "collections" ("title", "accession_number", "acquired")
   SELECT "title", "accession_number", "acquired" FROM "temp";
   ```
4. 清理临时表（可选）：
   ```sql
   DROP TABLE "temp";
   ```

### 5. 插入数据的约束校验
表结构中的约束（`NOT NULL`、`UNIQUE`）会阻止非法数据插入，违反约束会报错：
- 违反`NOT NULL`：插入`title`为`NULL`的行，报错`Runtime error: NOT NULL constraint failed`。
- 违反`UNIQUE`：插入重复`accession_number`的行，报错`Runtime error: UNIQUE constraint failed`。
- 作用：约束是数据完整性的“护栏”，避免无效/重复数据。

## 四、数据删除：DELETE
### 1. 基本语法
```sql
DELETE FROM 表名 [WHERE 条件];
```
- 无`WHERE`子句：删除表中**所有行**（谨慎使用！）。
- 有`WHERE`子句：仅删除满足条件的行（精准删除）。

### 2. 常见删除场景
#### （1）删除所有行
```sql
DELETE FROM "collections";  -- 清空藏品表（无恢复，慎用）
```
#### （2）条件删除（按具体条件）
- 删除指定名称的藏品：
  ```sql
  DELETE FROM "collections" WHERE "title" = 'Spring outing';
  ```
- 删除收藏日期为`NULL`的藏品：
  ```sql
  DELETE FROM "collections" WHERE "acquired" IS NULL;
  ```
- 删除1909年之前收藏的藏品（日期字符串支持比较运算）：
  ```sql
  DELETE FROM "collections" WHERE "acquired" < '1909-01-01';
  ```

### 3. 外键约束下的删除问题
当表存在外键依赖时（如`created`表引用`artists.id`），直接删除被引用的主键会触发约束报错，需通过`ON DELETE`子句指定处理逻辑：

#### （1）问题示例
若直接删除`artists`表中`id=3`的艺术家，而`created`表有引用该`id`的行，报错：`Runtime error: FOREIGN KEY constraint failed`。

#### （2）`ON DELETE`的5种处理方式
在定义外键时指定`ON DELETE`，解决依赖删除问题：
| `ON DELETE` 选项 | 作用 | 示例 |
|------------------|------|------|
| RESTRICT | 禁止删除被外键引用的主键（默认行为） | 无法删除有藏品关联的艺术家 |
| NO ACTION | 允许删除主键，但外键列保留原引用值（可能导致无效引用） | 艺术家被删，`created.artist_id`仍为3 |
| SET NULL | 删除主键时，外键列设为`NULL`（需外键列允许`NULL`） | 艺术家被删，`created.artist_id`变为`NULL` |
| SET DEFAULT | 删除主键时，外键列设为默认值（需提前定义默认值） | 外键列默认值为0，删除后设为0 |
| CASCADE | 级联删除：删除主键时，自动删除所有引用该主键的外键行 | 删除艺术家时，`created`表中该艺术家的关联行同步删除 |

#### （3）级联删除示例（推荐用于多对多关系）
定义外键时添加`ON DELETE CASCADE`：
```sql
CREATE TABLE "created" (
  "artist_id" INTEGER,
  "collection_id" INTEGER,
  FOREIGN KEY("artist_id") REFERENCES "artists"("id") ON DELETE CASCADE,  -- 级联删除
  FOREIGN KEY("collection_id") REFERENCES "collections"("id") ON DELETE CASCADE
);
```
- 此时删除艺术家，关联的`created`表行自动删除，无报错：
  ```sql
  DELETE FROM "artists" WHERE "name" = 'Unidentified artist';
  ```

### 4. 主键删除后的复用规则
- 默认行为：SQLite生成主键时，取“当前表中最大主键+1”，删除的主键值**不会自动重用**（如删除`id=3`，下一个主键为`max(id)+1`，而非3）。
- 强制重用：创建表时给主键列加`AUTOINCREMENT`关键字（需手动设置）。

## 五、数据更新：UPDATE
### 1. 基本语法
```sql
UPDATE 表名
SET "列1" = 值1, "列2" = 值2, ...
WHERE 条件;
```
- 核心：`WHERE`子句指定更新的行，**无`WHERE`则更新表中所有行**（极其危险，慎用！）。
- 支持子查询：`SET`或`WHERE`中可嵌套`SELECT`，动态获取值。

### 2. 实操示例：修改藏品的艺术家归属
场景：藏品“Farmers working at dawn”原归属“Unidentified artist”，现更正为“Li Yin”：
```sql
UPDATE "created"
SET "artist_id" = (
  SELECT "id" FROM "artists" WHERE "name" = 'Li Yin'  -- 子查询获取Li Yin的ID
)
WHERE "collection_id" = (
  SELECT "id" FROM "collections" WHERE "title" = 'Farmers working at dawn'  -- 子查询获取藏品ID
);
```
- 执行逻辑：先通过子查询获取目标艺术家ID和藏品ID，再更新`created`表中的关联关系。

## 六、关键问题与注意事项
1. **主键自动生成规则**：SQLite默认取“最大主键+1”，删除后不重用，需`AUTOINCREMENT`关键字强制重用。
2. **多条插入的原子性**：批量插入时，一条数据违反约束→所有数据插入失败（保证数据一致性）。
3. **CSV导入的空值处理**：CSV中的空单元格会被解析为“空字符串”，而非`NULL`，需手动用`UPDATE`转换（如`UPDATE "collections" SET "acquired" = NULL WHERE "acquired" = '';`）。
4. **删除/更新的`WHERE`必要性**：无`WHERE`会操作全表，生产环境需严格校验条件，避免误删/误更。
5. **外键`ON DELETE`的选择**：多对多关系推荐`CASCADE`（级联删除），一对一/一对多关系可根据需求选`SET NULL`或`RESTRICT`。
6. **临时表的作用**：仅用于数据中转（如CSV导入），数据库关闭后自动删除，不占用持久存储。
7. **数据类型兼容性**：插入/更新时，值的类型需与列的“类型亲和性”匹配（如`NUMERIC`列可接收日期字符串，SQLite自动适配）。