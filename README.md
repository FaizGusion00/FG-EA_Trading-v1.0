# FG ScalpingPro EA Trading System v1.10

## Overview
The FG ScalpingPro EA is a professional-grade trading system developed by Faiz Nasir for FGCompany Original Trading. This sophisticated Expert Advisor combines multiple technical indicators and adaptive algorithms to identify high-probability trading setups across different market conditions, with a target win rate of 90%+.

## Key Features
- **Multi-Indicator Approach**: Combines Bollinger Bands, EMAs, RSI, ATR, and volume analysis
- **Market Phase Detection**: Automatically identifies trending, ranging, and volatile market conditions
- **Dynamic Parameter Adjustment**: Adapts strategy parameters based on current market phase
- **Advanced Exit Strategies**: Trailing stops and partial profit taking to maximize profit potential
- **Comprehensive Risk Management**: Position sizing, daily loss limits, and volatility filters
- **Currency Pair Optimization**: Specific settings for major forex pairs
- **Advanced Filtering System**: Time, volatility, RSI, and news filters to avoid unfavorable conditions
- **Visual Indicator**: Clear visual signals for manual trading confirmation
- **Multi-Pair Backtesting**: Built-in tools for testing across multiple pairs and timeframes

## Files Included
1. **FG_ScalpingPro_EA.mq5** - The main Expert Advisor file
2. **FG_ScalpingPro_Indicator.mq5** - Custom indicator for chart visualization
3. **FG_ScalpingPro_Backtester.mq5** - Multi-pair/multi-timeframe backtesting script

## Detailed Strategy Overview

### Entry Logic
The EA uses a sophisticated multi-layered approach to identify high-probability entry points:

**Buy Signal Conditions:**
- Primary Trend: EMA Fast (9) > EMA Slow (21) indicating bullish trend
- Price Action: Price above Fast EMA with recent touch or cross
- Momentum: RSI showing upward momentum after coming from oversold territory
- Volume: Above-average volume to confirm signal strength

**Sell Signal Conditions:**
- Primary Trend: EMA Fast (9) < EMA Slow (21) indicating bearish trend
- Price Action: Price below Fast EMA with recent touch or cross
- Momentum: RSI showing downward momentum after coming from overbought territory
- Volume: Above-average volume to confirm signal strength

### Market Phase Detection
One of the EA's key strengths is its ability to detect and adapt to different market phases:

1. **Trending Markets**
   - Identified by: Strong separation between EMAs relative to ATR
   - Strategy Adjustment: Increases TP targets by 50% to capture extended moves
   - Optimization: Favors trend-following signals over mean reversion

2. **Ranging Markets**
   - Identified by: Narrow Bollinger Bands (width < 1.5% of price)
   - Strategy Adjustment: Reduces TP targets by 20% to account for limited movement
   - Optimization: Focuses on mean reversion signals

3. **Volatile Markets**
   - Identified by: Rapid changes in ATR (>20% increase)
   - Strategy Adjustment: Widens stop losses by 20% to avoid premature exits
   - Optimization: More stringent entry criteria to filter out false signals

### Exit Strategies
The EA employs a multi-tiered approach to exits:

1. **Dynamic Stop Loss and Take Profit**
   - Based on ATR to adapt to current market volatility
   - Pair-specific settings for major currency pairs
   - Automatically adjusted based on detected market phase

2. **Trailing Stop Algorithm**
   - Activates after price moves favorably by 50% of target (customizable)
   - Step size of 5 points (customizable)
   - Helps lock in profits while allowing room for price fluctuations

3. **Partial Position Closing**
   - Closes 50% of position once price reaches halfway to target (customizable)
   - Secures partial profits while allowing remainder to reach full target
   - Particularly effective in volatile and trending markets

### Risk Management System
Comprehensive risk controls are built into every level of the strategy:

1. **Position Sizing Algorithm**
   - Calculates lot size based on defined risk percentage (default 1%)
   - Accounts for current stop loss distance in points
   - Maximum lot size capped at 0.05 lots (customizable)

