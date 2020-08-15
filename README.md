# StockBar

A menu bar app that tracks stock price changes every minute.
The menu bar item displays the daily position changes if the unit size is provided in the settings. Otherwise, the per unit daily changes is displayed.
![mainDisplay](Screenshots/StockBar.png)
Click on the symbol name to show details such as the price, the change percentage, the last updated time stamp, and the position information.

<img src="Screenshots/StockDetails.png" alt="details" width="200">

## Preference
Provide the stock **symbols** to track in preference view. If the unit size and the average position costs are supplied, the open profit and loss will also be tracked. Click **StockBar** in the menu bar and select **Preference**.
![preference](Screenshots/Settings.png)
## API
* In use: [yahoo finance api](https://query1.finance.yahoo.com/v8/finance/chart/AAPL?interval=1d). However, there is no official guide.
* Other apis:
    1. another yahoo api that can query multiple symbols at the same time. https://query1.finance.yahoo.com/v7/finance/quote?fields=symbol,shortName,priceHint,regularMarketPrice,regularMarketChange,regularMarketChangePercent,currency,regularMarketTime,fiftyTwoWeekHigh,fiftyTwoWeekLow&symbols=AAPL,GOOG
    2. [alphavantage](https://www.alphavantage.co). Free API key is available (By the time of writing, any string can be a valid free API key). However, the free API can only send five requests per minute. It only has end-of-day Nasdaq quotes.
