SELECT
	cs_Posts.PostID AS id,
	cs_Posts.ParentID AS parent,
	cs_Posts.ThreadID AS topic,
	cs_Posts.UserID AS author,
	cs_Posts.SectionID AS category,
	'"' + REPLACE(CAST(cs_Posts.[Subject] AS nvarchar(max)), '"', '""') + '"' AS title,
	cs_Posts.PostDate AS created_at,
	'"' + REPLACE(CAST(cs_Posts.Body AS nvarchar(max)), '"', '""') + '"' AS [raw],
	-- FUCKING HELL why is there no CONCAT function http://stackoverflow.com/a/7806049
	'"' + REPLACE(STUFF((SELECT ', ' + CAST(cs_Post_Categories.Name AS nvarchar(max))
		FROM cs_Post_Categories
		WHERE cs_Post_Categories.CategoryID IN (SELECT cs_Posts_InCategories.CategoryID
			FROM cs_Posts_InCategories
			WHERE cs_Posts_InCategories.PostID = cs_Posts.PostID)
		FOR XML PATH(''), TYPE
		).value('(./text())[1]', 'nvarchar(max)'), 1, 2, ''), '"', '""') + '"' AS tags
FROM cs_Posts
WHERE PostType = 1 AND PostConfiguration = 0
ORDER BY id ASC;
