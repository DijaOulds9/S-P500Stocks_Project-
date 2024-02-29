SELECT * FROM `S&P500Stocks_Analysis`.abbv_stock;
#Combining all Values into 1 Table

Create Table Stocks_Data AS 
Select * From abbv_stock 
Union All 
Select * From acn_stock 
Union All 
Select * From aos_stock; 

# Daily Return 
select date, symbol,
Close,ROUND(( close - Lag(close, 1) over (partition by symbol Order by date))/ (Lag(close, 1) Over (Partition by Symbol Order by Date)),2) As Daily_Return 
From Stocks_Data
where symbol IN ("abbv", "acn", "aos")
order by date, symbol; 

# Finding the highest and lowest closing prices for each stock
Select 
symbol,
Max(close) AS Highest_Closing_Price, Min(Close) AS Lowest_Closing_Price 
From Stocks_Data
Group by symbol
order by Symbol; 

# Finding recovery Days 
# Using DateDiff and Subqueries to find the Peak of stock before decline and lowest price.
SELECT 
    DATEDIFF (
        (SELECT MIN(date) FROM aos_stock WHERE close >= (SELECT MAX(close) FROM aos_stock)),
        (SELECT MIN(date) FROM aos_stock WHERE close = (SELECT MIN(close) FROM aos_stock WHERE close < (SELECT MAX(close) FROM abbv_stock)))
	) AS recovery_days; 

# Voltality     
#insight: the lower the better 
select date, symbol,
Close, ROUND(( close - Lag(close, 1) over (partition by symbol Order by date))/ (Lag(close, 1) Over (Partition by Symbol Order by Date)),2) As Daily_Return 
From Stocks_Data
where symbol IN ("abbv", "acn", "aos")
order by date, symbol;

With Returns AS( 
Select Date,
Symbol,
Log(close/Lag(close,1) Over(Partition By symbol order by date)) AS log_Return
From Stocks_Data)
Select 
Symbol,
Round(Sqrt(252* AVG(Log_return*log_return)-AVG(log_return)* AVG(Log_return)),2) AS Volatility 
From Returns
Group By Symbol; 

#Calculating the Drawdown 
# Formula ((Peak- Trough)/peak)*100
With Peak AS(
Select Max(close) AS Peak_Price From Stocks_Data), 
Through AS(
select 
symbol, 
Min(close) AS Through_Price From Stocks_Data
Where Close <(Select Max(close) From Stocks_Data)
group By symbol), 
Drawdown AS(
Select
Symbol,
((Select Peak_Price From Peak)- Through_Price)/(Select Peak_Price From Peak)* 100 As Drawdown_Perecentage
From Through)
Select symbol, 
Drawdown_Perecentage AS Drawdown From Drawdown;



  
 








