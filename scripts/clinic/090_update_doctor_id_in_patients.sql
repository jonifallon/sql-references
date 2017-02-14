DROP SEQUENCE IF EXISTS doctor_join_id_seq;
DROP SEQUENCE IF EXISTS patient_join_id_seq;
DROP TABLE IF EXISTS doctor_ids;
DROP TABLE IF EXISTS patient_ids;
CREATE TEMPORARY SEQUENCE doctor_join_id_seq MINVALUE 0;
CREATE TEMPORARY SEQUENCE patient_join_id_seq MINVALUE 0;
CREATE TEMPORARY TABLE doctor_ids AS (
  SELECT id,
    NEXTVAL('doctor_join_id_seq') AS join_id
  FROM doctors
  WHERE specialty = 'General practice'
);
CREATE TEMPORARY TABLE patient_ids AS (
  SELECT id,
    NEXTVAL('patient_join_id_seq') AS join_id
  FROM patients
  WHERE DATE_PART('year', AGE(born_on)) BETWEEN
    16 AND 64
);
UPDATE patients AS p
SET doctor_id = ids.doctor_id
FROM (SELECT p.id AS patient_id, d.id AS doctor_id
      FROM doctor_ids d
      INNER JOIN patient_ids p
        ON d.join_id = (p.join_id % CURRVAL('doctor_join_id_seq'))) AS ids
WHERE p.id = ids.patient_id;
