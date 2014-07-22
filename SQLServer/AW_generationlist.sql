use AdventureWorks2012
go

select
	dept_list.GroupName,
	count(*) as Count,
	dept_list.Age/10*10 as Generation
from
	(select
		hr_dept.DepartmentID,
		hr_dept.GroupName,
		hr_dept.Name,
		p.FirstName,
		datediff(day, hr_emp.BirthDate, getdate()) / 365 as Age
	from
		HumanResources.Department hr_dept
		inner join HumanResources.EmployeeDepartmentHistory hr_emp_dept_history on
			hr_emp_dept_history.DepartmentID = hr_dept.DepartmentID
		inner join HumanResources.Employee hr_emp on
			hr_emp.BusinessEntityID = hr_emp_dept_history.BusinessEntityID
		inner join Person.Person p on
			p.BusinessEntityID = hr_emp.BusinessEntityID
	) as dept_list
group by
	dept_list.GroupName,
	dept_list.Age/10*10
order by
	GroupName,
	Count desc,
	Generation