2. **Daily Loss Protection**
   - Stops trading after reaching daily loss limit (default 5% of balance)
   - Automatically resets at the start of each trading day
   - Prevents cascading losses during adverse market conditions

3. **Volatility Filters**
   - Requires minimum ATR value to ensure sufficient market movement
   - Prevents trading during exceptionally low volatility periods
   - Adjusts parameters during high volatility to accommodate wider price swings

### Advanced Filtering System
Multiple layers of filters designed to avoid poor trading conditions:

1. **RSI Filter**
   - Prevents buying when RSI is overbought (>70)
   - Prevents selling when RSI is oversold (<30)
   - Requires momentum in the direction of the trade

2. **Time Filters**
   - Trading hours restriction (default 8:00-12:00 EST, the London/NY overlap)
   - Day of week options to avoid specific trading days
   - Essential for avoiding thin market conditions

3. **Volume Filter**
   - Requires volume above the moving average for valid signals
   - Helps confirm signal strength and avoid false breakouts

4. **News Filter**
   - Framework for avoiding trading during high-impact news events
   - Customizable time windows before and after news releases

## Installation Guide

### Setting Up the EA

1. **Copy Files to MetaTrader Directory**:
   - Navigate to your MetaTrader 5 data folder (typically `C:\Users\[YourUsername]\AppData\Roaming\MetaQuotes\Terminal\[UNIQUE_ID]`)
   - Copy `FG_ScalpingPro_EA.mq5` to the `MQL5\Experts` folder
   - Copy `FG_ScalpingPro_Indicator.mq5` to the `MQL5\Indicators` folder
   - Copy `FG_ScalpingPro_Backtester.mq5` to the `MQL5\Scripts` folder

2. **Compile the Files**:
   - Open MetaTrader 5
   - Press F4 or go to Tools > MetaEditor to open the editor
   - In the Navigator panel, find and right-click on each file
   - Select "Compile" for each file
   - Ensure there are no compilation errors

3. **Add EA to Chart**:
   - Open a chart for your desired currency pair (recommended: EUR/USD, GBP/USD, USD/JPY, or AUD/USD)
   - Set the timeframe to M15 (15-minute chart)
   - In the Navigator panel, find "FG_ScalpingPro_EA" under Expert Advisors
   - Drag and drop it onto your chart, or double-click it
   - Configure the settings in the popup dialog (see "Optimal Settings" below)
   - Click "OK"

4. **Enable Automated Trading**:
   - Click the "AutoTrading" button in the top toolbar (or press Alt+T)
   - Ensure the button turns green, indicating that automated trading is enabled
   - Confirm that the EA is running by checking for a smiley face in the top-right corner of the chart

### Optimal Settings

#### General EA Settings
- **Magic Number**: 123456 (or any unique number)
- **Risk Percent**: 0.5-1.0% (recommended for consistent growth)
- **Max Lot Size**: 0.05 (prevents oversized positions)
- **Daily Loss Limit**: 5% (prevents excessive drawdowns)

#### Indicator Settings
- **Bollinger Bands**: Period=20, Deviation=2.5
- **EMAs**: Fast=9, Slow=21
- **RSI**: Period=14, Overbought=70, Oversold=30
- **ATR Period**: 14
- **Volume Period**: 20

#### Exit Strategy Settings
- **Trailing Stop**: Enabled, start at 50% of TP distance, 5-point step
- **Partial Close**: Enabled, close 50% of position when 50% of TP is reached
- **Dynamic ATR Multipliers**: Enabled, adjusts based on market phase
- **ATR Multiplier for TP**: 1.5 (base value, automatically adjusted)
- **ATR Multiplier for SL**: 1.0 (base value, automatically adjusted)

#### Filters
- **Time Filter**: Enable and set trading hours to 8:00-12:00 EST (London/NY overlap)
- **Volume Filter**: Enabled (only trades with above-average volume)
- **ATR Minimum**: 15 points (avoids low-volatility environments)
- **RSI Filter**: Enabled (avoids overbought/oversold contradictions)

