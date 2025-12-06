# Viewing

## 一、课程概述

- **课程主题**：聚焦SQL视图（View）与公共表表达式（CTE），核心围绕“如何通过虚拟表简化复杂查询、聚合数据、拆分数据、增强安全”，以及软删除的实现。
- **主讲人**：Carter Zenke、David J. Malan（哈佛大学）
- **核心工具**：SQLite，示例数据库`longlist.db`（布克奖长名单书籍）、`rideshare.db`（网约车数据）、`mfa.db`（美术馆藏品数据）
- **课程目标**：掌握View的创建与四大应用场景、CTE的使用、软删除实现，理解虚拟表与物理表的区别

## 二、核心概念：视图（View）
### 1. 视图定义与本质
- 视图是**基于查询结果创建的虚拟表**，不存储实际数据，数据仍来自底层物理表。
- 核心特性：
  - 不占用额外磁盘空间（仅存储查询逻辑）。
  - 底层表数据更新时，视图查询结果自动同步（动态关联）。
  - 可像物理表一样使用（支持`SELECT`查询，部分场景可通过触发器间接更新）。
- 核心价值：简化复杂查询、复用查询逻辑、数据分区、隐藏敏感信息。

### 2. 视图创建语法
```sql
CREATE [TEMPORARY] VIEW "视图名" AS
SELECT 列1, 列2, ...
FROM 表1
[JOIN 表2 ON 关联条件]
[GROUP BY 列]
[ORDER BY 列];
```
- `TEMPORARY`：可选，创建临时视图（仅在当前数据库连接有效，断开后自动删除）。
- 关键：视图的查询逻辑可包含`JOIN`、聚合函数、`WHERE`等任意SQL语法。

## 三、视图的四大核心应用场景
### 1. 简化查询（Simplifying）
- **作用**：将多表关联、嵌套查询等复杂逻辑封装为视图，后续查询直接调用视图，无需重复编写复杂SQL。
- **示例场景**：查询特定作者的书籍（需关联`authors`“作者表”、`authored`“关联表”、`books`“书籍表”）。
  - 原复杂嵌套查询：
    ```sql
    SELECT "title" FROM "books"
    WHERE "id" IN (
      SELECT "book_id" FROM "authored"
      WHERE "author_id" = (
        SELECT "id" FROM "authors" WHERE "name" = 'Fernanda Melchor'
      )
    );
    ```
  - 步骤1：创建关联视图（封装多表JOIN逻辑）
    ```sql
    CREATE VIEW "longlist" AS
    SELECT "authors"."name" AS "author_name", "books"."title" AS "book_title"
    FROM "authors"
    JOIN "authored" ON "authors"."id" = "authored"."author_id"
    JOIN "books" ON "books"."id" = "authored"."book_id";
    ```
  - 步骤2：通过视图简化查询
    ```sql
    SELECT "book_title" FROM "longlist" WHERE "author_name" = 'Fernanda Melchor';
    ```
- **关键技巧**：多表JOIN时，优先通过“主键-外键”关联（如`authors.id`与`authored.author_id`）。

### 2. 数据聚合（Aggregating）
- **作用**：将聚合函数（`AVG`、`SUM`等）的计算结果封装为视图，支持后续二次聚合或快速查询。
- **示例场景**：计算每本书的平均评分，并关联书籍标题和入围年份。
  - 步骤1：创建聚合视图
    ```sql
    CREATE VIEW "average_book_ratings" AS
    SELECT 
      "books"."id" AS "book_id",
      "books"."title" AS "book_title",
      "books"."year" AS "longlist_year",
      ROUND(AVG("ratings"."rating"), 2) AS "avg_rating"
    FROM "ratings"
    JOIN "books" ON "ratings"."book_id" = "books"."id"
    GROUP BY "books"."id";  -- 按书籍分组计算平均评分
    ```
  - 步骤2：基于视图二次聚合（计算每年入围书籍的平均评分）
    ```sql
    CREATE TEMPORARY VIEW "average_ratings_by_year" AS
    SELECT 
      "longlist_year",
      ROUND(AVG("avg_rating"), 2) AS "yearly_avg_rating"
    FROM "average_book_ratings"
    GROUP BY "longlist_year";
    ```
- **注意**：聚合视图的逻辑顺序为“先JOIN关联表，再GROUP BY聚合”。

### 3. 数据分区（Partitioning）
- **作用**：将单表中的数据按逻辑条件拆分为多个视图（如按年份、类别），适配特定场景（如网站按年份展示数据）。
- **示例场景**：创建2022年入围书籍的专属视图
  ```sql
  CREATE VIEW "2022_longlist" AS
  SELECT "id", "title", "author_id"
  FROM "books"
  WHERE "year" = 2022;  -- 按年份分区
  ```
- **查询视图**：直接获取分区数据，无需重复写`WHERE`条件
  ```sql
  SELECT * FROM "2022_longlist";
  ```

### 4. 增强安全（Securing）
- **作用**：隐藏敏感列（如个人身份信息PII），仅暴露必要数据给特定用户（如分析师），避免数据泄露。
- **示例场景**：网约车数据库中，向分析师隐藏骑手姓名（匿名化）
  - 原表（`rides`）含敏感列`rider`（骑手姓名）。
  - 创建安全视图（仅暴露起点、终点，骑手姓名匿名化）：
    ```sql
    CREATE VIEW "ride_analysis" AS
    SELECT 
      "id",
      "origin" AS "start_point",
      "destination" AS "end_point",
      'Anonymous' AS "rider"  -- 匿名化处理
    FROM "rides";
    ```
