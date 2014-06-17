SELECT
	SectionID AS id,
	'"' + REPLACE(Name, '"', '""') + '"' AS name,
	'"' + REPLACE([Description], '"', '""') + '"' AS [description],
	SortOrder AS position
FROM cs_Sections
WHERE ForumType = 0 AND ApplicationType = 0
ORDER BY SectionID ASC;
