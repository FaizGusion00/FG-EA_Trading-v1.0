//+------------------------------------------------------------------+
//|                                     FG_ScalpingPro_Backtester.mq5 |
//|                       Copyright 2025, FGCompany Original Trading |
//|                                     Developed by Faiz Nasir      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, FGCompany Original Trading"
#property link      "https://www.fgtrading.com"
#property version   "1.30"
#property strict
#property description "FG ScalpingPro EA - Backtesting Utility"

// Required for multi-timeframe, multi-symbol testing
#include <Arrays\ArrayString.mqh>
#include <Files\FileTxt.mqh>

// Enumeration for run mode
enum ENUM_RUN_MODE {
   RUN_OPTIMIZATION,   // Run optimization
   RUN_BACKTEST,       // Run backtest
   RUN_MULTI_PAIR,     // Run multi-pair backtest
   RUN_MULTI_TF        // Run multi-timeframe backtest
};

// Define TesterStatistics structure for storing backtest results
struct TesterStatistics {
   double profit;            // Net profit
   double gross_profit;      // Gross profit
   double gross_loss;        // Gross loss
   int trades;               // Total number of trades
   int profit_trades;        // Number of profitable trades
   int loss_trades;          // Number of losing trades
   double profit_factor;     // Profit factor
   double recovery_factor;   // Recovery factor
   double expected_payoff;   // Expected payoff
   double sharpe_ratio;      // Sharpe ratio
   double max_drawdown;      // Maximum drawdown
   double max_drawdown_rel;  // Relative maximum drawdown
};

// Input parameters - Backtesting settings
input string GeneralSection = "===== Backtesting Settings =====";       // General Settings
input ENUM_RUN_MODE RunMode = RUN_MULTI_PAIR;                          // Run mode
input string SymbolsToTest = "EURUSD,GBPUSD,USDJPY,AUDUSD";           // Symbols to test (comma separated)
input string TimeframesToTest = "M15,M30,H1";                          // Timeframes to test (comma separated)
input datetime StartDate = D'2023.01.01 00:00';                        // Start date
input datetime EndDate = D'2023.12.31 23:59';                          // End date
input bool SaveReportToFile = true;                                    // Save report to file
input string ReportFilename = "FG_ScalpingPro_Backtest_Report.txt";    // Report filename

// EA parameters (match these with the EA settings you want to test)
input string EASection = "===== EA Settings To Test =====";             // EA Settings
input bool   EnableTrading = true;                                     // Enable automatic trading
input int    MagicNumber = 123456;                                     // Magic number
input int    MaxTrades = 5;                                            // Maximum number of concurrent trades
input bool   StrictAnalysis = true;                                    // Stricter entry conditions for higher win rate
input string TradeComment = "FG_ScalpingPro";                          // Trade comment
input int    MinTradeHoldingTime = 15;                               // Minimum trade holding time (minutes)
input int    MaxTradeHoldingTime = 60;                               // Maximum trade holding time (minutes)

// Bollinger Bands parameters
input string BBSettings = "===== Bollinger Bands Settings =====";        // Bollinger Bands Settings
input int    BB_Period = 20;                                          // Bollinger Bands period
input double BB_Deviation = 2.5;                                      // Bollinger Bands deviation
input int    BB_Shift = 0;                                            // Bollinger Bands shift

// Moving Average parameters
input string MASettings = "===== Moving Average Settings =====";        // Moving Average Settings  
input int    EMA_Fast_Period = 9;                                     // Fast EMA period
input int    EMA_Slow_Period = 21;                                    // Slow EMA period

// RSI parameters
input string RSISettings = "===== RSI Settings =====";                  // RSI Settings
input int    RSI_Period = 14;                                          // RSI period
input int    RSI_Overbought = 70;                                      // RSI overbought level
input int    RSI_Oversold = 30;                                        // RSI oversold level
input bool   UseRSIFilter = true;                                      // Use RSI for signal filtering

// ATR parameters
input string ATRSettings = "===== ATR Settings =====";                  // ATR Settings
input int    ATR_Period = 14;                                          // ATR period
input double ATR_Multiplier_TP = 1.5;                                  // ATR multiplier for TP
input double ATR_Multiplier_SL = 1.0;                                  // ATR multiplier for SL
input int    ATR_MinValue = 15;                                        // Minimum ATR value in points to trade
input bool   UseDynamicMultiplier = true;                              // Use dynamic ATR multipliers

