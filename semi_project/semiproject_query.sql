SELECT * FROM member_info;

SELECT * FROM managers;

SELECT * FROM board;

SELECT * FROM category
ORDER BY board_number;

SELECT * FROM vote;

SELECT m.member_number, m.member_name, c.board_number, c.category_number
FROM category c JOIN vote v ON c.board_number = v.board_number
                JOIN member_info m ON v.member_number = m.member_number
ORDER BY member_number;

SELECT category_number, vote_count;

--CREATE OR REPLACE VIEW vote_percent
--AS(
--    SELECT category_number, vote, total_vote
--    ,RPAD(' ', (vote)+1, '*') ||' '|| TRUNC(vote/total_vote * 10) vote_graph  
--    ,ROUND(vote/total_vote * 100,2) || '%' vote_percent
--    FROM(
--        SELECT category_number 
--            , COUNT(category_number) vote
--            , (SELECT COUNT(*) FROM vote p WHERE board_number = (SELECT COUNT(*)
--                                                             FROM vote c
--                                                             WHERE p.board_number = c.board_number))  total_vote
--        FROM vote
--        GROUP BY category_number
--        ORDER BY category_number
--        )
--    );

-- 투표 그래프 뷰 테이블 생성
CREATE OR REPLACE VIEW vote_percent
AS
(
    SELECT board_number
        , category_number
        , vote
        , RPAD(' ', ROUND(vote/total_vote*10) + 1, '▒') || '  ' || ROUND(vote/total_vote * 100, 2) || '%' vote_graph
        , ROUND(vote/total_vote * 100, 2) || '%'vote_percent 
    FROM(
        SELECT board_number 
            , category_number 
            , COUNT(board_number) vote
            , (SELECT COUNT(*) FROM vote p WHERE board_number = (SELECT COUNT(*)
                                                             FROM vote c
                                                             WHERE p.board_number = c.board_number))  total_vote

        FROM vote
        GROUP BY category_number, board_number
        ORDER BY board_number
        )
)ORDER BY board_number;

SELECT * FROM board;
SELECT * FROM vote_percent;
SELECT * FROM managers;

--필요한거 
--board : board_title, start_date, end_date -> status(상태) 항목수  
--managers : managers_name
--vote_percent


-- 상세 조회 뷰 테이블 생성
CREATE OR REPLACE VIEW 상세조회
AS
(
SELECT board_number, board_title, start_date, end_date
, DECODE(status, 0, '설문조사 완료', 1 , '진행중', 2, '설문 예정') "설문 상태"
, managers_name, category_number, vote_graph
FROM(
    SELECT DISTINCT b.board_number, b.board_title, b.start_date, b.end_date
    ,CASE
        WHEN ROUND(SYSDATE - b.start_date) >= 0 AND ROUND(b.end_date - SYSDATE) <= 0 THEN 0
        WHEN ROUND(SYSDATE - b.start_date) >= 0 AND ROUND(b.end_date - SYSDATE) >= 0 THEN 1
        ELSE 2
    END status
    ,m.managers_name
    ,v.vote_graph, v.category_number, v.vote_percent
    FROM board b JOIN managers m ON b.managers_number = m.managers_number
                 JOIN vote_percent v ON v.board_number = b.board_number
    ORDER BY b.board_number, v.category_number
    )
);
