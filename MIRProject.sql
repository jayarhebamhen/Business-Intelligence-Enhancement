/* Shift – time variable (Order date – SalesOrderHeader). A snap shot in time.
• Sales
– Standard Cost (Production.product)
– Revenue (Derived FROM Unitprice * Orderquantity or use line total in SalesOrderDetail)
– Profit (Derived from Revenue – Total Product cost(Order Quantity * Standard cost)
– Number of transactions (Count of unique salesorderID – Sales order header has unique salesorderid)
– Item sold (Total Order quantity - SalesOrderDetail)
– Product (Name, Category, Subcategory)
– Location (Sales territory)
• Sales Channel – (SalesOrderheader)
– Digital – Online sales
– Reseller – Store sales*/

select * from [Sales].[SalesOrderDetail]
select * from [Sales].[SalesOrderHeader]
select * from [Production].[Product]
select * from [Production].[ProductCategory]
select * from [Production].[ProductSubcategory]
select * from [Sales].[SalesTerritory]
SELECT * FROM [Production].[ProductModel]



/*Number of Rows 121317*/


Select 
A.[SalesOrderID],
A.[OrderQty],
A.[ProductID],
A.[UnitPrice],
A.[LineTotal] AS Revenue,
B.[OrderDate],
B.Status,
B.[OnlineOrderFlag],
CASE 
	WHEN B.[OnlineOrderFlag] = 1 THEN 'Online' ELSE 'Reseller'
	END AS SalesChannel,
C.Name AS ProductName,
C.StandardCost,
C.StandardCost * A.OrderQty AS TotalProductCost,
A.LineTotal  - (C.StandardCost * A.OrderQty) AS Profit,
D.Name AS ProductSubCatName,
E.Name AS ProductCatName,
F.Name AS Region,
G.[Name] AS ProductModelName
FROM 
[Sales].[SalesOrderDetail] AS A
LEFT JOIN [Sales].[SalesOrderHeader] AS B 
ON A.[SalesOrderID] = B.[SalesOrderID]
LEFT JOIN [Production].[Product] AS C
ON A.[ProductID] = C.ProductID
LEFT JOIN [Production].[ProductSubcategory] AS D 
ON C.[ProductSubcategoryID] = D.ProductSubcategoryID
LEFT JOIN [Production].[ProductCategory] AS E
ON D.ProductCategoryID = E.ProductCategoryID
LEFT JOIN [Sales].[SalesTerritory] AS F
ON B.TerritoryID = F.[TerritoryID]
LEFT JOIN [Production].[ProductModel] AS G
ON C.ProductModelID = G.ProductModelID
where a.ProductID = 708;
/*------------------------------------------------*/

SELECT C.[Name] AS ProductModelName,
FORMAT (D.[OrderDate],'MM-yyyy') AS Month_Year,
SUM ([OrderQty]) AS Vol_Sold,
AVG ([UnitPrice]) AS Avg_Price
FROM [Sales].[SalesOrderDetail] AS A
LEFT JOIN [Production].[Product] AS B
ON A.[ProductID]=B.[ProductID]
LEFT JOIN [Production].[ProductModel] AS C
ON B.[ProductModelID]=C.[ProductModelID]
LEFT JOIN [Sales].[SalesOrderHeader] AS D
ON A.[SalesOrderID]=D.[SalesOrderID]
WHERE OnlineOrderFlag=1
GROUP BY C.Name,
FORMAT (D.OrderDate, 'MM-yyyy')
ORDER BY ProductModelName,
FORMAT (D.OrderDate, 'MM-yyyy');



SELECT A.[Name] AS Item,
SUM (C.[OrderQty]) AS Vol_Sold,
AVG (C.[UnitPrice]) AS Avg_Price,
DATEDIFF(mm, min(D.[OrderDate]), max (D.[OrderDate])) AS #Months,
AVG (C.[OrderQty]*C.[UnitPrice]) AS Avg_Revenue,
AVG (C.[OrderQty]*C.[UnitPrice])/DATEDIFF(mm, min(D.[OrderDate]), max (D.[OrderDate])) AS Monthly_Revenue
FROM [Production].[ProductModel] AS A
LEFT JOIN [Production].[Product] AS B ON A.ProductModelID=B.ProductModelID
LEFT JOIN [Sales].[SalesOrderDetail] AS C ON B.ProductID=C.ProductID
LEFT JOIN [Sales].[SalesOrderHeader] AS D ON C.SalesOrderID=D.SalesOrderID
WHERE OnlineOrderFlag=1
GROUP BY A.[Name]

/*MONTHLY AVERAGE SOLD AND MONTHLY AVERAGE PRICE*/


SELECT ProductModelName,
AVG (Vol_Sold) AS Vol_Sold,
AVG (Avg_Price) AS Avg_Price
FROM
(SELECT C.[Name] AS ProductModelName,
FORMAT (D.[OrderDate],'MM-yyyy') AS Month_Year,
SUM ([OrderQty]) AS Vol_Sold,
AVG ([UnitPrice]) AS Avg_Price
FROM [Sales].[SalesOrderDetail] AS A
LEFT JOIN [Production].[Product] AS B
ON A.[ProductID]=B.[ProductID]
LEFT JOIN [Production].[ProductModel] AS C
ON B.[ProductModelID]=C.[ProductModelID]
LEFT JOIN [Sales].[SalesOrderHeader] AS D
ON A.[SalesOrderID]=D.[SalesOrderID]
WHERE OnlineOrderFlag=1
GROUP BY C.Name,
FORMAT (D.OrderDate, 'MM-yyyy') ) AS A
GROUP BY ProductModelName;


