# Relating

## 一、课程概述
- **课程主题**：多表关系管理与SQL高级查询，核心围绕“如何关联数据库中的多个表”及“复杂数据检索技巧”展开。
- **主讲人**：Carter Zenke、David J. Malan（哈佛大学）
- **核心工具**：延续SQLite，新增示例数据库（`longlist.db`含7个关联表、`sea_lions.db`用于JOIN演示）
- **课程目标**：掌握表间关系设计、主键/外键用法、子查询、JOIN、集合操作、分组统计等高级技能

## 二、核心概念：多表关系与ER图
### 1. 关系型数据库定义
- 数据库包含多个相互关联的表（如`longlist.db`中有books、authors、publishers、ratings等表），表间通过“关系”连接，称为**关系型数据库**。
- 表间关系的意义：避免数据冗余（如同一作者的多本书无需重复存储作者信息），提高数据一致性和查询效率。

### 2. 三种表间关系类型
| 关系类型 | 定义 | 示例 |
|----------|------|------|
| 一对一（One-to-One） | 一个实体仅对应另一个实体的一条记录，反之亦然 | 一本书对应一个唯一ISBN，一个ISBN仅对应一本书（严格场景） |
| 一对多（One-to-Many） | 一个实体可对应另一个实体的多条记录，反之仅一条 | 一个作者可写多本书，一本书仅属于一个出版商 |
| 多对多（Many-to-Many） | 两个实体间互相可对应多条记录 | 一个作者可写多本书，一本书可由多个作者合著 |

### 3. 实体关系图（ER图）
- **作用**：可视化表（实体）间的关系，是数据库设计与沟通的核心工具。
- **组成要素**：
  - 实体：数据库中的表（如Author、Book、Translator）。
  - 关系：实体间的关联（用动词标注，如“wrote”“published”“translated”）。
  - 乌鸦脚符号（Crow’s Foot Notation）：表示关系 cardinality（数量约束）：
    - 圆圈（○）：0个（可选关系）。
    - 竖线（|）：1个（必选关系）。
    - 乌鸦脚（⊏）：多个（不限数量）。
- **示例解读**：Book与Translator的关系为“0-多 ↔ 1-多”，即一本书可无译者或多个译者，一个译者至少翻译一本书（可多本）。

## 三、表关联核心：主键与外键
### 1. 主键（Primary Key, PK）
- **定义**：表中唯一标识每条记录的列，值不可重复、不可为NULL。
- **示例**：
  - 书籍表（books）：可用ISBN作为主键（天然唯一），或自定义数字ID（如1、2、3，更节省内存）。
  - 作者表（authors）：自定义`id`列作为主键，唯一标识每位作者。
- **核心特性**：唯一性、非空性，是表的“唯一身份证”。

### 2. 外键（Foreign Key, FK）
- **定义**：引用另一个表主键的列，用于建立表间关联，是“连接表的桥梁”。
- **示例**：
  - 评分表（ratings）中的`isbn`列引用书籍表（books）的`isbn`主键，形成“一本书对应多个评分”的一对多关系。
  - 关联表（Junction Table）：用于实现多对多关系，如`authored`表含`author_id`（引用authors.id）和`book_id`（引用books.id），记录作者与书籍的多对多映射。
- **关键注意事项**：
  - 外键值可重复（如同一本书的多个评分共用一个ISBN），但必须匹配引用表的主键值（或为NULL）。
  - 关联表仅用于存储多对多关系的映射，无额外业务数据。

### 3. 常见问题
- 不同表的主键值可重复（如作者ID=1和书籍ID=1），因归属不同表，无歧义。
- 关联表会占用少量额外空间，但避免了数据冗余，是多对多关系的唯一合理实现方式。
- 主键通常不修改（抽象化设计），若需修改，需同步更新所有引用它的外键（避免关联断裂）。

## 四、SQL高级查询语法
### 1. 子查询（Subqueries）
- **定义**：嵌套在其他查询中的查询（也称“嵌套查询”），用于分解复杂逻辑。
- **执行顺序**：从最内层查询开始执行，结果作为外层查询的条件或数据源。
- **语法规则**：
  - 子查询需用括号包裹。
  - 按风格规范缩进，提高可读性（无强制空格数要求）。
- **示例**：
  - 查找“Fitzcarraldo Editions”出版的所有书籍：
    ```sql
    SELECT "title"
    FROM "books"
    WHERE "publisher_id" = (
      SELECT "id"
      FROM "publishers"
      WHERE "publisher" = 'Fitzcarraldo Editions'
    );
    ```
  - 查找书籍《Flights》的作者（多表多对多关系）：
    ```sql
    SELECT "name"
    FROM "authors"
    WHERE "id" = (
      SELECT "author_id"
      FROM "authored"
      WHERE "book_id" = (
        SELECT "id"
        FROM "books"
        WHERE "title" = 'Flights'
      )
    );
    ```
- **注意**：若内层查询无结果，外层查询也返回空；子查询适用于逻辑分步的场景。

### 2. IN关键字
- **定义**：判断某个值是否存在于指定集合（如子查询结果）中，适用于多值匹配。
- **核心场景**：解决子查询返回多个结果的场景（替代`=`，`=`仅支持单值匹配）。
- **示例**：查找作者“Fernanda Melchor”写的所有书籍（多对多关系）：
  ```sql
  SELECT "title"
  FROM "books"
  WHERE "id" IN (
    SELECT "book_id"
    FROM "authored"
    WHERE "author_id" = (
      SELECT "id"
      FROM "authors"
      WHERE "name" = 'Fernanda Melchor'
    )
  );
  ```

