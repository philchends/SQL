USE employees_mod;

# Join t_employees table and t_dept_emp table and generate a list of the number of employees, which is grouped by calendar_year and gender. 
SELECT 
    YEAR(de.from_date) AS calendar_year,
    e.gender,
    COUNT(e.emp_no) AS number_of_employees
FROM
    t_employees e
        JOIN
    t_dept_emp de ON e.emp_no = de.emp_no
WHERE
    YEAR(de.from_date) > 1989
GROUP BY YEAR(de.from_date) , e.gender;



# Compare the number of male managers to the number of female managers from different departments for each year, starting from 1990.

SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    # When calendar_year is between from_date and to_date, the manager is active(1), otherwise inactive(0). 
    # When we import the date into Tableau, Tableau can automatically calcuate the number of active manager by year.
    CASE
        WHEN
            YEAR(dm.to_date) >= e.calendar_year
                AND YEAR(dm.from_date) <= e.calendar_year
        THEN
            1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
        JOIN
    t_employees ee ON ee.emp_no = dm.emp_no

ORDER BY dm.emp_no ASC, calendar_year ASC;
    
    
# Compare the average salary of female versus male employees in the entire company until year 2002, and add a filter allowing you to see that per each department.
# VIsualize the data in Tableau using an area chart. 
USE employees_mod;
SELECT 
    e.gender,
    d.dept_name,
    ROUND(AVG(s.salary), 2) AS salary,
    YEAR(s.from_date) AS calendar_year
FROM
    t_salaries s
        JOIN
    t_employees e ON e.emp_no = s.emp_no
        JOIN
    t_dept_emp de ON s.emp_no = de.emp_no
        JOIN
    t_departments d ON de.dept_no = d.dept_no
GROUP BY d.dept_no , e.gender , calendar_year
HAVING calendar_year <= 2002
ORDER BY d.dept_no;

# Create an SQL stored procedure to obtain the average male and female salary per department within a certain salary range.
# Visualize the obtained result-set in Tableau as a double bar chart. 

DROP PROCEDURE IF EXISTS filter_avg_salary;
DELIMITER $$
CREATE PROCEDURE filter_avg_salary(IN p_s_range1 FLOAT, IN p_s_range2 FLOAT) 
BEGIN
SELECT 
	e.gender,
	d.dept_name,
	AVG(s.salary) AS avg_salary
FROM
	t_salaries s
	JOIN
	t_employees e ON s.emp_no = e.emp_no
	JOIN
	t_dept_emp de ON e.emp_no = de.emp_no
	JOIN
	t_departments d ON de.dept_no = d.dept_no 
WHERE s.salary BETWEEN p_s_range1 AND p_s_range2     
GROUP BY d.dept_no, e.gender
ORDER BY d.dept_no;
END $$
DELIMITER ;

CALL filter_avg_salary( 50000, 90000);