SELECT 
Item,
AVG (CostofGoods) AS CostofGoods,
AVG (Vol_Sold) AS Vol_Sold,
AVG (Avg_Price) AS Avg_Price

FROM
(SELECT C.[Name] AS Item,
FORMAT (D.[OrderDate],'MM-yyyy') AS Order_Month,
AVG (B.[StandardCost]) AS CostofGoods,
SUM (A.[OrderQty]) AS Vol_Sold,
AVG (A.[UnitPrice]) AS Avg_Price
FROM [Sales].[SalesOrderDetail] AS A
LEFT JOIN [Production].[Product] AS B
ON A.[ProductID]=B.[ProductID]
LEFT JOIN [Production].[ProductModel] AS C
ON B.[ProductModelID]=C.[ProductModelID]
LEFT JOIN [Sales].[SalesOrderHeader] AS D
ON A.[SalesOrderID]=D.[SalesOrderID]
WHERE OnlineOrderFlag=1
GROUP BY C.Name,
FORMAT (D.OrderDate, 'MM-yyyy') ) AS A
GROUP BY Item;


/*MIN, MAX, AVG PRICE*/

SELECT
    ps.Name AS 'Product Subcategory',
    MIN(p.ListPrice) AS 'Minimum Price',
    MAX(p.ListPrice) AS 'Maximum Price'
FROM Production.Product p
JOIN Production.ProductSubcategory ps
ON p.ProductSubcategoryID = ps.ProductSubcategoryID
GROUP BY ps.Name
ORDER BY ps.Name;

SELECT
    pc.Name AS 'Product Category',
    psc.Name AS 'Product Subcategory',
    YEAR(p.SellStartDate) AS 'Year',
    MIN(p.ListPrice) AS 'Minimum Price',
    AVG(p.ListPrice) AS 'Average Price',
    MAX(p.ListPrice) AS 'Maximum Price'
FROM Production.Product p
JOIN Production.ProductSubcategory psc
ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc
ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name, psc.Name, YEAR(p.SellStartDate)
ORDER BY pc.Name, psc.Name, YEAR(p.SellStartDate);

SELECT
    pc.Name AS 'Product Category',
    psc.Name AS 'Product Subcategory',
    YEAR(h.OrderDate) AS 'Year',
    h.SalesOrderID AS 'Sales Order ID',
    MIN(d.UnitPrice) AS 'Minimum Price',
    AVG(d.UnitPrice) AS 'Average Price',
    MAX(d.UnitPrice) AS 'Maximum Price'
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h
ON d.SalesOrderID = h.SalesOrderID
JOIN Production.Product p
ON d.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc
ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc
ON psc.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Bikes'
GROUP BY pc.Name, psc.Name, YEAR(h.OrderDate), h.SalesOrderID
ORDER BY pc.Name, psc.Name, YEAR(h.OrderDate), h.SalesOrderID;

SELECT
    pc.Name AS 'Product Category',
    psc.Name AS 'Product Subcategory',
    YEAR(h.OrderDate) AS 'Year',
    h.SalesOrderID AS 'Sales Order ID',
    d.UnitPrice AS 'Unit Price',
    MIN(d.UnitPrice) OVER (PARTITION BY pc.Name, psc.Name, YEAR(h.OrderDate)) AS 'Minimum Price',
    AVG(d.UnitPrice) OVER (PARTITION BY pc.Name, psc.Name, YEAR(h.OrderDate)) AS 'Average Price',
    MAX(d.UnitPrice) OVER (PARTITION BY pc.Name, psc.Name, YEAR(h.OrderDate)) AS 'Maximum Price'
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h
ON d.SalesOrderID = h.SalesOrderID
JOIN Production.Product p
ON d.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc
ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc
ON psc.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Bikes'
ORDER BY pc.Name, psc.Name, YEAR(h.OrderDate), h.SalesOrderID;




SELECT A.[SalesOrderID], 
MIN(A.[UnitPrice]) AS MinimumPrice,
AVG(A.[UnitPrice]) AS AveragePrice,
MAX(A.[UnitPrice]) AS MaximumPrice
FROM [Sales].[SalesOrderDetail] AS A
WHERE A.[SalesOrderID] = '43659'
GROUP BY A.[SalesOrderID]

/*FORECAST*/

Select * from [Sales].[SalesTerritory]
--Forecast2--
SELECT 
DATEPART(QUARTER, SSOH.[OrderDate]) AS [Quarter], 
(select convert (varchar, SSOH.[OrderDate], 23)) AS [Order Date], 
sst.Name AS [Country], 
CASE 
WHEN SSOH.[OnlineOrderFlag] = 1 THEN 'Online' ELSE 'Reseller' 
END AS 
[Sales Channel], 
SSOD.[LineTotal] AS [Revenue] 
FROM 
[Sales].[SalesOrderDetail] AS SSOD 
LEFT JOIN [Sales].[SalesOrderHeader] AS SSOH 
ON 
SSOD.[SalesOrderID] = SSOH.[SalesOrderID] 
LEFT JOIN [Sales].[SalesTerritory] AS SST 
ON 
SSOH.TerritoryID = SST.TerritoryID 
GROUP BY 
SSOH.[OrderDate], 
SST.Name, 
SST.[Group], 
SSOH.[OnlineOrderFlag], 
SSOD.[LineTotal] 
ORDER BY 
SSOH.[OrderDate]


