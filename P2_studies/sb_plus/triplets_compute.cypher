UNWIND $input_data AS row
MATCH (a:Publication {node_id: row.cited_1})<--(p)-->(b:Publication {node_id: row.cited_2}), (p)-->(c:Publication)
RETURN a.node_id AS scp1, b.node_id AS scp2, c.node_id AS scp3, COUNT(p) AS frequency;
