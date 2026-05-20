CREATE DATABASE healthcare_analysis;
USE healthcare_analysis;

CREATE TABLE patients (
    PatientID INT PRIMARY KEY,
    PatientName VARCHAR(100),
    Gender VARCHAR(10),
    Age INT,
    RegistrationDate DATE
);

CREATE TABLE appointments (
    AppointmentID INT PRIMARY KEY,
    PatientID INT,
    AppointmentDate DATE,
    Department VARCHAR(100),
    DoctorID INT,
    Status VARCHAR(20),
    FOREIGN KEY (PatientID) REFERENCES patients(PatientID)
);
#total patients based on gender
SELECT Gender, COUNT(*) 
FROM patients
GROUP BY Gender;

#Query 1 — Total Patients
SELECT COUNT(DISTINCT PatientID) total_patients
FROM patients;

#Query 2 - Gender-wise distribution of patients
SELECT Gender, COUNT(*) AS total_patients
FROM patients
GROUP BY Gender;

#query 3- Average age of patients by gender
SELECT Gender, AVG(Age) AS average_age
FROM patients
GROUP BY Gender;

#query 4- Monthly trend of appointments (year/month)
SELECT 
    EXTRACT(YEAR FROM AppointmentDate) AS year,
    EXTRACT(MONTH FROM AppointmentDate) AS month,
    COUNT(*) AS total_appointments
FROM appointments
GROUP BY year, month
ORDER BY year, month;

#query 5- Top 3 departments with highest missed appointments
SELECT Department, COUNT(*) AS missed_appointments
FROM appointments
WHERE Status = 'Missed'
GROUP BY Department
ORDER BY missed_appointments DESC
LIMIT 3;

#query 6 - Distribution of appointment status
SELECT Status, COUNT(*) AS total
FROM appointments
GROUP BY Status;

#query 7 - Repeat patient rate (patients with more than one appointment)
SELECT PatientID, COUNT(*) AS appointment_count
FROM appointments
GROUP BY PatientID
HAVING COUNT(*) > 1;

#query 8 - Average appointments per doctor per departmen
SELECT DoctorID, Department, AVG(appointment_count) AS avg_appointments
FROM (
    SELECT DoctorID, Department, COUNT(*) AS appointment_count
    FROM appointments
    GROUP BY DoctorID, Department
) sub
GROUP BY DoctorID, Department;

#query-9 - Patients with more than 2 missed appointments
SELECT PatientID, COUNT(*) AS missed_count
FROM appointments
WHERE Status = 'Missed'
GROUP BY PatientID
HAVING COUNT(*) > 2;

#query- 10 - Patients registered in 2020 + average appointment gap
WITH patient_appointments AS (
    SELECT 
        p.PatientID,
        a.AppointmentDate,
        LAG(a.AppointmentDate) OVER (PARTITION BY p.PatientID ORDER BY a.AppointmentDate) AS prev_date
    FROM patients p
    JOIN appointments a
    ON p.PatientID = a.PatientID
    WHERE EXTRACT(YEAR FROM p.RegistrationDate) = 2020
)

SELECT 
    PatientID,
    AVG(AppointmentDate - prev_date) AS avg_gap_days
FROM patient_appointments
WHERE prev_date IS NOT NULL
GROUP BY PatientID;

#query-11 Rank appointments for each patient
SELECT 
    PatientID,
    AppointmentDate,
    RANK() OVER (PARTITION BY PatientID ORDER BY AppointmentDate) AS visit_rank
FROM appointments;

#query- 12-Department-wise monthly no-show rate
SELECT 
    Department,
    EXTRACT(YEAR FROM AppointmentDate) AS year,
    EXTRACT(MONTH FROM AppointmentDate) AS month,
    SUM(CASE WHEN Status = 'Missed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS no_show_rate
FROM appointments
GROUP BY Department, year, month
ORDER BY year, month;