Select 
A.CustomerID,
A.OnlineOrderFlag,
(select convert(varchar,orderDate,23)) AS OrderDate,
B.BirthDate,
B.EnglishEducation AS Education,
B.EnglishOccupation AS Occupation,
B.Gender,
B.MaritalStatus,
B.YearlyIncome,
B.TotalChildren,
B.HouseOwnerFlag,
B.NumberCarsOwned,
B.CommuteDistance,
C.EnglishCountryRegionName AS [Country],
A.Status

From
[Sales].[SalesOrderHeader] AS A
Left Join [AdventureWorksDW2017].[dbo].[DimCustomer] AS B
ON A.CustomerID = B.CustomerKey
Left Join [AdventureWorksDW2017].[dbo].[DimGeography] AS C
ON B.GeographyKey = C.GeographyKey
Where A.OnlineOrderFlag = 1

select * from [Sales].[vStoreWithDemographics]
---Scrap Cost---

Select * from [Production].[ScrapReason]
Select * from [Production].[WorkOrder]
Select * from [Production].[TransactionHistory]
Select * from [Production].[WorkOrderRouting]

SELECT 
    SR.Name AS ScrapReason,
    P.Name AS ProductName,
    SUM(WO.ScrappedQty) AS TotalScrappedQty,
    SUM(WO.ScrappedQty * P.StandardCost) AS TotalScrapCost,
    SUM(WOR.ActualCost) AS TotalActualCost,
    SUM(WO.ScrappedQty * WOR.ActualCost) AS TotalScrapActualCost,
    L.Name AS ProductionLocation,
    YEAR(WO.StartDate) AS Year,
    WO.StartDate,
    WO.EndDate,
    WO.DueDate,
    DATEDIFF(day, WO.DueDate, WO.EndDate) AS DelayDays
FROM Production.WorkOrder AS WO
JOIN Production.Product AS P
ON WO.ProductID = P.ProductID
JOIN Production.ScrapReason AS SR
ON WO.ScrapReasonID = SR.ScrapReasonID
JOIN Production.WorkOrderRouting AS WOR
ON WO.WorkOrderID = WOR.WorkOrderID
JOIN Production.Location AS L
ON WOR.LocationID = L.LocationID
GROUP BY SR.Name, P.Name, L.Name, YEAR(WO.StartDate), WO.StartDate, WO.EndDate, WO.DueDate;









Select * from [Sales].[Customer]
Select * from [Sales].[SalesOrderHeader]
Select * from [Sales].[SalesReason]
Select * from [Sales].[Store]
Select * from [Sales].[SalesOrderHeader]

SELECT 
YEAR (oh.OrderDate) AS [Year], 
SUM (od.LineTotal) AS [Total Revenue], 
SUM (p.StandardCost * od.OrderQty) AS [Total Cost], 
SUM (od.LineTotal) - SUM (p.StandardCost * od.OrderQty) AS [Total Profit] 
FROM 
Sales.SalesOrderDetail od 
INNER JOIN Sales.SalesOrderHeader oh ON od.SalesOrderID = oh.SalesOrderID 
INNER JOIN Production.Product p ON od.ProductID = p.ProductID 
GROUP BY YEAR (oh.OrderDate) 
ORDER BY YEAR (oh.OrderDate)

select * from [Production].[ProductCostHistory]
where productid = 708

Select * from [Sales].[SalesTerritory]
select * from sales.SalesOrderDetail

---Sales Table
drop table if exists #newcost
select
productid,standardcost,startdate,enddate,
isnull(enddate, getdate()) as enddate2
into #newcost
from [Production].[ProductCostHistory]

select
sh.salesorderid,salesorderdetailid, st.name Region, sh.CustomerID,
orderdate,orderqty,sd.productid,sd.unitprice,
(select standardcost from #newcost
where sd.productid = productid and orderdate between startdate and enddate2) * OrderQty AS TotalProductCost,
linetotal as revenue,
(linetotal - (select standardcost from #newcost
where sd.productid = productid and orderdate between startdate and enddate2) * OrderQty) profit,
pm.name productmodelname,psc.name productsubcategoryname,ppc.name ProdCatName,B.BirthDate,FLOOR(DATEDIFF(day, B.BirthDate, GETDATE()) / 365.25) AS Age,
B.EnglishEducation AS Education,
B.EnglishOccupation AS Occupation,
B.Gender,
B.MaritalStatus,
B.YearlyIncome,
B.TotalChildren,
B.HouseOwnerFlag,
B.NumberCarsOwned,
C.EnglishCountryRegionName AS [Country],


CASE 
	WHEN sh.[OnlineOrderFlag] = 1 THEN 'Online' ELSE 'Reseller'
	END AS SalesChannel,
CASE
	WHEN B.HouseOwnerFlag = 1 THEN 'Yes' ELSE 'No'
	END AS HouseOwner

from [Sales].[SalesOrderDetail] sd
inner join [Sales].[SalesOrderHeader] sh
on sd.SalesOrderID = sh.SalesOrderID
inner join [Sales].[SalesTerritory] st
on sh.TerritoryID = st.TerritoryID
inner join [Production].[Product] pp
on pp.ProductID = sd.ProductID
inner join [Production].[ProductModel] pm
on pp.ProductModelID = pm.ProductModelID
inner join [Production].[ProductSubcategory] psc
on pp.productsubcategoryid = psc.productsubcategoryid
inner join [Production].[ProductCategory] ppc
on psc.ProductCategoryID =ppc.ProductCategoryID
Left Join [AdventureWorksDW2017].[dbo].[DimCustomer] AS B
ON sh.CustomerID = B.CustomerKey
Left Join [AdventureWorksDW2017].[dbo].[DimGeography] AS C
ON B.GeographyKey = C.GeographyKey
where ppc.name = 'Bikes'
--------------Store Details
drop table if exists #newcost
select
productid,standardcost,startdate,enddate,
isnull(enddate, getdate()) as enddate2
into #newcost
from [Production].[ProductCostHistory]

