
-- INSERT INTO edges
WITH dedpued AS(
    SELECT *, row_number() OVER (PARTITION BY player_id, game_id) AS row_num
    FROM game_details
    ),

    filtered AS (
        SELECT * FROM dedpued
        WHERE row_num = 1
    ),

    aggregated AS (
        SELECT
           f1.player_id AS subject_player_id,
           f2.player_id AS object_player_id,
          CASE
              WHEN f1.team_abbreviation = f2.team_abbreviation THEN 'shares_team'::edge_type
              ELSE 'plays_against'::edge_type
              END AS edge_type,
          COUNT(*)    AS num_games,
          MAX(f1.player_name) AS subject_player_name,
          MAX(f2.player_name) AS object_player_name,
          SUM(f1.pts) AS subject_points,
          SUM(f2.pts) AS objects_points

       FROM filtered f1
                JOIN filtered f2 ON f1.game_id = f2.game_id
           AND f1.player_name <> f2.player_name
       WHERE f1.player_id > f2.player_id
       GROUP BY f1.player_id,
                f2.player_id,
                CASE
                    WHEN f1.team_abbreviation = f2.team_abbreviation THEN 'shares_team'::edge_type
                    ELSE 'plays_against'::edge_type
                    END)

    SELECT
        subject_player_id AS subject_identifier,
        'player'::vertex_type AS subject_type,
        object_player_id AS object_identifier,
        'player'::vertex_type AS object_Type,
        edge_type AS edge_type,
        json_build_object(
            'num_games', num_games,
            'subject_points', subject_points,
            'object_points', objects_points
        )
    FROM aggregated





SELECT
    player_id AS subject_identifier,
    'player'::vertex_type AS subject_Type,
    game_id AS object_identifier,
    'game'::vertex_type AS object_Type,
    'plays_in'::edge_type AS edge_type,
    json_build_object(
        'start_position', start_position,
        'pts', pts,
        'team_id', team_id,
        'team_abbreviation', team_abbreviation
    ) AS properties
FROM dedpued
WHERE row_num = 1;


--
-- SELECT
--     v.properties->>'player_name',
--     MAX(e.properties->>'pts')
-- FROM vertices v
-- JOIN edges e ON e.subject_identifier = v.identifier
-- AND e.subject_type = v.type
-- GROUP BY 1
-- ORDER BY 2 DESC