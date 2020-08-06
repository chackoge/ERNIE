-- Ecology DDL for the year 1987

SET search_path = theta_plus_ecology;

SELECT count(*)
FROM public.scopus_asjc_pubs
WHERE class_code ='1105'; -- Ecology, Evolution, Behavior and Systematics

SELECT count(*)
FROM public.scopus_asjc_pubs
WHERE class_code ='2302'; -- Ecological Modelling

SELECT count(*)
FROM public.scopus_asjc_pubs
WHERE class_code ='2303'; -- Ecology

-- Get all ecology articles published in the year 1987
DROP TABLE IF EXISTS theta_plus_ecology.eco1987;

CREATE TABLE theta_plus_ecology.eco1987
TABLESPACE theta_plus_tbs AS
SELECT sp.scp 
FROM public.scopus_publications sp
INNER JOIN public.scopus_publication_groups spg
    ON sp.scp=spg.sgr
    AND spg.pub_year=1987
    AND sp.citation_type='ar'
    AND sp.citation_language='English'
    AND sp.pub_type='core'
INNER JOIN public.scopus_classes sc
    ON sp.scp=sc.scp
    AND sc.class_code IN ('1105', '2302', '2303');
    
CREATE INDEX eco1987_idx
    ON theta_plus_ecology.eco1987(scp)
TABLESPACE index_tbs;

-- Get all the cited references of the ecology articles published in 1987
DROP TABLE IF EXISTS theta_plus_ecology.eco1987_cited;

CREATE TABLE theta_plus_ecology.eco1987_cited
TABLESPACE theta_plus_tbs AS
SELECT eco.scp AS citing,sr.ref_sgr AS cited
FROM theta_plus_ecology.eco1987 eco
INNER JOIN public.scopus_references sr 
    ON eco.scp = sr.scp;

CREATE INDEX eco1987_cited_idx
    ON theta_plus_ecology.eco1987_cited(citing,cited)
TABLESPACE index_tbs;

-- Get all the citing references of the ecology articles published in 1987
DROP TABLE IF EXISTS theta_plus_ecology.eco1987_citing;

CREATE TABLE theta_plus_ecology.eco1987_citing 
TABLESPACE theta_plus_tbs AS
SELECT sr.scp AS citing,eco.scp AS cited 
FROM theta_plus_ecology.eco1987 eco
INNER JOIN public.scopus_references sr 
    ON eco.scp=sr.ref_sgr;

CREATE INDEX eco1987_citing_idx 
ON theta_plus_ecology.eco1987_citing(citing,cited)
TABLESPACE index_tbs;

-- Create table from the union of cited and citing references
DROP TABLE IF EXISTS theta_plus_ecology.eco1987_citing_cited;

CREATE TABLE theta_plus_ecology.eco1987_citing_cited
TABLESPACE theta_plus_tbs AS
SELECT DISTINCT citing,cited from theta_plus_ecology.eco1987_cited 
UNION
SELECT DISTINCT citing,cited from theta_plus_ecology.eco1987_citing;


-- clean up Scopus data
DELETE FROM theta_plus_ecology.eco1987_citing_cited
WHERE citing=cited;

--remove all non-core publications by joining against
-- scopus publications and requiring type = core
-- and language = English
DROP TABLE IF EXISTS XX_eco1987;
ALTER TABLE theta_plus_ecology.eco1987_citing_cited
RENAME TO XX_eco1987;

CREATE TABLE theta_plus_ecology.eco1987_citing_cited AS
WITH cte AS(SELECT citing,cited FROM XX_eco1987
INNER JOIN public.scopus_publications sp
ON XX_eco1987.citing=sp.scp
AND sp.citation_language='English'
AND sp.pub_type='core')
SELECT citing,cited FROM cte
INNER JOIN public.scopus_publications sp2
ON cte.cited=sp2.scp
AND sp2.citation_language='English'
AND sp2.pub_type='core';
DROP TABLE XX_eco1987;

-- Get all nodes in the 1987 dataset
DROP TABLE IF EXISTS theta_plus_ecology.eco1987_nodes;

CREATE TABLE theta_plus_ecology.eco1987_nodes
TABLESPACE theta_plus_tbs AS
SELECT DISTINCT citing AS scp
FROM theta_plus_ecology.eco1987_citing_cited
UNION
SELECT DISTINCT cited
FROM theta_plus_ecology.eco1987_citing_cited;

CREATE INDEX eco1987_nodes_idx 
    ON theta_plus_ecology.eco1987_nodes(scp);