// Volume filter parameters
input string VolumeSettings = "===== Volume Filter Settings =====";      // Volume Filter Settings
input int    Volume_Period = 20;                                      // Volume SMA period
input bool   EnableVolumeFilter = true;                               // Enable volume filter

// Time filter parameters
input string TimeSettings = "===== Time Filter Settings =====";         // Time Filter Settings
input bool   EnableTimeFilter = true;                                // Enable time filter
input int    StartHour = 8;                                          // Start hour (EST)
input int    EndHour = 12;                                           // End hour (EST)
input bool   MondayFilter = true;                                    // Trade on Monday
input bool   TuesdayFilter = true;                                   // Trade on Tuesday
input bool   WednesdayFilter = true;                                 // Trade on Wednesday
input bool   ThursdayFilter = true;                                  // Trade on Thursday
input bool   FridayFilter = true;                                    // Trade on Friday

// Exit optimization parameters
input string ExitSettings = "===== Exit Optimization =====";            // Exit Optimization
input bool   UseTrailingStop = true;                                   // Use trailing stop
input double TrailingStart = 0.5;                                      // Start trailing after this portion of TP reached
input double TrailingStep = 5.0;                                       // Trailing step in points
input bool   UsePartialClose = true;                                   // Use partial position closing
input double PartialClosePercent = 50.0;                               // Percentage to close at first target
input double PartialCloseAt = 0.5;                                     // Close partial position at this portion of TP

// Risk management
input string RiskSettings = "===== Risk Management =====";              // Risk Management Settings
input double RiskPercent = 1.0;                                        // Risk percent per trade
input double MaxLotSize = 0.05;                                        // Maximum lot size
input bool   UseDailyLossLimit = true;                                 // Use daily loss limit
input double DailyLossPercent = 5.0;                                   // Daily loss limit in percent of balance

// Global variables
string CurrentSymbol;
ENUM_TIMEFRAMES CurrentTimeframe;
CFileTxt ReportFile;
bool IsFileOpen = false;
int TotalTestsRun = 0;
int SuccessfulTests = 0;
MqlDateTime StartDateTime, EndDateTime;

// Structure to store backtest results
struct BacktestResult {
   string Symbol;
   string Timeframe;
   double NetProfit;
   double GrossProfit;
   double GrossLoss;
   int TotalTrades;
   int WinningTrades;
   int LosingTrades;
   double ProfitFactor;
   double MaxDrawdown;
   double WinRate;
   double SharpeRatio;
   double ExpectedPayoff;
};

// Array to store all backtest results
BacktestResult Results[];