select
sh.salesorderid,salesorderdetailid, st.name Region, sh.CustomerID,
orderdate,orderqty,sd.productid,
(select standardcost from #newcost
where sd.productid = productid and orderdate between startdate and enddate2) * OrderQty AS TotalProductCost,
linetotal as revenue,
(linetotal - (select standardcost from #newcost
where sd.productid = productid and orderdate between startdate and enddate2) * OrderQty) profit,
pm.name productmodelname,psc.name productsubcategoryname,ppc.name ProdCatName,B.BirthDate,
B.EnglishEducation AS Education,
B.EnglishOccupation AS Occupation,
B.Gender,
B.MaritalStatus,
B.YearlyIncome,
B.TotalChildren,
B.HouseOwnerFlag,
B.NumberCarsOwned,
C.EnglishCountryRegionName AS [Country],
SSO.[Description], SSO.[DiscountPct], SSO.[Type], SSO.[Category],SSO.[MinQty], SSO.[MaxQty],


CASE 
	WHEN sh.[OnlineOrderFlag] = 1 THEN 'Online' ELSE 'Store'
	END AS SalesChannel

from [Sales].[SalesOrderDetail] sd
inner join [Sales].[SalesOrderHeader] sh
on sd.SalesOrderID = sh.SalesOrderID
inner join [Sales].[SalesTerritory] st
on sh.TerritoryID = st.TerritoryID
inner join [Production].[Product] pp
on pp.ProductID = sd.ProductID
inner join [Production].[ProductModel] pm
on pp.ProductModelID = pm.ProductModelID
inner join [Production].[ProductSubcategory] psc
on pp.productsubcategoryid = psc.productsubcategoryid
inner join [Production].[ProductCategory] ppc
on psc.ProductCategoryID =ppc.ProductCategoryID
Left Join [Sales].[SpecialOfferProduct] AS SSOP
ON pp.ProductID = SSOP.ProductID
Left Join [Sales].[SpecialOffer] AS SSO
ON SSOP.SpecialOfferID = SSO.SpecialOfferID
Left Join [AdventureWorksDW2017].[dbo].[DimCustomer] AS B
ON sh.CustomerID = B.CustomerKey
Left Join [AdventureWorksDW2017].[dbo].[DimGeography] AS C
ON B.GeographyKey = C.GeographyKey

----Components----
drop table if exists #newcost
select
productid,standardcost,startdate,enddate,
isnull(enddate, getdate()) as enddate2
into #newcost
from [Production].[ProductCostHistory]

select
sh.salesorderid,salesorderdetailid, st.name Region, sh.CustomerID,
orderdate,orderqty,sd.productid,
(select standardcost from #newcost
where sd.productid = productid and orderdate between startdate and enddate2) * OrderQty AS TotalProductCost,
linetotal as revenue,
(linetotal - (select standardcost from #newcost
where sd.productid = productid and orderdate between startdate and enddate2) * OrderQty) profit,
pm.name productmodelname,psc.name productsubcategoryname,ppc.name ProdCatName,B.BirthDate,
B.EnglishEducation AS Education,
B.EnglishOccupation AS Occupation,
B.Gender,
B.MaritalStatus,
B.YearlyIncome,
B.TotalChildren,
B.HouseOwnerFlag,
B.NumberCarsOwned,
C.EnglishCountryRegionName AS [Country],


CASE 
	WHEN sh.[OnlineOrderFlag] = 1 THEN 'Online' ELSE 'Store'
	END AS SalesChannel

from [Sales].[SalesOrderDetail] sd
inner join [Sales].[SalesOrderHeader] sh
on sd.SalesOrderID = sh.SalesOrderID
inner join [Sales].[SalesTerritory] st
on sh.TerritoryID = st.TerritoryID
inner join [Production].[Product] pp
on pp.ProductID = sd.ProductID
inner join [Production].[ProductModel] pm
on pp.ProductModelID = pm.ProductModelID
inner join [Production].[ProductSubcategory] psc
on pp.productsubcategoryid = psc.productsubcategoryid
inner join [Production].[ProductCategory] ppc
on psc.ProductCategoryID =ppc.ProductCategoryID
Left Join [AdventureWorksDW2017].[dbo].[DimCustomer] AS B
ON sh.CustomerID = B.CustomerKey
Left Join [AdventureWorksDW2017].[dbo].[DimGeography] AS C
ON B.GeographyKey = C.GeographyKey
where ppc.name = 'Components'

SELECT 
    SpecialOfferID,
    Description,
    DiscountPct,
    Type,
    Category,
    StartDate,
    EndDate,
    MinQty,
    MaxQty
FROM 
    Sales.SpecialOffer;

	select * from sales.SalesOrderHeader

	SELECT 
    SOH.OrderDate,
    SOD.OrderQty,
    SOD.UnitPrice,
    SOD.UnitPriceDiscount,
    SO.Description AS DiscountDescription,
    (SOD.OrderQty * SOD.UnitPrice) AS RevenueBeforeDiscount,
    (SOD.OrderQty * SOD.UnitPrice * (1 - SOD.UnitPriceDiscount)) AS RevenueAfterDiscount