- **注意**：SQLite本身无访问控制，需依赖视图逻辑+权限管理（如仅允许分析师查询视图，禁止访问原表）。

## 四、公共表表达式（CTE）
### 1. CTE定义与特性
- 全称：Common Table Expression（公共表表达式），是**仅在单个查询中有效临时视图**。
- 与视图的区别：
  | 特性 | 视图（View） | CTE |
  |------|--------------|-----|
  | 生命周期 | 永久（除非手动删除）/临时（连接有效） | 仅当前查询有效 |
  | 适用场景 | 多次复用查询逻辑 | 单次查询中的复杂逻辑拆分 |
  | 存储 | 写入数据库schema | 仅在查询执行时临时生成 |
- 核心价值：简化单次复杂查询的逻辑结构（替代多层嵌套子查询）。

### 2. CTE语法与示例
```sql
WITH "CTE名称" AS (
  -- CTE的查询逻辑（可包含JOIN、聚合等）
  SELECT 列1, 列2, ...
  FROM 表
  GROUP BY 列
)
-- 主查询（使用CTE）
SELECT 列 FROM "CTE名称"
GROUP BY 列;
```
- **示例场景**：用CTE计算每年入围书籍的平均评分（替代临时视图）
  ```sql
  WITH "book_avg_ratings" AS (
    SELECT 
      "books"."year",
      ROUND(AVG("ratings"."rating"), 2) AS "book_rating"
    FROM "ratings"
    JOIN "books" ON "ratings"."book_id" = "books"."id"
    GROUP BY "books"."id"
  )
  SELECT 
    "year",
    ROUND(AVG("book_rating"), 2) AS "yearly_avg"
  FROM "book_avg_ratings"
  GROUP BY "year";
  ```
- 优势：逻辑分层清晰，比嵌套子查询更易读、易维护。

## 五、软删除（Soft Deletions）
### 1. 软删除定义
- 不物理删除表中的行，而是通过“标记字段”（如`deleted`）标识数据是否删除，保留数据历史记录。
- 核心逻辑：
  1. 给表添加`deleted`列（0=未删除，1=已删除）。
  2. 创建视图，仅显示`deleted=0`的未删除数据。
  3. 通过触发器（Trigger）实现“删除视图行→更新标记字段”的联动。

### 2. 软删除实现步骤（以美术馆藏品为例）
#### （1）给表添加标记列
```sql
ALTER TABLE "collections" ADD COLUMN "deleted" INTEGER DEFAULT 0;
-- DEFAULT 0：默认所有数据为“未删除”
```

#### （2）创建“未删除数据”视图
```sql
CREATE VIEW "current_collections" AS
SELECT "id", "title", "accession_number", "acquired"
FROM "collections"
WHERE "deleted" = 0;  -- 仅显示未删除藏品
```

#### （3）创建触发器：通过视图间接更新标记字段
- 触发器1：删除视图行→标记`deleted=1`（软删除）
  ```sql
  CREATE TRIGGER "soft_delete"
  INSTEAD OF DELETE ON "current_collections"
  FOR EACH ROW
  BEGIN
    UPDATE "collections"
    SET "deleted" = 1
    WHERE "id" = OLD."id";  -- OLD：指代视图中要删除的行
  END;
  ```
- 触发器2：插入视图行→若数据已软删除，则恢复（`deleted=0`）；否则新增
  ```sql
  -- 场景1：恢复已软删除的数据
  CREATE TRIGGER "restore_deleted"
  INSTEAD OF INSERT ON "current_collections"
  FOR EACH ROW
  WHEN NEW."accession_number" IN (SELECT "accession_number" FROM "collections")
  BEGIN
    UPDATE "collections"
    SET "deleted" = 0
    WHERE "accession_number" = NEW."accession_number";  -- NEW：指代要插入的行
  END;
  
  -- 场景2：新增未存在的数据
  CREATE TRIGGER "insert_new"
  INSTEAD OF INSERT ON "current_collections"
  FOR EACH ROW
  WHEN NEW."accession_number" NOT IN (SELECT "accession_number" FROM "collections")
  BEGIN
    INSERT INTO "collections" ("title", "accession_number", "acquired")
    VALUES (NEW."title", NEW."accession_number", NEW."acquired");
  END;
  ```

#### （4）使用视图实现软删除/恢复
- 软删除：删除视图中的行，触发`soft_delete`触发器
  ```sql
  DELETE FROM "current_collections" WHERE "title" = 'Imaginative landscape';
  ```
- 恢复数据：插入已软删除的`accession_number`，触发`restore_deleted`触发器
  ```sql
  INSERT INTO "current_collections" ("title", "accession_number")
  VALUES ('Imaginative landscape', '56.496');
  ```

## 六、关键问题与注意事项
1. **视图的可更新性**：视图本身不能直接插入/删除数据（无实际存储），需通过`INSTEAD OF`触发器间接操作底层表。
2. **临时视图与CTE的区别**：临时视图可在当前连接的多个查询中复用，CTE仅在单个查询中有效。
3. **视图的性能**：视图不优化查询性能（本质是复用查询逻辑），复杂视图的查询速度依赖底层表的索引设计。
4. **软删除的优势**：保留数据历史，支持数据恢复；避免物理删除导致的外键约束冲突。
5. **SQLite的局限**：无原生访问控制，视图的安全依赖“仅提供视图查询权限”的外部配置。
6. **视图的命名规范**：避免用数字开头（如`2022`），建议添加前缀（如`v_2022_longlist`），增强可读性。

