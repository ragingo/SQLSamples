use AdventureWorks2012
go

select
	emp_list.dept_id,
	emp_list.dept_group_name,
	emp_list.dept_name,
	emp_list.emp_names
from
	(select
		hr_dept.DepartmentID as dept_id,
		hr_dept.GroupName as dept_group_name,
		hr_dept.Name as dept_name,
		(select
			p.LastName + '(' + cast(datediff(day, hr_emp.BirthDate, getdate()) / 365 as varchar(3)) + ')' + ','
		 from
			HumanResources.EmployeeDepartmentHistory hr_emp_dept
			inner join HumanResources.Employee hr_emp on
				hr_emp.BusinessEntityID = hr_emp_dept.BusinessEntityID
			inner join Person.Person p on
				p.BusinessEntityID = hr_emp.BusinessEntityID
		 where
			hr_emp_dept.DepartmentID = hr_dept.DepartmentID
		 for xml path('')
		) emp_names
	from
		HumanResources.Department hr_dept
	) as emp_list