FROM 
    Sales.SalesOrderDetail SOD
JOIN 
    Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
JOIN 
    Sales.SpecialOfferProduct SOP ON SOD.ProductID = SOP.ProductID AND SOD.SpecialOfferID = SOP.SpecialOfferID
JOIN 
    Sales.SpecialOffer SO ON SOP.SpecialOfferID = SO.SpecialOfferID
WHERE 
    SOH.OnlineOrderFlag = 0 
ORDER BY 
    SOH.OrderDate;

	SELECT 
    SUM(((SOD.OrderQty * SOD.UnitPrice * (1 - SOD.UnitPriceDiscount)) - (SOD.OrderQty * P.StandardCost))) AS TotalProfit
FROM 
    Sales.SalesOrderDetail SOD
JOIN 
    Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
JOIN 
    Sales.SpecialOfferProduct SOP ON SOD.ProductID = SOP.ProductID AND SOD.SpecialOfferID = SOP.SpecialOfferID
JOIN 
    Sales.SpecialOffer SO ON SOP.SpecialOfferID = SO.SpecialOfferID
JOIN 
    Production.Product P ON SOD.ProductID = P.ProductID
WHERE 
    SOH.OnlineOrderFlag = 0;
	
	---Total Revenue, Cost, and Profit: 
	---This query calculates the total revenue (after discounts), cost of goods sold, and profit for all sales orders.---
	SELECT 
    SUM((SOD.OrderQty * SOD.UnitPrice * (1 - SOD.UnitPriceDiscount))) AS TotalRevenue,
    SUM((SOD.OrderQty * P.StandardCost)) AS TotalCost,
    SUM(((SOD.OrderQty * SOD.UnitPrice * (1 - SOD.UnitPriceDiscount)) - (SOD.OrderQty * P.StandardCost))) AS TotalProfit
FROM 
    Sales.SalesOrderDetail SOD
JOIN 
    Production.Product P ON SOD.ProductID = P.ProductID;

	SELECT 
    P.Name AS ProductName,
    SUM(((SOD.OrderQty * SOD.UnitPrice * (1 - SOD.UnitPriceDiscount)) - (SOD.OrderQty * P.StandardCost))) AS Profit
FROM 
    Sales.SalesOrderDetail SOD
JOIN 
    Production.Product P ON SOD.ProductID = P.ProductID
GROUP BY 
    P.Name;

	SELECT 
    SO.Description AS SpecialOfferDescription,
    SUM(((SOD.OrderQty * SOD.UnitPrice * (1 - SOD.UnitPriceDiscount)) - (SOD.OrderQty * P.StandardCost))) AS Profit
FROM 
    Sales.SalesOrderDetail SOD
JOIN 
    Sales.SpecialOfferProduct SOP ON SOD.ProductID = SOP.ProductID AND SOD.SpecialOfferID = SOP.SpecialOfferID
JOIN 
    Sales.SpecialOffer SO ON SOP.SpecialOfferID = SO.SpecialOfferID
JOIN 
    Production.Product P ON SOD.ProductID = P.ProductID
GROUP BY 
    SO.Description;

	SELECT 
    SO.Description AS SpecialOfferDescription,
    SUM(((SOD.OrderQty * SOD.UnitPrice * (1 - SOD.UnitPriceDiscount)) - (SOD.OrderQty * P.StandardCost))) AS Profit,
    SUM(SOD.OrderQty * SOD.UnitPrice * (1 - SOD.UnitPriceDiscount)) AS Revenue,
    SOD.UnitPrice,
    SOD.UnitPriceDiscount AS DiscountPercent
FROM 
    Sales.SalesOrderDetail SOD
JOIN 
    Sales.SpecialOfferProduct SOP ON SOD.ProductID = SOP.ProductID AND SOD.SpecialOfferID = SOP.SpecialOfferID
JOIN 
    Sales.SpecialOffer SO ON SOP.SpecialOfferID = SO.SpecialOfferID
JOIN 
    Production.Product P ON SOD.ProductID = P.ProductID
GROUP BY 
    SO.Description, 
    SOD.UnitPrice, 
    SOD.UnitPriceDiscount;

	SELECT 
    SO.Description AS SpecialOfferDescription,
    PM.Name AS ProductModelName,
    PS.Name AS ProductSubcategoryName,
    SUM(((SOD.OrderQty * SOD.UnitPrice * (1 - SOD.UnitPriceDiscount)) - (SOD.OrderQty * P.StandardCost))) AS Profit,
    SUM(SOD.OrderQty * SOD.UnitPrice * (1 - SOD.UnitPriceDiscount)) AS Revenue,
    SOD.UnitPrice,
    SOD.UnitPriceDiscount AS DiscountPercent
FROM 
    Sales.SalesOrderDetail SOD
JOIN 
    Sales.SpecialOfferProduct SOP ON SOD.ProductID = SOP.ProductID AND SOD.SpecialOfferID = SOP.SpecialOfferID
JOIN 
    Sales.SpecialOffer SO ON SOP.SpecialOfferID = SO.SpecialOfferID
JOIN 
    Production.Product P ON SOD.ProductID = P.ProductID
JOIN 
    Production.ProductModel PM ON P.ProductModelID = PM.ProductModelID
JOIN 
    Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
GROUP BY 
    SO.Description, 
    PM.Name, 
    PS.Name, 
    SOD.UnitPrice, 
    SOD.UnitPriceDiscount;


