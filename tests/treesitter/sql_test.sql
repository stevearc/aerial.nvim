CREATE DATABASE db1;
CREATE SCHEMA sch1;
CREATE ROLE role1;
CREATE EXTENSION ext1;

CREATE TABLE db1.sch1.t1 (
  id integer,
  col1 integer,
  col2 integer
);

CREATE VIEW sch1.v1 AS
  SELECT id, col1 FROM sch1.t1;

CREATE MATERIALIZED VIEW sch1.mv1 AS
  SELECT id, col2 FROM sch1.t1;

CREATE TYPE sch1.t_enum AS ENUM ('a', 'b');

CREATE SEQUENCE sch1.seq1;

CREATE FUNCTION sch1.fn_add(a integer, b integer)
RETURNS integer
LANGUAGE sql
AS $$
  SELECT a + b;
$$;

CREATE FUNCTION sch1.trg_fn()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN NEW;
END;
$$;

CREATE TRIGGER sch1.trg1
BEFORE INSERT ON sch1.t1
FOR EACH ROW
EXECUTE FUNCTION sch1.trg_fn();

CREATE INDEX idx1 ON sch1.t1 ((col1 + col2));

CREATE POLICY pol1 ON sch1.t1
  FOR SELECT
  TO PUBLIC
  USING (col1 > 0);
