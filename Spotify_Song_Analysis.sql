SELECT *
FROM Popular_Spotify_Songs pss ;


SELECT COUNT(*)
FROM Popular_Spotify_Songs pss ;

-- Task:count how many each artist has streamed songs on spotify
-- Result: It showed me how many songs have each artist on spotify.
-- 1th Taylor Swift 34 songs in total
-- 2d The Weeknd 21 songs in total
-- 3d SZA 19 songs oin total
-- Problem: It counts songs for artists separately if an artist was not solo

SELECT `artist(s)_name` ,COUNT(DISTINCT track_name) as num_track
FROM Popular_Spotify_Songs pss
GROUP BY `artist(s)_name`
ORDER BY COUNT(DISTINCT track_name) DESC;

-- ///////////--

-- Task: See the proportion of song collaboration/solo.
-- Result: This query did not show me proportions since it counted by artist_count. (8 different types)

SELECT artist_count ,Count(CASE WHEN artist_count > 1 THEN 'Collaborative'
ELSE 'SOLO' END) AS types
FROM Popular_Spotify_Songs pss
GROUP by artist_count
ORDER BY types DESC;-- it shows 8 rows. 1 solo - 586 songs, 2 singers - 254 songs, 3 singers 85 songs, 4 singers 15 songs, 5 -5, 6-3, 7-2, 8-2

-- ////////////---

-- Task: Changing syntax in order to limit result by two rows. SOLO and other Collaborative
-- Result: It showed me two columns "Solo" 586 songs and 'Collaboration ' 366 songs

 SELECT COUNT(CASE WHEN artist_count = 1 THEN '1'
 END) as solo,
 COUNT(CASE WHEN artist_count > 1 THEN '2' END) as collaboration
 FROM Popular_Spotify_Songs pss;

-- FOR visualisation purpose
  SELECT types, count(*)
      FROM(
  SELECT track_name,
         CASE WHEN artist_count = 1 THEN 'SOLO'
         WHEN artist_count > 1 THEN 'Collaboration' END as types
  FROM Popular_Spotify_Songs) AS Subquery
  GROUP BY types;

 -- SUM function returns the same value since I used quantitative variables. BUT IT IS BECAUSE I USED "1" IN BOTH CASES.
 -- If I used "2" instead of '1' in the second condition, it would give me the sum of rows by increasing quantity by twice.
 SELECT SUM(CASE WHEN artist_count = 1 THEN '1'
 END) as solo,
 SUM(CASE WHEN artist_count > 1 THEN '1' END) as collaboration
 FROM Popular_Spotify_Songs pss;

 -- TASK: RETRIEVE INFORMATION IN PROPORTION
 -- Result: I was able to retrieve information in percentage SOLO 61.55% Collaboration 38.45%

 SELECT COUNT(*) as num_track, ROUND(COUNT(CASE WHEN artist_count = 1 THEN '1'
 END)/ COUNT(*) * 100,2) as solo_perc,
  ROUND(COUNT(CASE WHEN artist_count > 1 THEN '1'
 END)/ COUNT(*)* 100,2) as colloboration_perc
 FROM Popular_Spotify_Songs pss;

-- ////////////

-- Task: what songs are streamed the most
-- Result: The most 10 streamed songs: Blinding lights, Shape of You, Someone You loved,
--         Dance Monkey, Sunflower-Spider-Man, Once dance, Stay(with Justin Biber),
--          Believer, Closer, Starboy

SELECT `artist(s)_name` ,track_name,
rank () over (order by streams DESC) as top_rank
FROM Popular_Spotify_Songs pss
LIMIT 10;

-- Task: What songs was in the most number of playlists. Spotify_playlist
-- Result: Get Lucky - radio edit, Mr.Brightside, Wake me up, Smells like teen spirit - remastered 2021, take on me, Blinding lights
--         One dance, Somebody that I used to know.

SELECT
	`artist(s)_name` ,
	track_name,
	in_spotify_playlists,
	rank () over (
	order by in_spotify_playlists DESC) as top_song
FROM
	Popular_Spotify_Songs pss
LIMIT 10;
-- Checking the result above. Spotify playlist.
-- Result: Get Lucky - radio edit, Mr.Brightside, Wake me up, Smells like teen spirit - remastered 2021, take on me, Blinding lights etc.

SELECT track_name , MAX(in_spotify_playlists) AS top_count
FROM Popular_Spotify_Songs pss
GROUP BY track_name
ORDER BY top_count desc
LIMIT 10;

-- ////////////---

-- TASK: try to sum up all playlist by track_name
-- Result: The song that is in the most number of playlist is Smells Like Teen Spirit

SELECT Popular_Spotify_Songs.track_name, SUM(in_spotify_playlists + in_apple_playlists + in_deezer_playlists) as num_playlist
FROM Popular_Spotify_Songs
GROUP BY Popular_Spotify_Songs.track_name
ORDER BY num_playlist DESC;

-- Task: to find difference between most popular songs
-- Result: I got the difference in streams between each song.
-- Example: difference between first and second popular song are -141,351,184 (Blinding light 3703895074 -  Shape of you 3562543890 = -141351184  )

SELECT `artist(s)_name` ,track_name, streams,
LAG(streams) over(order by streams DESC) as comparasion,
streams - LAG(streams,1,Null) over(order by streams DESC) as diff
FROM Popular_Spotify_Songs;

-- TASK: show the difference in streams in percentage
-- RESULT: I got the difference in percentage
-- Example: (Blinding light 3703895074 -  Shape of you 3562543890/3703895074 = -3.82% ). I checked also by calculator. Got the same result.

SELECT `artist(s)_name` , track_name , streams,
LAG(STREAMS) over (order by streams DESC) as comparasion,
ROUND((Streams - LAG(STREAMS) over (order by streams DESC))/LAG(STREAMS) over (order by streams DESC)*100,2) as diff_perc
FROM Popular_Spotify_Songs;

-- TASK: Group songs by year released
-- RESULT: time-series shows how many songs were released. 2022 year - 402 songs

SELECT released_year, COUNT(*) as num_track
    FROM Popular_Spotify_Songs
GROUP BY released_year
ORDER BY num_track DESC;

SELECT released_year, num_track,
       LAG(num_track,1,0) over (order by released_year DESC) as comparison,
       num_track - LAG(num_track,1,0) over (order by released_year DESC) as diff
    FROM(SELECT Popular_Spotify_Songs.released_year, COUNT(*) AS num_track
FROM Popular_Spotify_Songs
GROUP BY released_year) as subquery;

-- TASK: Create a date from released year, released month, released day and see how many days song has been released.
--       Then calculate how much a song has been streamed per day
-- RESULT: Full_date was create, after that I subtracted days from current date, after that I divided streams on days and got the most streamed (mean) song per day.
--         Harry Styles 'As it was' released day 2022-03-31, 770 days. streams per day: 3263881.16 (rough estimation)
--         Limited result to top 5;

SELECT track_name, `artist(s)_name`,full_date,streams,DAYS,
       ROUND((streams/DAYS),2)as num_streams_per_day
    FROM (
SELECT track_name,`artist(s)_name`,full_date, streams, datediff(curdate(),full_date) as DAYS
    FROM (
SELECT track_name, `artist(s)_name`, streams, CAST(CONCAT(released_year,'-',released_month,'-',released_day)AS DATE) AS full_date
       FROM Popular_Spotify_Songs) as subquery) AS nam_days
ORDER BY num_streams_per_day DESC
LIMIT 5;