#### Pair-Specific Settings (Default Values)
- EUR/USD: TP:15 pips, ATR:1.5x
- GBP/USD: TP:20 pips, ATR:1.3x
- USD/JPY: TP:18 pips, ATR:1.2x
- AUD/USD: TP:16 pips, ATR:1.4x

## Backtesting Instructions

### Using Built-in Strategy Tester
1. Open the Strategy Tester (Ctrl+R or View > Strategy Tester)
2. Select "FG_ScalpingPro_EA" from the dropdown
3. Choose your desired symbol (e.g., EUR/USD)
4. Set the timeframe to M15
5. Select the date range (recommended: test at least 1 year of data)
6. Set "Model" to "Every tick" for most accurate results
7. Click "Start" to begin the backtest

### Using Multi-pair/Multi-timeframe Backtester
1. In the Navigator panel, find "FG_ScalpingPro_Backtester" under Scripts
2. Right-click and select "Modify" to adjust settings if needed
3. Configure the input parameters:
   - Run Mode: Choose between single backtest, multi-pair, or multi-timeframe
   - Symbols to Test: List of currency pairs to test (default: EURUSD,GBPUSD,USDJPY,AUDUSD)
   - Timeframes to Test: List of timeframes to test (default: M15,M30,H1)
   - Start/End Date: Set your desired testing period
4. Close the editor and right-click the script in Navigator
5. Select "Run Script" to start the multi-pair/multi-timeframe backtesting
6. Review the results in both the Terminal log and the generated report file

## Troubleshooting

### Common Issues
1. **EA Not Trading**:
   - Ensure "AutoTrading" is enabled
   - Check "Common" tab in EA settings and confirm "Allow live trading" is enabled
   - Verify your broker allows automated trading
   - Check journal log for errors (Ctrl+T)

2. **Compilation Errors**:
   - Ensure you have the latest version of MetaTrader 5
   - Check that all required libraries are included
   - Verify proper syntax for string operations like StringTrimLeft and StringTrimRight

3. **Backtester Issues**:
   - Make sure all EA files are compiled successfully
   - Check that symbol names are correct in the backtester settings
   - Verify you have historical data for the selected period

## Performance Optimization

### Fine-Tuning for Different Market Conditions
- **Trending Markets**: Consider increasing the TrailingStart parameter to 0.7 to avoid premature trailing
- **Ranging Markets**: Consider decreasing ATR_Multiplier_TP to 1.2 for more realistic targets
- **Volatile Pairs (GBP/USD, GBP/JPY)**: Consider increasing ATR_Multiplier_SL to 1.2
- **Quiet Pairs (EUR/USD, USD/CHF)**: Consider decreasing ATR_MinValue to 12

### Risk Management Suggestions
- Start with 0.5% risk per trade until the system proves itself on your account
- Consider reducing DailyLossPercent to 3% for more conservative protection
- Test different PartialClosePercent values (30%, 50%, 70%) to find optimal performance

## Important Notes

- **Demo Testing**: Always test on a demo account for at least one month before live trading
- **Risk Warning**: Past performance doesn't guarantee future results, even with 90%+ win rate
- **Parameter Optimization**: Consider optimizing parameters for your specific trading conditions
- **News Avoidance**: EA includes a news filter, but consider manually disabling during major news events
- **RSI Customization**: Adjust RSI settings based on your preferred trading style
- **Exit Strategy Fine-tuning**: Partial closes and trailing stops can be adjusted to match market conditions

## Version History

- **v1.00**: Initial release with basic functionality
- **v1.10**: Added RSI analysis, market phase detection, advanced exit strategies (trailing stops and partial closes), dynamic ATR multipliers, daily loss limits, and comprehensive backtesting tools

## Support & Contact
For support, updates, or questions, please contact:
FGCompany Original Trading
Website: https://www.fgtrading.com

## Copyright Notice
Copyright © 2025, FGCompany Original Trading
Developed by Faiz Nasir
All rights reserved. 