### 3. JOIN：表连接操作
- **定义**：将两个或多个表按指定条件（通常是主键-外键匹配）合并为一个结果集，是多表查询的核心。
- **常用JOIN类型及区别**：
  | JOIN类型 | 核心特性 | 语法示例（海狮数据库） |
  |----------|----------|------------------------|
  | INNER JOIN（默认JOIN） | 仅保留所有表中匹配条件的行（交集） | `SELECT * FROM "sea_lions" JOIN "migrations" ON "sea_lions"."id" = "migrations"."id";` |
  | LEFT JOIN | 保留左表（第一个表）所有行，右表匹配不到则补NULL | `SELECT * FROM "sea_lions" LEFT JOIN "migrations" ON "sea_lions"."id" = "migrations"."id";` |
  | RIGHT JOIN | 保留右表（第二个表）所有行，左表匹配不到则补NULL | `SELECT * FROM "sea_lions" RIGHT JOIN "migrations" ON "sea_lions"."id" = "migrations"."id";` |
  | FULL JOIN | 保留所有表的所有行，匹配不到则补NULL（全量数据） | `SELECT * FROM "sea_lions" FULL JOIN "migrations" ON "sea_lions"."id" = "migrations"."id";` |
  | NATURAL JOIN | 自动按同名列（如`id`）匹配，无重复列，等价于INNER JOIN | `SELECT * FROM "sea_lions" NATURAL JOIN "migrations";` |
- **关键说明**：
  - `ON`关键字指定连接条件（必须，除非用NATURAL JOIN）。
  - 连接结果是**临时结果集**，不保存到数据库，需重新执行查询获取最新数据。
  - 多表连接时，左/右表针对每一次JOIN操作：前一个表为左表，当前连接的表为右表。

### 4. Sets：集合操作
- **定义**：将查询结果集（Set）视为数学集合，进行交集、并集、差集运算，需保证参与运算的集合“列数相同、类型一致”。
- **常用集合运算符**：
  | 运算符 | 作用 | 示例（作者与译者集合） |
  |--------|------|------------------------|
  | INTERSECT | 求交集（同时属于两个集合的元素） | 查找既是作者又是译者的人：<br>`SELECT "name" FROM "authors" INTERSECT SELECT "name" FROM "translators";` |
  | UNION | 求并集（属于任一集合的元素，自动去重） | 查找所有作者或译者（无重复）：<br>`SELECT "name" FROM "authors" UNION SELECT "name" FROM "translators";` |
  | EXCEPT | 求差集（属于前一个集合但不属于后一个集合的元素） | 查找仅为作者而非译者的人：<br>`SELECT "name" FROM "authors" EXCEPT SELECT "name" FROM "translators";` |
- **扩展示例**：查找两位译者共同翻译的书籍：
  ```sql
  SELECT "book_id" FROM "translated" WHERE "translator_id" = (SELECT "id" FROM "translators" WHERE "name" = 'Sophie Hughes')
  INTERSECT
  SELECT "book_id" FROM "translated" WHERE "translator_id" = (SELECT "id" FROM "translators" WHERE "name" = 'Margaret Jull Costa');
  ```

### 5. Groups：分组统计
- **核心关键字**：`GROUP BY`（分组）+ `HAVING`（筛选分组结果），结合聚合函数实现批量统计。
- **与WHERE的区别**：
  - `WHERE`：筛选**单个行**（分组前过滤数据）。
  - `HAVING`：筛选**分组结果**（分组后过滤统计值）。
- **语法示例**：
  - 按书籍分组，计算每本书的平均评分：
    ```sql
    SELECT "book_id", ROUND(AVG("rating"), 2) AS "average rating"
    FROM "ratings"
    GROUP BY "book_id";
    ```
  - 筛选平均评分>4.0的书籍，并按评分降序排序：
    ```sql
    SELECT "book_id", ROUND(AVG("rating"), 2) AS "average rating"
    FROM "ratings"
    GROUP BY "book_id"
    HAVING "average rating" > 4.0
    ORDER BY "average rating" DESC;
    ```
  - 统计每本书的评分数量：
    ```sql
    SELECT "book_id", COUNT("rating") AS "rating_count"
    FROM "ratings"
    GROUP BY "book_id";
    ```

## 五、关键问题与注意事项
1. **ER图与表关系**：表间关系由数据库设计者定义，ER图是沟通设计逻辑的工具，需结合业务场景确定关系类型（如“作者-书籍”是一对多还是多对多）。
2. **子查询与缩进**：缩进无强制格式，但合理缩进可大幅提升复杂查询的可读性。
3. **JOIN的NULL值**：LEFT/RIGHT/FULL JOIN可能产生NULL值（匹配不到的数据），需注意后续处理（如用`IS NOT NULL`过滤）。
4. **集合操作的约束**：INTERSECT/UNION/EXCEPT要求参与运算的集合“列数相同、数据类型一致”，否则报错。
5. **主键与外键的一致性**：外键必须引用其他表的主键，若主键值修改，需同步更新所有关联的外键（避免数据不一致）。
6. **关联表的作用**：多对多关系必须通过关联表（如`authored`）实现，无其他替代方案。