SELECT 
    p.Name AS ProductModelName,
    sod.ProductID,
    YEAR(sod.ModifiedDate) AS Year,
    sod.UnitPrice AS OriginalPrice,
    sod.UnitPriceDiscount * 100 AS DiscountPercent,
    sod.UnitPrice * (1 - sod.UnitPriceDiscount) AS DiscountedPrice,
    SUM(CASE WHEN sod.UnitPriceDiscount = 0 THEN sod.OrderQty ELSE 0 END) AS VolumeSoldWithoutDiscount,
    SUM(CASE WHEN sod.UnitPriceDiscount > 0 THEN sod.OrderQty ELSE 0 END) AS VolumeSoldWithDiscount,
    SUM(sod.UnitPrice * sod.OrderQty * (1 - sod.UnitPriceDiscount)) AS RevenueWithDiscount,
    SUM(sod.UnitPrice * sod.OrderQty) AS RevenueWithoutDiscount,
    SUM((sod.UnitPrice - c.StandardCost) * sod.OrderQty * (1 - sod.UnitPriceDiscount)) AS ProfitWithDiscount,
    SUM((sod.UnitPrice - c.StandardCost) * sod.OrderQty) AS ProfitWithoutDiscount
FROM 
    Sales.SalesOrderDetail sod
JOIN 
    Production.Product p ON p.ProductID = sod.ProductID
JOIN 
    Production.ProductCostHistory c ON c.ProductID = p.ProductID
WHERE 
    c.StartDate <= sod.ModifiedDate AND (c.EndDate >= sod.ModifiedDate OR c.EndDate IS NULL)
GROUP BY 
    p.Name, sod.ProductID, YEAR(sod.ModifiedDate), sod.UnitPrice, sod.UnitPriceDiscount * 100, sod.UnitPrice * (1 - sod.UnitPriceDiscount);




---Pricing/Discount Analysis
	SELECT 
    p.Name AS ProductModelName,
    sod.ProductID,
    YEAR(sod.ModifiedDate) AS Year,
    sod.UnitPrice AS OriginalPrice,
    sod.UnitPriceDiscount * 100 AS DiscountPercent,
    sod.UnitPrice * (1 - sod.UnitPriceDiscount) AS DiscountedPrice,
    SUM(CASE WHEN sod.UnitPriceDiscount = 0 THEN sod.OrderQty ELSE 0 END) AS VolumeSoldWithoutDiscount,
    SUM(CASE WHEN sod.UnitPriceDiscount > 0 THEN sod.OrderQty ELSE 0 END) AS VolumeSoldWithDiscount,
    SUM(sod.UnitPrice * sod.OrderQty * (1 - sod.UnitPriceDiscount)) AS RevenueWithDiscount,
    SUM(sod.UnitPrice * sod.OrderQty) AS RevenueWithoutDiscount,
    SUM((sod.UnitPrice - c.StandardCost) * sod.OrderQty * (1 - sod.UnitPriceDiscount)) AS ProfitWithDiscount,
    SUM((sod.UnitPrice - c.StandardCost) * sod.OrderQty) AS ProfitWithoutDiscount,
    CASE 
	WHEN soh.[OnlineOrderFlag] = 1 THEN 'Online' ELSE 'Reseller'
	END AS SalesChannel,

    t.Name AS TerritoryRegion
FROM 
    Sales.SalesOrderDetail sod
JOIN 
    Production.Product p ON p.ProductID = sod.ProductID
JOIN 
    Production.ProductCostHistory c ON c.ProductID = p.ProductID
JOIN 
    Sales.SalesOrderHeader soh ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Sales.SalesTerritory t ON t.TerritoryID = soh.TerritoryID
WHERE 
    c.StartDate <= sod.ModifiedDate AND (c.EndDate >= sod.ModifiedDate OR c.EndDate IS NULL)
GROUP BY 
    p.Name, sod.ProductID, YEAR(sod.ModifiedDate), sod.UnitPrice, sod.UnitPriceDiscount * 100, sod.UnitPrice * (1 - sod.UnitPriceDiscount), soh.[OnlineOrderFlag], t.Name;

	SELECT 
    pc.Name AS ProductCategoryName,
    sod.ProductID,
    YEAR(sod.ModifiedDate) AS Year,
    sod.UnitPrice AS OriginalPrice,
    sod.UnitPriceDiscount * 100 AS DiscountPercent,
    sod.UnitPrice * (1 - sod.UnitPriceDiscount) AS DiscountedPrice,
    SUM(CASE WHEN sod.UnitPriceDiscount = 0 THEN sod.OrderQty ELSE 0 END) AS VolumeSoldWithoutDiscount,
    SUM(CASE WHEN sod.UnitPriceDiscount > 0 THEN sod.OrderQty ELSE 0 END) AS VolumeSoldWithDiscount,
    SUM(sod.UnitPrice * sod.OrderQty * (1 - sod.UnitPriceDiscount)) AS RevenueWithDiscount,
    SUM(sod.UnitPrice * sod.OrderQty) AS RevenueWithoutDiscount,
    SUM((sod.UnitPrice - c.StandardCost) * sod.OrderQty * (1 - sod.UnitPriceDiscount)) AS ProfitWithDiscount,
    SUM((sod.UnitPrice - c.StandardCost) * sod.OrderQty) AS ProfitWithoutDiscount,
     CASE 
	WHEN soh.[OnlineOrderFlag] = 1 THEN 'Online' ELSE 'Reseller'
	END AS SalesChannel,
	soh.[OnlineOrderFlag] AS SalesChannel,
    t.Name AS TerritoryRegion
