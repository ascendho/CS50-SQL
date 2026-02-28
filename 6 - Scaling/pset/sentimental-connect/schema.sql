-- Users table
CREATE TABLE `users` (
    `id` INT UNSIGNED AUTO_INCREMENT,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `password` VARCHAR(128) NOT NULL,
    PRIMARY KEY (`id`)
);

-- Schools table
-- YEAR type only supports 1901–2155, so use SMALLINT UNSIGNED for founding year (e.g. Harvard 1636)
CREATE TABLE `schools` (
    `id` INT UNSIGNED AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    `type` ENUM('Primary', 'Secondary', 'Higher Education') NOT NULL,
    `location` VARCHAR(255) NOT NULL,
    `founded_year` SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (`id`)
);

-- Companies table
CREATE TABLE `companies` (
    `id` INT UNSIGNED AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    `industry` ENUM('Technology', 'Education', 'Business') NOT NULL,
    `location` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`id`)
);

-- Connections between users (people)
CREATE TABLE `people_connections` (
    `user_id` INT UNSIGNED NOT NULL,
    `connection_id` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`user_id`, `connection_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
    FOREIGN KEY (`connection_id`) REFERENCES `users`(`id`)
);

-- Connections between users and schools
CREATE TABLE `school_connections` (
    `id` INT UNSIGNED AUTO_INCREMENT,
    `user_id` INT UNSIGNED NOT NULL,
    `school_id` INT UNSIGNED NOT NULL,
    `start_date` DATE,
    `end_date` DATE,
    `degree` VARCHAR(255),
    PRIMARY KEY (`id`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
    FOREIGN KEY (`school_id`) REFERENCES `schools`(`id`)
);

-- Connections between users and companies
CREATE TABLE `company_connections` (
    `id` INT UNSIGNED AUTO_INCREMENT,
    `user_id` INT UNSIGNED NOT NULL,
    `company_id` INT UNSIGNED NOT NULL,
    `start_date` DATE,
    `end_date` DATE,
    `title` VARCHAR(255),
    PRIMARY KEY (`id`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
    FOREIGN KEY (`company_id`) REFERENCES `companies`(`id`)
);

-- Sample data

INSERT INTO `users` (`first_name`, `last_name`, `username`, `password`)
VALUES
    ('Claudine', 'Gay', 'claudine', 'password'),
    ('Reid', 'Hoffman', 'reid', 'password');

INSERT INTO `schools` (`name`, `type`, `location`, `founded_year`)
VALUES
    ('Harvard University', 'Higher Education', 'Cambridge, Massachusetts', 1636);

INSERT INTO `companies` (`name`, `industry`, `location`)
VALUES
    ('LinkedIn', 'Technology', 'Sunnyvale, California');

-- Claudine Gay's connection with Harvard (PhD, 1993–1998)
INSERT INTO `school_connections` (`user_id`, `school_id`, `start_date`, `end_date`, `degree`)
VALUES
    (1, 1, '1993-01-01', '1998-12-31', 'PhD');

-- Reid Hoffman's connection with LinkedIn (CEO and Chairman, 2003–2007)
INSERT INTO `company_connections` (`user_id`, `company_id`, `start_date`, `end_date`, `title`)
VALUES
    (2, 1, '2003-01-01', '2007-02-01', 'CEO and Chairman');
