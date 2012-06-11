CREATE TABLE `plays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `search_blob` text COLLATE utf8_unicode_ci,
  `artist` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `song_title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `station_id` int(11) DEFAULT NULL,
  `started_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  FULLTEXT KEY `fulltext_plays` (`search_blob`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `stations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `stream_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('20120610193810');

INSERT INTO schema_migrations (version) VALUES ('20120610193821');