FROM 
    Sales.SalesOrderDetail sod
JOIN 
    Production.Product p ON p.ProductID = sod.ProductID
JOIN 
    Production.ProductSubcategory ps ON ps.ProductSubcategoryID = p.ProductSubcategoryID
JOIN 
    Production.ProductCategory pc ON pc.ProductCategoryID = ps.ProductCategoryID
JOIN 
    Production.ProductCostHistory c ON c.ProductID = p.ProductID
JOIN 
    Sales.SalesOrderHeader soh ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Sales.SalesTerritory t ON t.TerritoryID = soh.TerritoryID
WHERE 
    c.StartDate <= sod.ModifiedDate AND (c.EndDate >= sod.ModifiedDate OR c.EndDate IS NULL)
GROUP BY 
    pc.Name, sod.ProductID, YEAR(sod.ModifiedDate), sod.UnitPrice, sod.UnitPriceDiscount * 100, sod.UnitPrice * (1 - sod.UnitPriceDiscount), soh.[OnlineOrderFlag], t.Name;
	

	SELECT VendorID, COUNT(PurchaseOrderID) as LateOrders,OrderDate,
    DATEADD(day, 7, OrderDate) AS DueDate
FROM Purchasing.PurchaseOrderHeader
WHERE ShipDate > DATEADD(day, 7, OrderDate)
GROUP BY VendorID;

SELECT 
    VendorID,
    COUNT(PurchaseOrderID) as LateOrders
FROM 
    Purchasing.PurchaseOrderHeader
WHERE 
    ShipDate > DATEADD(day, 7, OrderDate)
GROUP BY 
    VendorID;

	SELECT ProductID, SUM(Quantity) as TotalQuantity
FROM Production.ProductInventory
GROUP BY ProductID
HAVING SUM(Quantity) < 100;
select * from Sales.SalesOrderDetail



SELECT 
    p.ProductID,
    pc.Name AS ProductCategoryName,
    sr.Name AS ScrapReason,
    COUNT(wo.WorkOrderID) as ScrapCount
FROM 
    Production.WorkOrder wo
JOIN 
    Production.Product p ON p.ProductID = wo.ProductID
JOIN 
    Production.ProductSubcategory ps ON ps.ProductSubcategoryID = p.ProductSubcategoryID
JOIN 
    Production.ProductCategory pc ON pc.ProductCategoryID = ps.ProductCategoryID
JOIN 
    Production.ScrapReason sr ON sr.ScrapReasonID = wo.ScrapReasonID
WHERE 
    wo.ScrapReasonID IS NOT NULL
GROUP BY 
    p.ProductID, pc.Name, sr.Name
ORDER BY 
    ScrapCount DESC;

SELECT 
    P.ProductID,
    P.Name AS ProductName,
    V.BusinessEntityID AS VendorID,
    V.Name AS VendorName,
    POH.PurchaseOrderID,
    POH.OrderDate,
    POD.OrderQty
FROM 
    Production.Product P
JOIN 
    Purchasing.ProductVendor PV ON P.ProductID = PV.ProductID
JOIN 
    Purchasing.Vendor V ON PV.BusinessEntityID = V.BusinessEntityID
JOIN 
    Purchasing.PurchaseOrderHeader POH ON V.BusinessEntityID = POH.VendorID
JOIN 
    Purchasing.PurchaseOrderDetail POD ON POH.PurchaseOrderID = POD.PurchaseOrderID
WHERE 
    P.ProductID = POD.ProductID;

	SELECT 
    SOH.SalesOrderID,
    SOH.OrderDate,
    SOD.ProductID,
    P.Name AS ProductName,
    SOD.OrderQty,
    SOH.Status
FROM 
    Sales.SalesOrderHeader SOH
JOIN 
    Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
JOIN 
    Production.Product P ON SOD.ProductID = P.ProductID
WHERE 
    SOH.Status = 5;

	SELECT 
    P.ProductID,
    P.Name AS ProductName,
    P.StandardCost,
    P.ListPrice,
    V.BusinessEntityID AS VendorID,
    V.Name AS VendorName,
    POH.PurchaseOrderID,
    POH.OrderDate,
    POH.Status AS OrderStatus,
    PV.StandardPrice,
    PV.AverageLeadTime,
    POD.OrderQty,
    (POD.OrderQty * P.ListPrice) AS TotalPrice
FROM 
    Production.Product P
JOIN 
    Purchasing.ProductVendor PV ON P.ProductID = PV.ProductID
JOIN 
    Purchasing.Vendor V ON PV.BusinessEntityID = V.BusinessEntityID
JOIN 
    Purchasing.PurchaseOrderHeader POH ON V.BusinessEntityID = POH.VendorID
JOIN 
    Purchasing.PurchaseOrderDetail POD ON POH.PurchaseOrderID = POD.PurchaseOrderID
WHERE 
    P.ProductID = POD.ProductID;
	---SUPPLY CHAIN ANALYSIS
SELECT 
    P.ProductID,
    P.Name AS ProductName,
    P.StandardCost,
    P.ListPrice,
    V.BusinessEntityID AS VendorID,
    V.Name AS VendorName,
    POH.PurchaseOrderID,
    POH.OrderDate,
    CASE 
        WHEN POH.Status = 1 THEN 'Pending'
        WHEN POH.Status = 2 THEN 'Approved'
        WHEN POH.Status = 3 THEN 'Rejected'
        WHEN POH.Status = 4 THEN 'Complete'
        ELSE 'Unknown'
    END AS OrderStatus,
    PV.StandardPrice,
    PV.AverageLeadTime,
    POD.OrderQty,
    (POD.OrderQty * P.ListPrice) AS TotalPrice
