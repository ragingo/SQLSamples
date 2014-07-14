use [AdventureWorks2012]
go


select top 0
	hr_dept.DepartmentID,
	hr_dept.GroupName,
	hr_dept.Name,
	hr_emp.BusinessEntityID,
	concat(
		person.FirstName, ' ',
		iif(isnull(person.MiddleName, '')='', '', concat(person.MiddleName, ' ')),
		person.LastName
	) as PersonName,
	hr_emp.Gender,
	hr_emp.BirthDate
from
	HumanResources.Employee hr_emp
	inner join Person.Person person on
		person.BusinessEntityID = hr_emp.BusinessEntityID
	inner join
		HumanResources.EmployeeDepartmentHistory hr_history on
			hr_emp.BusinessEntityID = hr_history.BusinessEntityID
	inner join
		HumanResources.Department hr_dept on
			hr_history.DepartmentID = hr_dept.DepartmentID
order by
	hr_dept.DepartmentID,
	hr_emp.BusinessEntityID


select top 0
	*
from
	Production.Product p
order by
	p.ProductID

select top 0
	*
from
	Sales.SalesOrderHeader header
	inner join Sales.SalesOrderDetail detail on
		header.SalesOrderID = detail.SalesOrderID