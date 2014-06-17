SELECT
	cs_Users.UserID AS id,
	'"' + REPLACE(cs_Users.Email, '"', '""') + '"' AS email,
	'"' + REPLACE(cs_Users.UserName, '"', '""') + '"' AS name,
	cs_Users.CreateDate AS created_at,
	CONVERT(nvarchar(max), CAST(cs_UserAvatar.Content AS varbinary(max)), 2) AS avatar
FROM cs_Users
LEFT JOIN cs_UserAvatar ON cs_Users.UserID = cs_UserAvatar.UserID
ORDER BY id ASC;