FROM 
    Production.Product P
JOIN 
    Purchasing.ProductVendor PV ON P.ProductID = PV.ProductID
JOIN 
    Purchasing.Vendor V ON PV.BusinessEntityID = V.BusinessEntityID
JOIN 
    Purchasing.PurchaseOrderHeader POH ON V.BusinessEntityID = POH.VendorID
JOIN 
    Purchasing.PurchaseOrderDetail POD ON POH.PurchaseOrderID = POD.PurchaseOrderID
WHERE 
    P.ProductID = POD.ProductID;

---ORDER STATUS, REJECTED, SHIPPED ETC

SELECT 
    SOH.SalesOrderID,
    SOH.OrderDate,
    SOD.ProductID,
    P.Name AS ProductName,
    SOD.OrderQty,
    CASE SOH.Status
        WHEN 1 THEN 'In process'
        WHEN 2 THEN 'Approved'
        WHEN 3 THEN 'Backordered'
        WHEN 4 THEN 'Rejected'
        WHEN 5 THEN 'Shipped'
        WHEN 6 THEN 'Cancelled'
        ELSE 'Unknown'
    END AS Status
FROM 
    Sales.SalesOrderHeader SOH
JOIN 
    Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
JOIN 
    Production.Product P ON SOD.ProductID = P.ProductID
WHERE 
    SOH.Status = 4;

SELECT 
    P.ProductID,
    P.Name AS ProductName,
    P.StandardCost,
    P.ListPrice,
    (P.ListPrice - P.StandardCost) AS ProfitMargin
FROM 
    Production.Product P;

---Actual Cost by Assembly Location
	SELECT 
    L.Name AS LocationName,
    SUM(P.StandardCost * PI.Quantity) AS TotalCost
FROM 
    Production.Product P
JOIN 
    Production.ProductInventory PI ON P.ProductID = PI.ProductID
JOIN 
    Production.Location L ON PI.LocationID = L.LocationID
GROUP BY 
    L.Name;
---Scrap Products and Percentage per year---

SELECT 
    YEAR(WO.StartDate) AS Year,
    P.ProductID,
    P.Name AS ProductName,
    SUM(WO.OrderQty) AS TotalProduced,
    SUM(WO.ScrappedQty) AS TotalScrapped,
    (SUM(WO.ScrappedQty) * 1.0 / SUM(WO.OrderQty)) * 100 AS ScrapPercentage,
    SUM(WO.ScrappedQty) * P.StandardCost AS ScrapCost
FROM 
    Production.Product P
JOIN 
    Production.WorkOrder WO ON P.ProductID = WO.ProductID
GROUP BY 
    YEAR(WO.StartDate),
    P.ProductID,
    P.Name,
    P.StandardCost;


---Scrap Reason and percentage per year

SELECT 
    YEAR(WO.StartDate) AS Year,
    SR.ScrapReasonID,
    SR.Name AS ScrapReasonName,
    COUNT(WO.WorkOrderID) AS WorkOrderCount,
    (COUNT(WO.WorkOrderID) * 1.0 / (SELECT COUNT(*) FROM Production.WorkOrder WHERE ScrapReasonID IS NOT NULL)) * 100 AS WorkOrderPercentage
FROM 
    Production.WorkOrder WO
JOIN 
    Production.ScrapReason SR ON WO.ScrapReasonID = SR.ScrapReasonID
WHERE 
    WO.ScrapReasonID IS NOT NULL
GROUP BY 
    YEAR(WO.StartDate),
    SR.ScrapReasonID,
    SR.Name;

---Waste cost by year---
SELECT 
    YEAR(SOH.OrderDate) AS Year,
    P.ProductID,
    P.Name AS ProductName,
    SUM(SOD.OrderQty) AS QuantityOrdered,
    SUM(SOD.OrderQty) - ISNULL(SUM(SOH.SubTotal), 0) AS PotentialWaste,
    (SUM(SOD.OrderQty) - ISNULL(SUM(SOH.SubTotal), 0)) * P.StandardCost AS WasteCost
FROM 
    Sales.SalesOrderDetail SOD
JOIN 
    Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
JOIN 
    Production.Product P ON SOD.ProductID = P.ProductID
GROUP BY 
    YEAR(SOH.OrderDate),
    P.ProductID,
    P.Name,
    P.StandardCost;
---Days of Manufacture per year---
SELECT 
    YEAR(WO.StartDate) AS Year,
    WO.WorkOrderID,
    P.ProductID,
    P.Name AS ProductName,
    WO.StartDate,
    WO.EndDate,
    DATEDIFF(day, WO.StartDate, WO.EndDate) AS ManufacturingDays
FROM 
    Production.WorkOrder WO
JOIN 
    Production.Product P ON WO.ProductID = P.ProductID;

---OTD---
SELECT *,
CASE 
    WHEN ShipDate <= DueDate THEN 'Met OTD'
    ELSE 'Did not meet OTD'
END as OTD_Status
FROM Sales.SalesOrderHeader;

---Freight---
SELECT SalesOrderID, YEAR(OrderDate) as OrderYear, Freight,
CASE 
    WHEN Freight > (SELECT AVG(Freight) FROM Sales.SalesOrderHeader WHERE YEAR(OrderDate) = YEAR(s.OrderDate)) THEN 'High'
    ELSE 'Low'
END as FreightCostStatus
FROM Sales.SalesOrderHeader s;







	



