--Section 6--
SELECT Title, Domestic_sales, International_sales FROM movies JOIN Boxoffice ON Movies.Id = Boxoffice.Movie_id
SELECT Title, Domestic_sales, International_sales FROM movies JOIN Boxoffice ON Movies.Id = Boxoffice.Movie_id WHERE International_sales > Domestic_sales
SELECT Title, rating FROM movies JOIN Boxoffice ON Movies.Id = Boxoffice.Movie_id ORDER BY Rating DESC
--Section 7--
SELECT DISTINCT Building from Employees;
SELECT * FROM Buildings;
SELECT DISTINCT Building_name, role FROM Buildings LEFT JOIN Employees ON building_name = building
--Interview Question--
SELECT pages.page_id FROM pages LEFT JOIN page_likes 
ON pages.page_id = page_likes.page_id  
WHERE page_likes.page_id IS NULL
ORDER BY pages.page_id ASC;
