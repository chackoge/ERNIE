SET SEARCH_PATH = wenxi;

CREATE UNLOGGED TABLE IF NOT EXISTS test_one_million_pairs
(
  cited_1 BIGINT,
  cited_2 BIGINT,
  CONSTRAINT test_one_million_pairs_pk PRIMARY KEY (cited_1, cited_2) USING INDEX TABLESPACE index_tbs
);

COPY test_one_million_pairs FROM '/erniedev_data2/jenkins_home/workspace/ERNIE-Neo4j-sb-plus/build/test_1000000.csv' CSV HEADER;

-- Query for calculate frequency
/*  SELECT tomp.cited_1, tomp.cited_2, COUNT(1)
  FROM test_one_million_pairs tomp
  JOIN scopus_references sr1
       ON sr1.ref_sgr = tomp.cited_1
  JOIN scopus_references sr2
       ON sr2.scp = sr1.scp AND sr2.ref_sgr = tomp.cited_2;
    */

CREATE UNLOGGED TABLE IF NOT EXISTS test_one_million_pairs_frequency
(
  cited_1 BIGINT,
  cited_2 BIGINT,
  frequency INT
);

DO
$do$
  DECLARE
    i INT;
  BEGIN
    FOR i IN 1..:N
    LOOP
      INSERT INTO test_one_million_pairs_frequency (cited_1, cited_2, frequency)
      SELECT cited_1, cited_2, COUNT(1) as frequency
        FROM test_one_million_pairs tomp
        JOIN public.scopus_references sr1
             ON sr1.ref_sgr = tomp.cited_1
        JOIN public.scopus_references sr2
             ON sr2.scp = sr1.scp AND sr2.ref_sgr = tomp.cited_2
       GROUP BY tomp.cited_1, tomp.cited_2
       ORDER BY cited_1, cited_2
       LIMIT :batch_size OFFSET (i - 1)*:batch_size;
    END LOOP;
  END
$do$;

