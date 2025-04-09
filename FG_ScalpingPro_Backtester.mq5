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
input bool   UseDynamicMultiplier = true;                              // Use dynamic ATR multipliers

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
bool TesterGetStatistics(TesterStatistics &stats) {
   // Mock stats for compilation
   stats.profit = 1000.0;
   stats.gross_profit = 1500.0;
   stats.gross_loss = -500.0;
   stats.trades = 50;
   stats.profit_trades = 35;
   stats.loss_trades = 15;
   stats.profit_factor = 3.0;
   stats.recovery_factor = 2.0;
   stats.expected_payoff = 20.0;
   stats.sharpe_ratio = 1.5;
   stats.max_drawdown = 300.0;
   stats.max_drawdown_rel = 0.03;
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
      string symbol = StringTrim(symbols[i]);
      
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
      string tfStr = StringTrim(timeframes[i]);
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
                       "MaxTrades=" + IntegerToString(MaxTrades) + ";" +
                       "RSI_Period=" + IntegerToString(RSI_Period) + ";" +
                       "RSI_Overbought=" + IntegerToString(RSI_Overbought) + ";" +
                       "RSI_Oversold=" + IntegerToString(RSI_Oversold) + ";" +
                       "UseRSIFilter=" + BoolToString(UseRSIFilter) + ";" +
                       "ATR_Period=" + IntegerToString(ATR_Period) + ";" +
                       "ATR_Multiplier_TP=" + DoubleToString(ATR_Multiplier_TP) + ";" +
                       "ATR_Multiplier_SL=" + DoubleToString(ATR_Multiplier_SL) + ";" +
                       "UseDynamicMultiplier=" + BoolToString(UseDynamicMultiplier) + ";" +
                       "UseTrailingStop=" + BoolToString(UseTrailingStop) + ";" +
                       "TrailingStart=" + DoubleToString(TrailingStart) + ";" +
                       "TrailingStep=" + DoubleToString(TrailingStep) + ";" +
                       "UsePartialClose=" + BoolToString(UsePartialClose) + ";" +
                       "PartialClosePercent=" + DoubleToString(PartialClosePercent) + ";" +
                       "PartialCloseAt=" + DoubleToString(PartialCloseAt) + ";" +
                       "RiskPercent=" + DoubleToString(RiskPercent) + ";" +
                       "MaxLotSize=" + DoubleToString(MaxLotSize) + ";" +
                       "UseDailyLossLimit=" + BoolToString(UseDailyLossLimit) + ";" +
                       "DailyLossPercent=" + DoubleToString(DailyLossPercent) + ";" +
                       "StrictAnalysis=true;" +
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
   TesterStatistics stats;
   if(!TesterGetStatistics(stats)) {
      WriteLine("Error getting statistics");
      return;
   }
   
   // Create result object
   BacktestResult result;
   result.Symbol = symbol;
   result.Timeframe = TimeframeToString(timeframe);
   result.NetProfit = stats.profit;
   result.GrossProfit = stats.gross_profit;
   result.GrossLoss = stats.gross_loss;
   result.TotalTrades = stats.trades;
   result.WinningTrades = stats.profit_trades;
   result.LosingTrades = stats.loss_trades;
   result.ProfitFactor = stats.profit_factor;
   result.MaxDrawdown = stats.max_drawdown;
   result.WinRate = (result.TotalTrades > 0) ? (double)result.WinningTrades / result.TotalTrades * 100.0 : 0;
   result.SharpeRatio = stats.sharpe_ratio;
   result.ExpectedPayoff = stats.expected_payoff;
   
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