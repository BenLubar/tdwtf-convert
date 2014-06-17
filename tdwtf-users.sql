SELECT
	cs_Users.UserID AS id,
	'"' + REPLACE(cs_Users.Email, '"', '""') + '"' AS email,
	'"' + REPLACE(cs_Users.UserName, '"', '""') + '"' AS name,
	cs_Users.CreateDate AS created_at
FROM cs_Users
ORDER BY id ASC;
