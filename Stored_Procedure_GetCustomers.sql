CREATE Procedure getCustomers
	@FirstName NVARCHAR(100) = NULL,
	@LastName NVARCHAR(100) = NULL,
	@StartDate NVARCHAR(10) = NULL,
	@EndDate NVARCHAR(10) = NULL,
	@NumOrders INT = NULL,
	@PageNumber INT,
	@PageSize INT = 50

AS

BEGIN

	DECLARE @StartRow INT
	DECLARE @EndRow INT

	SET @StartRow = ((@PageNumber - 1) * @PageSize) + 1;
	SET @EndRow = (@PageNumber * @PageSize);


	SELECT
		Cus.CustomerID as CustomerID,
		Cus.FirstName as FirstName,
		Cus.LastName as LastName,
		Cus.CreatedDate as CreatedDate,
		sales.SumOrders,
		sales.NumOrders
	FROM 
		(
			SELECT *,
			ROW_NUMBER() OVER (ORDER BY CustomerID ASC) AS RowNumber
			FROM Customer
		) AS Cus	
		LEFT JOIN (
			SELECT CustomerID, SUM(Orders.OrderTotal) AS SumOrders, COUNT(CustomerID) AS NumOrders
			FROM Orders
			WHERE ((OrderDate BETWEEN CONVERT(VARCHAR, @StartDate, 101) AND CONVERT(VARCHAR, @EndDate, 101)) OR (@StartDate IS NULL AND @EndDate IS NULL))
			GROUP BY CustomerID) Sales
		ON Cus.CustomerID = Sales.CustomerID
	WHERE
		sumOrders IS NOT NULL AND
		(FirstName LIKE '%' +@FirstName + '%' OR @FirstName IS NULL) AND
		(LastName LIKE '%' + @LastName + '%' OR @LastName IS NULL) AND
		(NumOrders = @NumOrders OR @NumOrders IS NULL) AND
		Cus.RowNumber Between @StartRow AND @EndRow


END

EXEC getCustomers
	@PageNumber = 1,
	@StartDate = '01/01/2022',
	@EndDate = '12/31/2022',
	@FirstName = 'Aiden',
	@LastName = 'Smith',
	@NumOrders = 1