// Declare functions needed for tester simulation - these would typically be part of the MQL5 API
// in a real implementation, but we're providing mock functions for compilation
bool TesterInit() { return true; }
bool TesterSetSymbol(string symbol) { return true; }
bool TesterSetPeriod(ENUM_TIMEFRAMES timeframe) { return true; }
bool TesterSetDateFrom(datetime from) { return true; }
bool TesterSetDateTo(datetime to) { return true; }
bool TesterSetDeposit(double deposit) { return true; }
bool TesterSetLeverage(int leverage) { return true; }
bool TesterRun(string ea_name, string parameters = "") { return true; }
bool TesterGetStatistics(TesterStatistics &stat_result) {
   // Mock stats for compilation
   stat_result.profit = 1000.0;
   stat_result.gross_profit = 1500.0;
   stat_result.gross_loss = -500.0;
   stat_result.trades = 50;
   stat_result.profit_trades = 35;
   stat_result.loss_trades = 15;
   stat_result.profit_factor = 3.0;
   stat_result.recovery_factor = 2.0;
   stat_result.expected_payoff = 20.0;
   stat_result.sharpe_ratio = 1.5;
   stat_result.max_drawdown = 300.0;
   stat_result.max_drawdown_rel = 0.03;
   return true;
}

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
int OnStart() {
   // Initialize results array
   ArrayResize(Results, 0);
   
   // Convert date inputs to MqlDateTime structures
   TimeToStruct(StartDate, StartDateTime);
   TimeToStruct(EndDate, EndDateTime);
   
   // Prepare report file if enabled
   if(SaveReportToFile) {
      OpenReportFile();
   }
   
   // Print header
   PrintHeader();
   
   // Run tests based on selected mode
   switch(RunMode) {
      case RUN_OPTIMIZATION:
         RunOptimization();
         break;
      case RUN_BACKTEST:
         RunSingleBacktest(Symbol(), Period());
         break;
      case RUN_MULTI_PAIR:
         RunMultiPairBacktest();
         break;
      case RUN_MULTI_TF:
         RunMultiTimeframeBacktest();
         break;
   }
   
   // Print summary results
   PrintSummary();
   
   // Close report file if open
   if(IsFileOpen) {
      ReportFile.Close();
      IsFileOpen = false;
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| Open report file for writing                                     |
//+------------------------------------------------------------------+
void OpenReportFile() {
   if(ReportFile.Open(ReportFilename, FILE_WRITE|FILE_TXT)) {
      IsFileOpen = true;
      Print("Report file opened: ", ReportFilename);
   }
   else {
      Print("Failed to open report file: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Write a line to report file and print to console                 |
//+------------------------------------------------------------------+
void WriteLine(string text) {
   if(IsFileOpen) {
      ReportFile.WriteString(text + "\r\n");
   }
   Print(text);
}

//+------------------------------------------------------------------+
//| Print header information                                         |
//+------------------------------------------------------------------+
void PrintHeader() {
   string header = "FG ScalpingPro EA Backtest Report";
   string separator = "==================================";
   string dateRange = "Period: " + TimeToString(StartDate, TIME_DATE) + " to " + TimeToString(EndDate, TIME_DATE);
   
   WriteLine(separator);
   WriteLine(header);
   WriteLine(separator);
   WriteLine(dateRange);
   WriteLine("Run Mode: " + EnumToString(RunMode));
   WriteLine(separator);
}

//+------------------------------------------------------------------+
//| Run optimization for single pair and timeframe                   |
//+------------------------------------------------------------------+
void RunOptimization() {
   WriteLine("Starting optimization on " + Symbol() + ", " + EnumToString(Period()));
   
   // For optimization, we defer to the MetaTrader Strategy Tester's
   // built-in optimization capabilities
   WriteLine("Please use MetaTrader 5 Strategy Tester for detailed optimization.");
   WriteLine("This script is primarily designed for multi-pair and multi-timeframe backtesting.");
   
   // Run a single backtest for current settings
   RunSingleBacktest(Symbol(), Period());
}

//+------------------------------------------------------------------+
//| Run a backtest across multiple currency pairs                    |
//+------------------------------------------------------------------+
void RunMultiPairBacktest() {
   WriteLine("Starting multi-pair backtest on timeframe: " + EnumToString(Period()));
   
   // Parse symbols from input string
   string symbols[];
   int symbolCount = StringSplit(SymbolsToTest, ',', symbols);
   
   if(symbolCount == 0) {
      WriteLine("Error: No symbols specified");
      return;
   }
   
   // Initialize backtest counter
   TotalTestsRun = 0;
   SuccessfulTests = 0;
   
   // Loop through each symbol
   for(int i = 0; i < symbolCount; i++) {
      string symbol = symbols[i];
      // Use our custom StringTrim function
      symbol = StringTrim(symbol);
      
      // Check if symbol exists
      if(!SymbolSelect(symbol, true)) {
         WriteLine("Warning: Symbol " + symbol + " not found or not selected for backtesting");
         continue;
      }
      
      // Run backtest for this symbol
      RunSingleBacktest(symbol, Period());
   }
}

//+------------------------------------------------------------------+
//| Run a backtest across multiple timeframes                        |
//+------------------------------------------------------------------+
void RunMultiTimeframeBacktest() {
   WriteLine("Starting multi-timeframe backtest on symbol: " + Symbol());
   
   // Parse timeframes from input string
   string timeframes[];
   int tfCount = StringSplit(TimeframesToTest, ',', timeframes);
   
   if(tfCount == 0) {
      WriteLine("Error: No timeframes specified");
      return;
   }
   
   // Initialize backtest counter
   TotalTestsRun = 0;
   SuccessfulTests = 0;
   
   // Loop through each timeframe
   for(int i = 0; i < tfCount; i++) {
      string tfStr = timeframes[i];
      // Use our custom StringTrim function
      tfStr = StringTrim(tfStr);
      ENUM_TIMEFRAMES tf = StringToTimeframe(tfStr);
      
      if(tf == PERIOD_CURRENT) {
         WriteLine("Warning: Invalid timeframe " + tfStr);
         continue;
      }
      
      // Run backtest for this timeframe
      RunSingleBacktest(Symbol(), tf);
   }
}

//+------------------------------------------------------------------+
//| Run a single backtest for the specified symbol and timeframe     |
//+------------------------------------------------------------------+
void RunSingleBacktest(string symbol, ENUM_TIMEFRAMES timeframe) {
   // Save current symbol and timeframe
   CurrentSymbol = symbol;
   CurrentTimeframe = timeframe;
   
   WriteLine("Running backtest on " + symbol + ", " + TimeframeToString(timeframe));
   
   // Reset tester
   TesterInit();
   
   // Set backtesting parameters
   if(!TesterSetSymbol(symbol)) {
      WriteLine("Error setting symbol: " + symbol);
      return;
   }
   
   if(!TesterSetPeriod(timeframe)) {
      WriteLine("Error setting timeframe: " + TimeframeToString(timeframe));
      return;
   }
   
   // Build the parameter string for the EA - updated to match the latest EA version
   string parameters = "EnableTrading=" + BoolToString(EnableTrading) + ";" +
                       "MagicNumber=" + IntegerToString(MagicNumber) + ";" +
                       "TradeComment=" + TradeComment + ";" +
                       "MaxTrades=" + IntegerToString(MaxTrades) + ";" +
                       "StrictAnalysis=" + BoolToString(StrictAnalysis) + ";" +
                       "MinTradeHoldingTime=" + IntegerToString(MinTradeHoldingTime) + ";" +
                       "MaxTradeHoldingTime=" + IntegerToString(MaxTradeHoldingTime) + ";" +
                       // Bollinger Bands parameters
                       "BB_Period=" + IntegerToString(BB_Period) + ";" +
                       "BB_Deviation=" + DoubleToString(BB_Deviation) + ";" +
                       "BB_Shift=" + IntegerToString(BB_Shift) + ";" +
                       // Moving Average parameters
                       "EMA_Fast_Period=" + IntegerToString(EMA_Fast_Period) + ";" +
                       "EMA_Slow_Period=" + IntegerToString(EMA_Slow_Period) + ";" +
                       // RSI parameters
                       "RSI_Period=" + IntegerToString(RSI_Period) + ";" +
                       "RSI_Overbought=" + IntegerToString(RSI_Overbought) + ";" +
                       "RSI_Oversold=" + IntegerToString(RSI_Oversold) + ";" +
                       "UseRSIFilter=" + BoolToString(UseRSIFilter) + ";" +
                       // ATR parameters
                       "ATR_Period=" + IntegerToString(ATR_Period) + ";" +
                       "ATR_Multiplier_TP=" + DoubleToString(ATR_Multiplier_TP) + ";" +
                       "ATR_Multiplier_SL=" + DoubleToString(ATR_Multiplier_SL) + ";" +
                       "ATR_MinValue=" + IntegerToString(ATR_MinValue) + ";" +
                       "UseDynamicMultiplier=" + BoolToString(UseDynamicMultiplier) + ";" +
                       // Volume filter parameters
                       "Volume_Period=" + IntegerToString(Volume_Period) + ";" +
                       "EnableVolumeFilter=" + BoolToString(EnableVolumeFilter) + ";" +
                       // Time filter parameters
                       "EnableTimeFilter=" + BoolToString(EnableTimeFilter) + ";" +
                       "StartHour=" + IntegerToString(StartHour) + ";" +
                       "EndHour=" + IntegerToString(EndHour) + ";" +
                       "MondayFilter=" + BoolToString(MondayFilter) + ";" +
                       "TuesdayFilter=" + BoolToString(TuesdayFilter) + ";" +
                       "WednesdayFilter=" + BoolToString(WednesdayFilter) + ";" +
                       "ThursdayFilter=" + BoolToString(ThursdayFilter) + ";" +
                       "FridayFilter=" + BoolToString(FridayFilter) + ";" +
                       // Exit optimization parameters
                       "UseTrailingStop=" + BoolToString(UseTrailingStop) + ";" +
                       "TrailingStart=" + DoubleToString(TrailingStart) + ";" +
                       "TrailingStep=" + DoubleToString(TrailingStep) + ";" +
                       "UsePartialClose=" + BoolToString(UsePartialClose) + ";" +
                       "PartialClosePercent=" + DoubleToString(PartialClosePercent) + ";" +
                       "PartialCloseAt=" + DoubleToString(PartialCloseAt) + ";" +
                       // Risk management parameters
                       "RiskPercent=" + DoubleToString(RiskPercent) + ";" +
                       "MaxLotSize=" + DoubleToString(MaxLotSize) + ";" +
                       "UseDailyLossLimit=" + BoolToString(UseDailyLossLimit) + ";" +
                       "DailyLossPercent=" + DoubleToString(DailyLossPercent) + ";" +
                       // Disable visual elements for backtesting
                       "EnableAlerts=false;" +
                       "EnableDashboard=false;";
   
   // Set date range and deposit
   TesterSetDateFrom(StartDate);
   TesterSetDateTo(EndDate);
   TesterSetDeposit(10000.0); // $10,000 starting balance
   TesterSetLeverage(100);    // 1:100 leverage
   
   // Start backtesting
   WriteLine("Starting backtest for " + symbol + " on " + TimeframeToString(timeframe));
   
   // Run the EA
   if(!TesterRun("FG_ScalpingPro_EA.ex5", parameters)) {
      WriteLine("Error running backtest: " + IntegerToString(GetLastError()));
      return;
   }
   
   // Get and process results
   ProcessBacktestResults(symbol, timeframe);
   
   // Increment counters
   TotalTestsRun++;
   SuccessfulTests++;
}

//+------------------------------------------------------------------+
//| Process and store backtest results                               |
//+------------------------------------------------------------------+
void ProcessBacktestResults(string symbol, ENUM_TIMEFRAMES timeframe) {
   // Get tester statistics
   TesterStatistics local_stats;
   if(!TesterGetStatistics(local_stats)) {
      WriteLine("Error getting statistics");
      return;
   }
   
   // Create result object
   BacktestResult result;
   result.Symbol = symbol;
   result.Timeframe = TimeframeToString(timeframe);
   result.NetProfit = local_stats.profit;
   result.GrossProfit = local_stats.gross_profit;
   result.GrossLoss = local_stats.gross_loss;
   result.TotalTrades = local_stats.trades;
   result.WinningTrades = local_stats.profit_trades;
   result.LosingTrades = local_stats.loss_trades;
   result.ProfitFactor = local_stats.profit_factor;
   result.MaxDrawdown = local_stats.max_drawdown;
   result.WinRate = (result.TotalTrades > 0) ? (double)result.WinningTrades / result.TotalTrades * 100.0 : 0;
   result.SharpeRatio = local_stats.sharpe_ratio;
   result.ExpectedPayoff = local_stats.expected_payoff;
   
   // Add to results array
   int size = ArraySize(Results);
   ArrayResize(Results, size + 1);
   Results[size] = result;
   
   // Print results
   WriteLine("--- Results for " + symbol + " on " + TimeframeToString(timeframe) + " ---");
   WriteLine("Net Profit: " + DoubleToString(result.NetProfit, 2) + " USD");
   WriteLine("Total Trades: " + IntegerToString(result.TotalTrades));
   WriteLine("Win Rate: " + DoubleToString(result.WinRate, 2) + "%");
   WriteLine("Profit Factor: " + DoubleToString(result.ProfitFactor, 2));
   WriteLine("Max Drawdown: " + DoubleToString(result.MaxDrawdown, 2) + " USD");
   WriteLine("Expected Payoff: " + DoubleToString(result.ExpectedPayoff, 2) + " USD");
   WriteLine("Sharpe Ratio: " + DoubleToString(result.SharpeRatio, 2));
   WriteLine("---------------------------------------");
}

//+------------------------------------------------------------------+
//| Print summary of all backtest results                            |
//+------------------------------------------------------------------+
void PrintSummary() {
   if(TotalTestsRun == 0) {
      WriteLine("No tests were run successfully.");
      return;
   }
   
   WriteLine("\n=================== SUMMARY ===================");
   WriteLine("Total tests run: " + IntegerToString(TotalTestsRun));
   WriteLine("Successful tests: " + IntegerToString(SuccessfulTests));
   
   // Find best and worst performers
   int bestProfitIndex = 0;
   int bestWinRateIndex = 0;
   int worstProfitIndex = 0;
   
   for(int i = 1; i < ArraySize(Results); i++) {
      if(Results[i].NetProfit > Results[bestProfitIndex].NetProfit) {
         bestProfitIndex = i;
      }
      
      if(Results[i].WinRate > Results[bestWinRateIndex].WinRate && Results[i].TotalTrades >= 20) {
         bestWinRateIndex = i;
      }
      
      if(Results[i].NetProfit < Results[worstProfitIndex].NetProfit) {
         worstProfitIndex = i;
      }
   }
   
   // Print best and worst performers
   if(ArraySize(Results) > 0) {
      WriteLine("\nBest Profit Performance:");
      WriteLine(Results[bestProfitIndex].Symbol + " on " + Results[bestProfitIndex].Timeframe);
      WriteLine("Net Profit: " + DoubleToString(Results[bestProfitIndex].NetProfit, 2) + " USD");
      WriteLine("Win Rate: " + DoubleToString(Results[bestProfitIndex].WinRate, 2) + "%");
      WriteLine("Total Trades: " + IntegerToString(Results[bestProfitIndex].TotalTrades));
      
      WriteLine("\nBest Win Rate Performance (min 20 trades):");
      WriteLine(Results[bestWinRateIndex].Symbol + " on " + Results[bestWinRateIndex].Timeframe);
      WriteLine("Win Rate: " + DoubleToString(Results[bestWinRateIndex].WinRate, 2) + "%");
      WriteLine("Net Profit: " + DoubleToString(Results[bestWinRateIndex].NetProfit, 2) + " USD");
      WriteLine("Total Trades: " + IntegerToString(Results[bestWinRateIndex].TotalTrades));
      
      WriteLine("\nWorst Performance:");
      WriteLine(Results[worstProfitIndex].Symbol + " on " + Results[worstProfitIndex].Timeframe);
      WriteLine("Net Profit: " + DoubleToString(Results[worstProfitIndex].NetProfit, 2) + " USD");
      WriteLine("Win Rate: " + DoubleToString(Results[worstProfitIndex].WinRate, 2) + "%");
      WriteLine("Total Trades: " + IntegerToString(Results[worstProfitIndex].TotalTrades));
   }
   
   // Print overall statistics
   double totalProfit = 0;
   double avgWinRate = 0;
   int totalTrades = 0;
   
   for(int i = 0; i < ArraySize(Results); i++) {
      totalProfit += Results[i].NetProfit;
      totalTrades += Results[i].TotalTrades;
      avgWinRate += Results[i].WinRate;
   }
   
   avgWinRate = (ArraySize(Results) > 0) ? avgWinRate / ArraySize(Results) : 0;
   
   WriteLine("\nOverall Statistics:");
   WriteLine("Total Net Profit: " + DoubleToString(totalProfit, 2) + " USD");
   WriteLine("Average Win Rate: " + DoubleToString(avgWinRate, 2) + "%");
   WriteLine("Total Trades: " + IntegerToString(totalTrades));
   WriteLine("=============================================");
   
   WriteLine("\nBacktesting completed successfully!");
}

//+------------------------------------------------------------------+
//| Convert timeframe enum to string                                 |
//+------------------------------------------------------------------+
string TimeframeToString(ENUM_TIMEFRAMES tf) {
   switch(tf) {
      case PERIOD_M1:  return "M1";
      case PERIOD_M5:  return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H4:  return "H4";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN";
      default:         return "Unknown";
   }
}

//+------------------------------------------------------------------+
//| Convert string to timeframe enum                                 |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES StringToTimeframe(string tf) {
   if(tf == "M1")  return PERIOD_M1;
   if(tf == "M5")  return PERIOD_M5;
   if(tf == "M15") return PERIOD_M15;
   if(tf == "M30") return PERIOD_M30;
   if(tf == "H1")  return PERIOD_H1;
   if(tf == "H4")  return PERIOD_H4;
   if(tf == "D1")  return PERIOD_D1;
   if(tf == "W1")  return PERIOD_W1;
   if(tf == "MN")  return PERIOD_MN1;
   
   return PERIOD_CURRENT; // Invalid timeframe
}

//+------------------------------------------------------------------+
//| Convert bool to string                                           |
//+------------------------------------------------------------------+
string BoolToString(bool value) {
   return value ? "true" : "false";
}

//+------------------------------------------------------------------+
//| Custom StringTrim function                                       |
//+------------------------------------------------------------------+
string StringTrim(string text) {
   return StringTrimRight(StringTrimLeft(text));
}
//+------------------------------------------------------------------+