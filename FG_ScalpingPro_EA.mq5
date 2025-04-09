//+------------------------------------------------------------------+
//|                                            FG_ScalpingPro_EA.mq5 |
//|                       Copyright 2025, FGCompany Original Trading |
//|                                     Developed by Faiz Nasir      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, FGCompany Original Trading"
#property link      "https://www.fgtrading.com"
#property version   "1.30"
#property strict
#property description "FG ScalpingPro EA - High Probability Trading System"

// Include necessary libraries
#include <Trade\Trade.mqh>
#include <Arrays\ArrayObj.mqh>

// Enumeration for trading direction
enum ENUM_TRADE_SIGNAL {
   SIGNAL_NONE,    // No signal
   SIGNAL_BUY,     // Buy signal
   SIGNAL_SELL     // Sell signal
};

// Input parameters - General settings
input string GeneralSection = "===== General Settings ====="; // General Settings
input bool   EnableTrading = true;                // Enable automatic trading
input int    MagicNumber = 123456;               // Magic number
input string TradeComment = "FG_ScalpingPro";    // Trade comment

// Custom trading settings
input string CustomSettings = "===== Custom Trading Settings ====="; // Custom Trading Settings
input int    MaxTrades = 5;                      // Maximum number of concurrent trades
input bool   UseFixedLot = true;                 // Use fixed lot size
input double FixedLotSize = 0.01;                // Fixed lot size value
input int    MinTradeHoldingTime = 15;           // Minimum trade holding time (minutes)
input int    MaxTradeHoldingTime = 60;           // Maximum trade holding time (minutes)
input bool   StrictAnalysis = true;              // Stricter entry conditions for higher win rate

// Notification settings
input string NotificationSettings = "===== Notification Settings ====="; // Notification Settings
input bool   EnableAlerts = true;                // Enable pop-up alerts
input bool   EnablePushNotifications = false;    // Enable push notifications to mobile
input bool   EnableEmailAlerts = false;          // Enable email alerts
input bool   EnableDashboard = true;             // Enable visual dashboard
input int    DashboardX = 160;                   // Dashboard X position (centered)
input int    DashboardY = 5;                     // Dashboard Y position (higher)
input int    DashboardFontSize = 10;             // Dashboard font size
input color  DashboardTextColor = clrWhite;      // Dashboard text color
input color  DashboardBgColor = C'0,0,0';        // Dashboard background color (dark black)
input int    PreTradeAlertThreshold = 70;        // Alert threshold (0-100) for pre-trade notifications

// Indicator parameters 
input string BBSettings = "===== Bollinger Bands Settings ====="; // Bollinger Bands Settings
input int    BB_Period = 20;                     // Bollinger Bands period
input double BB_Deviation = 2.5;                 // Bollinger Bands deviation
input int    BB_Shift = 0;                       // Bollinger Bands shift

// Moving Average parameters
input string MASettings = "===== Moving Average Settings ====="; // Moving Average Settings  
input int    EMA_Fast_Period = 9;                // Fast EMA period
input int    EMA_Slow_Period = 21;               // Slow EMA period

// RSI parameters
input string RSISettings = "===== RSI Settings ====="; // RSI Settings
input int    RSI_Period = 14;                    // RSI period
input int    RSI_Overbought = 70;                // RSI overbought level
input int    RSI_Oversold = 30;                  // RSI oversold level
input bool   UseRSIFilter = true;                // Use RSI for signal filtering

// ATR parameters
input string ATRSettings = "===== ATR Settings ====="; // ATR Settings
input int    ATR_Period = 14;                    // ATR period
input double ATR_Multiplier_TP = 1.5;            // ATR multiplier for TP
input double ATR_Multiplier_SL = 1.0;            // ATR multiplier for SL
input int    ATR_MinValue = 15;                  // Minimum ATR value in points to trade
input bool   UseDynamicMultiplier = true;        // Use dynamic ATR multipliers based on market phase

// Exit optimization parameters
input string ExitSettings = "===== Exit Optimization ====="; // Exit Optimization
input bool   UseTrailingStop = true;             // Use trailing stop
input double TrailingStart = 0.5;                // Start trailing after this portion of TP reached (0.5 = 50%)
input double TrailingStep = 5.0;                 // Trailing step in points
input bool   UsePartialClose = true;             // Use partial position closing
input double PartialClosePercent = 50.0;         // Percentage to close at first target (%)
input double PartialCloseAt = 0.5;               // Close partial position after this portion of TP reached (0.5 = 50%)

// Volume filter parameters
input string VolumeSettings = "===== Volume Filter Settings ====="; // Volume Filter Settings
input int    Volume_Period = 20;                 // Volume SMA period
input bool   EnableVolumeFilter = true;          // Enable volume filter

// Time filter parameters
input string TimeSettings = "===== Time Filter Settings ====="; // Time Filter Settings
input bool   EnableTimeFilter = true;            // Enable time filter
input int    StartHour = 8;                      // Start hour (EST)
input int    EndHour = 12;                       // End hour (EST)
input bool   MondayFilter = true;                // Trade on Monday
input bool   TuesdayFilter = true;               // Trade on Tuesday
input bool   WednesdayFilter = true;             // Trade on Wednesday
input bool   ThursdayFilter = true;              // Trade on Thursday
input bool   FridayFilter = true;                // Trade on Friday

// News filter parameters
input string NewsSettings = "===== News Filter Settings ====="; // News Filter Settings
input bool   EnableNewsFilter = true;            // Enable news filter
input int    NewsBeforeMinutes = 30;             // Minutes before news release
input int    NewsAfterMinutes = 30;              // Minutes after news release

// Risk management
input string RiskSettings = "===== Risk Management ====="; // Risk Management Settings
input double RiskPercent = 1.0;                  // Risk percent per trade
input bool   UseFixedLotSize = false;            // Use fixed lot size instead of risk percent
input double MaxLotSize = 0.05;                  // Maximum lot size
input bool   UseDailyLossLimit = true;           // Use daily loss limit
input double DailyLossPercent = 5.0;             // Daily loss limit in percent of balance

// Currency pair-specific settings
input string PairSettings = "===== Pair-Specific Settings ====="; // Pair-Specific Settings
input bool   EnablePairSettings = true;          // Enable pair-specific settings
input string EURUSD_Settings = "TP:15, ATR:1.5"; // EURUSD settings
input string GBPUSD_Settings = "TP:20, ATR:1.3"; // GBPUSD settings
input string USDJPY_Settings = "TP:18, ATR:1.2"; // USDJPY settings
input string AUDUSD_Settings = "TP:16, ATR:1.4"; // AUDUSD settings

// Global variables
CTrade Trade;                                     // Trading object
double BB_Upper[], BB_Middle[], BB_Lower[];       // Bollinger Bands buffers
double EMA_Fast[], EMA_Slow[];                    // EMA buffers
double ATR_Buffer[];                              // ATR buffer
double RSI_Buffer[];                              // RSI buffer
long Volume_Buffer[];                             // Volume buffer as long type
double Volume_SMA;                                // Volume SMA value
MqlDateTime dt_struct;                            // Date-time structure
double InitialBalance;                            // Initial account balance
double DailyStartBalance;                         // Daily starting balance
datetime DailyResetTime;                          // Time to reset daily stats
double Close[];                                   // Close prices array
ENUM_TRADE_SIGNAL CurrentSignal = SIGNAL_NONE;    // Current trade signal
int CurrentProbability = 0;                       // Current trade probability (0-100)
datetime LastAlertTime = 0;                       // Time of the last alert
int SignalTimer = 0;                              // Timer for signal duration

// Dashboard object names
string DashboardBackground = "FG_Dashboard_BG";
string DashboardTitle = "FG_Dashboard_Title";
string DashboardSignal = "FG_Dashboard_Signal";
string DashboardPhase = "FG_Dashboard_Phase";
string DashboardProbability = "FG_Dashboard_Probability";
string DashboardRSI = "FG_Dashboard_RSI";
string DashboardATR = "FG_Dashboard_ATR";

// Trade tracking variables
struct TradeInfo {
   ulong ticket;                                 // Trade ticket number
   datetime openTime;                            // Trade open time
   ENUM_POSITION_TYPE type;                      // Trade type (buy/sell)
   double openPrice;                             // Open price
   double lots;                                  // Position size
   double tp;                                    // Take profit level
   double sl;                                    // Stop loss level
   bool partialClosed;                           // Flag if position was partially closed
};

TradeInfo ActiveTrades[];                        // Array to store active trade information

// Indicator handles
int BB_Handle;
int EMA_Fast_Handle;
int EMA_Slow_Handle;
int ATR_Handle;
int RSI_Handle;

// Market phase tracking
enum ENUM_MARKET_PHASE {
   PHASE_UNKNOWN,   // Unknown market phase
   PHASE_UPTREND,   // Uptrend (bullish) market
   PHASE_DOWNTREND, // Downtrend (bearish) market
   PHASE_RANGING,   // Ranging market
   PHASE_VOLATILE   // Volatile market
};

ENUM_MARKET_PHASE CurrentMarketPhase = PHASE_UNKNOWN;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   // Set magic number and trading settings
   Trade.SetExpertMagicNumber(MagicNumber);
   Trade.SetMarginMode();
   Trade.SetTypeFillingBySymbol(_Symbol);
   
   // Initialize indicator handles
   BB_Handle = iBands(_Symbol, PERIOD_CURRENT, BB_Period, BB_Shift, BB_Deviation, PRICE_CLOSE);
   EMA_Fast_Handle = iMA(_Symbol, PERIOD_CURRENT, EMA_Fast_Period, 0, MODE_EMA, PRICE_CLOSE);
   EMA_Slow_Handle = iMA(_Symbol, PERIOD_CURRENT, EMA_Slow_Period, 0, MODE_EMA, PRICE_CLOSE);
   ATR_Handle = iATR(_Symbol, PERIOD_CURRENT, ATR_Period);
   RSI_Handle = iRSI(_Symbol, PERIOD_CURRENT, RSI_Period, PRICE_CLOSE);
   
   // Check if indicators are created successfully
   if(BB_Handle == INVALID_HANDLE || EMA_Fast_Handle == INVALID_HANDLE || 
      EMA_Slow_Handle == INVALID_HANDLE || ATR_Handle == INVALID_HANDLE ||
      RSI_Handle == INVALID_HANDLE) {
      Print("Error creating indicators: ", GetLastError());
      return INIT_FAILED;
   }
   
   // Initialize arrays for indicator data
   ArraySetAsSeries(BB_Upper, true);
   ArraySetAsSeries(BB_Middle, true);
   ArraySetAsSeries(BB_Lower, true);
   ArraySetAsSeries(EMA_Fast, true);
   ArraySetAsSeries(EMA_Slow, true);
   ArraySetAsSeries(ATR_Buffer, true);
   ArraySetAsSeries(RSI_Buffer, true);
   ArraySetAsSeries(Volume_Buffer, true);
   ArraySetAsSeries(Close, true);
   
   // Initialize active trades array
   ArrayResize(ActiveTrades, 0);
   
   // Initialize balance tracking
   InitialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   ResetDailyStats();
   
   // Load existing positions
   LoadExistingPositions();
   
   // Create dashboard if enabled
   if(EnableDashboard) {
      CreateDashboard();
   }
   
   Print("FG ScalpingPro EA v1.30 initialized successfully");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   // Release indicator handles
   IndicatorRelease(BB_Handle);
   IndicatorRelease(EMA_Fast_Handle);
   IndicatorRelease(EMA_Slow_Handle);
   IndicatorRelease(ATR_Handle);
   IndicatorRelease(RSI_Handle);
   
   // Remove dashboard objects
   if(EnableDashboard) {
      DeleteDashboard();
   }
   
   Print("FG ScalpingPro EA removed");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   // Skip if automatic trading is disabled
   if(!EnableTrading) return;
   
   // Update indicator data - add detailed error checking
   if(!UpdateIndicators()) {
      Print("ERROR: Failed to update indicators, check buffers");
      // Update dashboard anyway with what we have
      if(EnableDashboard) {
         UpdateDashboard();
      }
      return;
   }
   
   // Update and manage existing positions first
   UpdateActiveTrades();
   ManagePositions();
   
   // Check for new signals and calculate probability on EVERY tick
   ENUM_TRADE_SIGNAL newSignal = GetTradeSignal();
   
   // Always calculate probability on each tick for real-time updates
   CurrentProbability = CalculateTradeProbability(newSignal);
   
   // Debug print to verify calculation
   Print("DEBUG: Current Probability = ", CurrentProbability, 
         "%, Signal = ", SignalToString(newSignal), 
         ", RSI = ", DoubleToString(RSI_Buffer[0], 1),
         ", ATR = ", DoubleToString(ATR_Buffer[0], 5),
         ", EMA_Fast = ", DoubleToString(EMA_Fast[0], 5),
         ", EMA_Slow = ", DoubleToString(EMA_Slow[0], 5));
   
   // If signal changed, reset the timer
   if(newSignal != CurrentSignal) {
      SignalTimer = 0;
   }
   else {
      SignalTimer++; // Increase timer when signal persists
   }
   
   // Update current signal
   CurrentSignal = newSignal;
   
   // Update dashboard if enabled - ensure it's always updated every tick
   if(EnableDashboard) {
      UpdateDashboard();
   }
   
   // Send pre-trade alert if probability is high
   if(CurrentSignal != SIGNAL_NONE && CurrentProbability >= PreTradeAlertThreshold) {
      // Only alert once every 5 minutes for the same signal
      if(TimeCurrent() - LastAlertTime > 300) {
         SendPreTradeAlert();
         LastAlertTime = TimeCurrent();
      }
   }
   
   // Check if we can open new trades
   int currentTrades = ArraySize(ActiveTrades);
   if(currentTrades < MaxTrades) {
      // Execute trades based on signals if they pass filters
      if(CurrentSignal != SIGNAL_NONE && CheckFilters()) {
         ExecuteTrade(CurrentSignal);
      }
   }
}

// Helper function to convert signal to string for debugging
string SignalToString(ENUM_TRADE_SIGNAL signal) {
   switch(signal) {
      case SIGNAL_BUY: return "BUY";
      case SIGNAL_SELL: return "SELL";
      default: return "NONE";
   }
}

//+------------------------------------------------------------------+
//| Load existing positions on initialization                        |
//+------------------------------------------------------------------+
void LoadExistingPositions() {
   for(int i = 0; i < PositionsTotal(); i++) {
      ulong ticket = PositionGetTicket(i);
      
      if(ticket <= 0) continue;
      
      // Select the position
      if(PositionSelectByTicket(ticket)) {
         // Check if it belongs to our EA
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber && 
            PositionGetString(POSITION_SYMBOL) == _Symbol) {
            
            int idx = ArraySize(ActiveTrades);
            ArrayResize(ActiveTrades, idx + 1);
            
            ActiveTrades[idx].ticket = ticket;
            ActiveTrades[idx].openTime = (datetime)PositionGetInteger(POSITION_TIME);
            ActiveTrades[idx].type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            ActiveTrades[idx].openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            ActiveTrades[idx].lots = PositionGetDouble(POSITION_VOLUME);
            ActiveTrades[idx].tp = PositionGetDouble(POSITION_TP);
            ActiveTrades[idx].sl = PositionGetDouble(POSITION_SL);
            ActiveTrades[idx].partialClosed = false; // Assume not partially closed on initialization
            
            Print("Loaded existing position #", ticket);
         }
      }
   }
   
   Print("Total active trades loaded: ", ArraySize(ActiveTrades));
}

//+------------------------------------------------------------------+
//| Update active trades array                                      |
//+------------------------------------------------------------------+
void UpdateActiveTrades() {
   // Check if positions are still open, remove closed ones
   for(int i = ArraySize(ActiveTrades) - 1; i >= 0; i--) {
      bool positionExists = false;
      
      // Check if the position still exists
      if(PositionSelectByTicket(ActiveTrades[i].ticket)) {
         positionExists = true;
      }
      
      // If position doesn't exist anymore, remove from array
      if(!positionExists) {
         // Remove the element by shifting all elements after it
         for(int j = i; j < ArraySize(ActiveTrades) - 1; j++) {
            ActiveTrades[j] = ActiveTrades[j + 1];
         }
         
         // Resize the array
         ArrayResize(ActiveTrades, ArraySize(ActiveTrades) - 1);
      }
   }
}

//+------------------------------------------------------------------+
//| Update all indicator values                                      |
//+------------------------------------------------------------------+
bool UpdateIndicators() {
   // Initialize Close prices first
   if(CopyClose(_Symbol, PERIOD_CURRENT, 0, 10, Close) <= 0) {
      Print("Error copying close price data: ", GetLastError());
      return false;
   }
   
   // Use larger buffer size for indicators (10 instead of 3)
   // This prevents zeros when history isn't fully loaded
   
   // Copy BB indicator data with error checking
   int bb_copied = CopyBuffer(BB_Handle, 0, 0, 10, BB_Upper);
   if(bb_copied <= 0) {
      Print("Error copying BB Upper buffer: ", GetLastError());
      return false;
   }
   
   bb_copied = CopyBuffer(BB_Handle, 1, 0, 10, BB_Middle);
   if(bb_copied <= 0) {
      Print("Error copying BB Middle buffer: ", GetLastError());
      return false;
   }
   
   bb_copied = CopyBuffer(BB_Handle, 2, 0, 10, BB_Lower);
   if(bb_copied <= 0) {
      Print("Error copying BB Lower buffer: ", GetLastError());
      return false;
   }
   
   // Copy EMA indicator data with error checking
   int ema_copied = CopyBuffer(EMA_Fast_Handle, 0, 0, 10, EMA_Fast);
   if(ema_copied <= 0) {
      Print("Error copying EMA Fast buffer: ", GetLastError());
      return false;
   }
   
   ema_copied = CopyBuffer(EMA_Slow_Handle, 0, 0, 10, EMA_Slow);
   if(ema_copied <= 0) {
      Print("Error copying EMA Slow buffer: ", GetLastError());
      return false;
   }
   
   // Copy ATR indicator data with error checking
   int atr_copied = CopyBuffer(ATR_Handle, 0, 0, 10, ATR_Buffer);
   if(atr_copied <= 0) {
      Print("Error copying ATR buffer: ", GetLastError());
      return false;
   }
   
   // Copy RSI indicator data with error checking
   int rsi_copied = CopyBuffer(RSI_Handle, 0, 0, 10, RSI_Buffer);
   if(rsi_copied <= 0) {
      Print("Error copying RSI buffer: ", GetLastError());
      return false;
   }
   
   // Get volume data
   int vol_copied = CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, Volume_Period + 10, Volume_Buffer);
   if(vol_copied <= 0) {
      Print("Error copying Volume buffer: ", GetLastError());
      return false;
   }
   
   // Verify that buffer elements aren't zero
   if(ATR_Buffer[0] == 0 || RSI_Buffer[0] == 0) {
      Print("Warning: Indicator returned zero values: ATR=", ATR_Buffer[0], ", RSI=", RSI_Buffer[0]);
      // Don't return false here, we'll use whatever we have
   }
   
   // Calculate Volume SMA
   long volumeSum = 0;
   for(int i = 1; i <= Volume_Period && i < vol_copied; i++) {
      volumeSum += Volume_Buffer[i];
   }
   Volume_SMA = (double)volumeSum / Volume_Period;
   
   // Detect market phase
   DetectMarketPhase();
   
   // Check for daily reset
   CheckDailyReset();
   
   return true;
}

//+------------------------------------------------------------------+
//| Detect current market phase                                      |
//+------------------------------------------------------------------+
void DetectMarketPhase() {
   // Get Bollinger Band width (volatility indicator)
   double bbWidth = (BB_Upper[0] - BB_Lower[0]) / BB_Middle[0];
   
   // Calculate trend strength with direction
   double trendStrength = (EMA_Fast[0] - EMA_Slow[0]) / ATR_Buffer[0];
   
   // Get ATR change to detect volatility changes
   double atrChange = (ATR_Buffer[0] - ATR_Buffer[2]) / ATR_Buffer[2];
   
   // Determine market phase
   if(MathAbs(trendStrength) > 0.5) {
      if(trendStrength > 0) {
         CurrentMarketPhase = PHASE_UPTREND;  // Positive trend strength = uptrend
      } else {
         CurrentMarketPhase = PHASE_DOWNTREND; // Negative trend strength = downtrend
      }
   }
   else if(bbWidth < 0.015) {
      CurrentMarketPhase = PHASE_RANGING;
   }
   else if(atrChange > 0.2) {
      CurrentMarketPhase = PHASE_VOLATILE;
   }
   else {
      CurrentMarketPhase = PHASE_UNKNOWN;
   }
   
   // Debug output to verify market phase detection
   Print("DEBUG: Market Phase Detection - EMA_Fast:", EMA_Fast[0], 
         " EMA_Slow:", EMA_Slow[0], 
         " TrendStrength:", trendStrength, 
         " BBWidth:", bbWidth, 
         " ATRChange:", atrChange, 
         " Phase:", MarketPhaseToString(CurrentMarketPhase));
}

//+------------------------------------------------------------------+
//| Reset daily statistics                                           |
//+------------------------------------------------------------------+
void ResetDailyStats() {
   DailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   // Set reset time to next day at 00:00
   MqlDateTime current_time;
   TimeToStruct(TimeCurrent(), current_time);
   
   current_time.hour = 0;
   current_time.min = 0;
   current_time.sec = 0;
   
   // Set to next day
   DailyResetTime = StructToTime(current_time) + 86400; // Add 24 hours
}

//+------------------------------------------------------------------+
//| Check if daily stats should be reset                             |
//+------------------------------------------------------------------+
void CheckDailyReset() {
   if(TimeCurrent() >= DailyResetTime) {
      ResetDailyStats();
   }
}

//+------------------------------------------------------------------+
//| Check if daily loss limit is reached                             |
//+------------------------------------------------------------------+
bool IsDailyLossLimitReached() {
   if(!UseDailyLossLimit) return false;
   
   double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double dailyLoss = DailyStartBalance - currentBalance;
   double dailyLossPercent = (dailyLoss / DailyStartBalance) * 100.0;
   
   return dailyLossPercent >= DailyLossPercent;
}

//+------------------------------------------------------------------+
//| Check filters before trading                                     |
//+------------------------------------------------------------------+
bool CheckFilters() {
   // Check volatility filter (ATR)
   double atr_points = ATR_Buffer[0] * _Point;
   if(atr_points < ATR_MinValue * _Point) {
      Print("Low volatility: ATR = ", atr_points, " points, minimum required = ", ATR_MinValue * _Point);
      return false;
   }
   
   // Check volume filter
   if(EnableVolumeFilter && Volume_Buffer[0] <= Volume_SMA) {
      Print("Volume too low: Current = ", Volume_Buffer[0], ", Average = ", Volume_SMA);
      return false;
   }
   
   // Check time filter
   if(EnableTimeFilter) {
      TimeToStruct(TimeCurrent(), dt_struct);
      
      // Check day of week filter
      if((dt_struct.day_of_week == 1 && !MondayFilter) ||
         (dt_struct.day_of_week == 2 && !TuesdayFilter) ||
         (dt_struct.day_of_week == 3 && !WednesdayFilter) ||
         (dt_struct.day_of_week == 4 && !ThursdayFilter) ||
         (dt_struct.day_of_week == 5 && !FridayFilter)) {
         return false;
      }
      
      // Check trading hours (EST time)
      int current_hour = dt_struct.hour;
      if(current_hour < StartHour || current_hour >= EndHour) {
         return false;
      }
   }
   
   // Check news filter
   if(EnableNewsFilter && IsHighImpactNews()) {
      Print("High impact news period - trading paused");
      return false;
   }
   
   // Add RSI filter
   if(UseRSIFilter) {
      // For buy signals: ensure RSI is not overbought and preferably coming from oversold
      if(CurrentSignal == SIGNAL_BUY && RSI_Buffer[0] > RSI_Overbought) {
         return false;
      }
      
      // For sell signals: ensure RSI is not oversold and preferably coming from overbought
      if(CurrentSignal == SIGNAL_SELL && RSI_Buffer[0] < RSI_Oversold) {
         return false;
      }
   }
   
   // Check daily loss limit
   if(IsDailyLossLimitReached()) {
      Print("Daily loss limit of ", DailyLossPercent, "% reached. No new trades allowed today.");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check for high impact news                                       |
//+------------------------------------------------------------------+
bool IsHighImpactNews() {
   // Note: This is a placeholder function. In a real implementation,
   // you would connect to a news API or use a custom news calendar.
   // For demonstration purposes, we'll just return false.
   return false;
}

//+------------------------------------------------------------------+
//| Get trading signal                                                |
//+------------------------------------------------------------------+
ENUM_TRADE_SIGNAL GetTradeSignal() {
   // Default to no signal
   ENUM_TRADE_SIGNAL signal = SIGNAL_NONE;
   
   // Check for buy signal
   if(EMA_Fast[0] > EMA_Slow[0] && // Bullish trend
      Close[0] > EMA_Fast[0] &&    // Price above Fast EMA 
      (Close[1] <= EMA_Fast[1] || Close[2] <= EMA_Fast[2]) && // Recent cross or touch of EMA
      RSI_Buffer[0] > RSI_Buffer[1] && // RSI momentum up
      (RSI_Buffer[1] < RSI_Oversold || RSI_Buffer[2] < RSI_Oversold)) { // Coming from oversold
      
      signal = SIGNAL_BUY;
   }
   // Check for sell signal
   else if(EMA_Fast[0] < EMA_Slow[0] && // Bearish trend
           Close[0] < EMA_Fast[0] &&    // Price below Fast EMA
           (Close[1] >= EMA_Fast[1] || Close[2] >= EMA_Fast[2]) && // Recent cross or touch of EMA
           RSI_Buffer[0] < RSI_Buffer[1] && // RSI momentum down
           (RSI_Buffer[1] > RSI_Overbought || RSI_Buffer[2] > RSI_Overbought)) { // Coming from overbought
      
      signal = SIGNAL_SELL;
   }
   
   return signal;
}

//+------------------------------------------------------------------+
//| Calculate trade probability based on indicator readings          |
//+------------------------------------------------------------------+
int CalculateTradeProbability(ENUM_TRADE_SIGNAL signal) {
   int probability = 0;
   
   // Force a minimum base probability for debugging
   probability = 5;
   
   // Even if no signal, calculate a probability based on market conditions
   if(signal == SIGNAL_NONE) {
      // Check if close to generating a signal
      bool potentialBuy = (EMA_Fast[0] > EMA_Slow[0] && Close[0] > EMA_Fast[0]);
      bool potentialSell = (EMA_Fast[0] < EMA_Slow[0] && Close[0] < EMA_Fast[0]);
      
      if(potentialBuy || potentialSell) {
         probability = 20; // Base probability for potential signal
      }
   } else {
      // Base score - having a valid signal gives 40 points
      probability = 40;
   }
   
   // Add points based on trend strength
   double emaSeparation = MathAbs(EMA_Fast[0] - EMA_Slow[0]) / ATR_Buffer[0];
   int trendPoints = (int)MathMin(emaSeparation * 50, 20);
   probability += trendPoints;
   
   // Add points based on RSI strength
   if(signal == SIGNAL_BUY || (signal == SIGNAL_NONE && EMA_Fast[0] > EMA_Slow[0])) {
      // For buy, better if RSI was recently oversold and now rising
      if(RSI_Buffer[1] < RSI_Oversold || RSI_Buffer[2] < RSI_Oversold) {
         probability += 15;
      }
      
      // Strength of RSI momentum
      double rsiMomentum = RSI_Buffer[0] - RSI_Buffer[1];
      probability += (int)MathMin(rsiMomentum * 2, 10);
   }
   else if(signal == SIGNAL_SELL || (signal == SIGNAL_NONE && EMA_Fast[0] < EMA_Slow[0])) {
      // For sell, better if RSI was recently overbought and now falling
      if(RSI_Buffer[1] > RSI_Overbought || RSI_Buffer[2] > RSI_Overbought) {
         probability += 15;
      }
      
      // Strength of RSI momentum
      double rsiMomentum = RSI_Buffer[1] - RSI_Buffer[0];
      probability += (int)MathMin(rsiMomentum * 2, 10);
   }
   
   // Add points based on volume strength
   double volumeRatio = (double)Volume_Buffer[0] / Volume_SMA;
   int volumePoints = (int)MathMin((volumeRatio - 1.0) * 30, 15);
   if(volumePoints > 0) probability += volumePoints;
   
   // Add points if signal persists (stability factor)
   probability += (int)MathMin(SignalTimer, 10);
   
   // Market condition factor - updated for more specific market phases
   switch(CurrentMarketPhase) {
      case PHASE_UPTREND:
         // Higher probability for buy signals in uptrend
         if(signal == SIGNAL_BUY) probability += 10;
         else if(signal == SIGNAL_SELL) probability -= 5; // Counter-trend trade
         break;
      case PHASE_DOWNTREND:
         // Higher probability for sell signals in downtrend
         if(signal == SIGNAL_SELL) probability += 10;
         else if(signal == SIGNAL_BUY) probability -= 5; // Counter-trend trade
         break;
      case PHASE_RANGING:
         // Lower probability in ranging markets
         probability -= 5;
         break;
      case PHASE_VOLATILE:
         // Higher risk in volatile markets
         probability -= 3;
         break;
   }
   
   // Make sure probability is never below 5%
   probability = MathMax(probability, 5);
   
   // Cap at 100
   probability = MathMin(probability, 100);
   
   return probability;
}

//+------------------------------------------------------------------+
//| Create dashboard objects                                         |
//+------------------------------------------------------------------+
void CreateDashboard() {
   // Get chart width to center the dashboard
   int chartWidth = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int dashboardWidth = 200;  // Slightly smaller width
   
   // Calculate center position
   int centerX = (chartWidth / 2) - (dashboardWidth / 2);
   
   // Create background
   ObjectCreate(0, DashboardBackground, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, DashboardBackground, OBJPROP_XDISTANCE, centerX > 0 ? centerX : DashboardX);
   ObjectSetInteger(0, DashboardBackground, OBJPROP_YDISTANCE, DashboardY);
   ObjectSetInteger(0, DashboardBackground, OBJPROP_XSIZE, dashboardWidth);
   ObjectSetInteger(0, DashboardBackground, OBJPROP_YSIZE, 150); // Increased height to prevent overflow
   ObjectSetInteger(0, DashboardBackground, OBJPROP_COLOR, DashboardTextColor);
   ObjectSetInteger(0, DashboardBackground, OBJPROP_BGCOLOR, DashboardBgColor);
   ObjectSetInteger(0, DashboardBackground, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, DashboardBackground, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, DashboardBackground, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, DashboardBackground, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, DashboardBackground, OBJPROP_BACK, false);
   ObjectSetInteger(0, DashboardBackground, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, DashboardBackground, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, DashboardBackground, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, DashboardBackground, OBJPROP_ZORDER, 0);
   
   // Create title
   ObjectCreate(0, DashboardTitle, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, DashboardTitle, OBJPROP_XDISTANCE, centerX > 0 ? centerX + 10 : DashboardX + 10);
   ObjectSetInteger(0, DashboardTitle, OBJPROP_YDISTANCE, DashboardY + 10);
   ObjectSetInteger(0, DashboardTitle, OBJPROP_COLOR, DashboardTextColor);
   ObjectSetInteger(0, DashboardTitle, OBJPROP_FONTSIZE, DashboardFontSize);
   ObjectSetInteger(0, DashboardTitle, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, DashboardTitle, OBJPROP_FONT, "Arial Bold");
   ObjectSetString(0, DashboardTitle, OBJPROP_TEXT, "FG ScalpingPro v1.30");
   
   // Move probability up to top position (make it first element after title)
   ObjectCreate(0, DashboardProbability, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, DashboardProbability, OBJPROP_XDISTANCE, centerX > 0 ? centerX + 10 : DashboardX + 10);
   ObjectSetInteger(0, DashboardProbability, OBJPROP_YDISTANCE, DashboardY + 30);
   ObjectSetInteger(0, DashboardProbability, OBJPROP_COLOR, DashboardTextColor);
   ObjectSetInteger(0, DashboardProbability, OBJPROP_FONTSIZE, DashboardFontSize);
   ObjectSetInteger(0, DashboardProbability, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, DashboardProbability, OBJPROP_FONT, "Arial");
   ObjectSetString(0, DashboardProbability, OBJPROP_TEXT, "Trade Probability: 0%");
   
   // Create signal label (moved down)
   ObjectCreate(0, DashboardSignal, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, DashboardSignal, OBJPROP_XDISTANCE, centerX > 0 ? centerX + 10 : DashboardX + 10);
   ObjectSetInteger(0, DashboardSignal, OBJPROP_YDISTANCE, DashboardY + 50);
   ObjectSetInteger(0, DashboardSignal, OBJPROP_COLOR, DashboardTextColor);
   ObjectSetInteger(0, DashboardSignal, OBJPROP_FONTSIZE, DashboardFontSize);
   ObjectSetInteger(0, DashboardSignal, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, DashboardSignal, OBJPROP_FONT, "Arial");
   ObjectSetString(0, DashboardSignal, OBJPROP_TEXT, "Signal: MONITORING");
   
   // Create market phase label (moved down)
   ObjectCreate(0, DashboardPhase, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, DashboardPhase, OBJPROP_XDISTANCE, centerX > 0 ? centerX + 10 : DashboardX + 10);
   ObjectSetInteger(0, DashboardPhase, OBJPROP_YDISTANCE, DashboardY + 70);
   ObjectSetInteger(0, DashboardPhase, OBJPROP_COLOR, DashboardTextColor);
   ObjectSetInteger(0, DashboardPhase, OBJPROP_FONTSIZE, DashboardFontSize);
   ObjectSetInteger(0, DashboardPhase, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, DashboardPhase, OBJPROP_FONT, "Arial");
   ObjectSetString(0, DashboardPhase, OBJPROP_TEXT, "Market Phase: UNKNOWN");
   
   // Create RSI label (moved down)
   ObjectCreate(0, DashboardRSI, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, DashboardRSI, OBJPROP_XDISTANCE, centerX > 0 ? centerX + 10 : DashboardX + 10);
   ObjectSetInteger(0, DashboardRSI, OBJPROP_YDISTANCE, DashboardY + 90);
   ObjectSetInteger(0, DashboardRSI, OBJPROP_COLOR, DashboardTextColor);
   ObjectSetInteger(0, DashboardRSI, OBJPROP_FONTSIZE, DashboardFontSize);
   ObjectSetInteger(0, DashboardRSI, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, DashboardRSI, OBJPROP_FONT, "Arial");
   ObjectSetString(0, DashboardRSI, OBJPROP_TEXT, "RSI: 0.0");
   
   // Create ATR label (moved down with more room for overflow)
   ObjectCreate(0, DashboardATR, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, DashboardATR, OBJPROP_XDISTANCE, centerX > 0 ? centerX + 10 : DashboardX + 10);
   ObjectSetInteger(0, DashboardATR, OBJPROP_YDISTANCE, DashboardY + 110);
   ObjectSetInteger(0, DashboardATR, OBJPROP_COLOR, DashboardTextColor);
   ObjectSetInteger(0, DashboardATR, OBJPROP_FONTSIZE, DashboardFontSize);
   ObjectSetInteger(0, DashboardATR, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetString(0, DashboardATR, OBJPROP_FONT, "Arial");
   ObjectSetString(0, DashboardATR, OBJPROP_TEXT, "ATR: 0.0");
}

//+------------------------------------------------------------------+
//| Update dashboard with current information                        |
//+------------------------------------------------------------------+
void UpdateDashboard() {
   // Make sure we recalculate probability before updating dashboard
   // This ensures the most current value is displayed
   if(CurrentProbability <= 0) {
      CurrentProbability = CalculateTradeProbability(CurrentSignal);
   }

   // Update signal
   string signalText = "Signal: ";
   color signalColor = DashboardTextColor;
   
   switch(CurrentSignal) {
      case SIGNAL_BUY:
         signalText += "BUY";
         signalColor = clrLime;
         break;
      case SIGNAL_SELL:
         signalText += "SELL";
         signalColor = clrRed;
         break;
      default:
         signalText += "MONITORING";
         break;
   }
   
   ObjectSetString(0, DashboardSignal, OBJPROP_TEXT, signalText);
   ObjectSetInteger(0, DashboardSignal, OBJPROP_COLOR, signalColor);
   
   // Update market phase
   string phaseText = "Market Phase: ";
   color phaseColor = DashboardTextColor;
   
   switch(CurrentMarketPhase) {
      case PHASE_UPTREND:
         phaseText += "UPTREND";
         phaseColor = clrLime;
         break;
      case PHASE_DOWNTREND:
         phaseText += "DOWNTREND";
         phaseColor = clrRed;
         break;
      case PHASE_RANGING:
         phaseText += "RANGING";
         phaseColor = clrGold;
         break;
      case PHASE_VOLATILE:
         phaseText += "VOLATILE";
         phaseColor = clrMagenta;
         break;
      default:
         phaseText += "UNKNOWN";
         break;
   }
   
   ObjectSetString(0, DashboardPhase, OBJPROP_TEXT, phaseText);
   ObjectSetInteger(0, DashboardPhase, OBJPROP_COLOR, phaseColor);
   
   // Update probability - Debug directly to make sure value is correct
   string probText = "Trade Probability: " + IntegerToString(CurrentProbability) + "%";
   color probColor = DashboardTextColor;
   
   if(CurrentProbability >= 80) probColor = clrLime;
   else if(CurrentProbability >= 60) probColor = clrYellow;
   else if(CurrentProbability >= 40) probColor = clrOrange;
   else if(CurrentProbability >= 20) probColor = clrPink;
   else probColor = clrRed; // Low probability
   
   ObjectSetString(0, DashboardProbability, OBJPROP_TEXT, probText);
   ObjectSetInteger(0, DashboardProbability, OBJPROP_COLOR, probColor);
   
   // Update RSI - protect against invalid values
   double rsiValue = RSI_Buffer[0];
   if(rsiValue <= 0 || rsiValue > 100) {
      rsiValue = 50.0; // Use neutral value if invalid
      Print("Warning: Invalid RSI value, using default");
   }
   
   color rsiColor = DashboardTextColor;
   if(rsiValue > RSI_Overbought) rsiColor = clrRed;
   else if(rsiValue < RSI_Oversold) rsiColor = clrLime;
   
   ObjectSetString(0, DashboardRSI, OBJPROP_TEXT, "RSI: " + DoubleToString(rsiValue, 1));
   ObjectSetInteger(0, DashboardRSI, OBJPROP_COLOR, rsiColor);
   
   // Update ATR - protect against invalid values
   double atrValue = ATR_Buffer[0];
   if(atrValue <= 0) {
      atrValue = _Point * 10; // Use small default value if invalid
      Print("Warning: Invalid ATR value, using default");
   }
   
   double atrPoints = atrValue / _Point;
   color atrColor = DashboardTextColor;
   if(atrPoints > ATR_MinValue * 2) atrColor = clrRed; // High volatility
   else if(atrPoints < ATR_MinValue) atrColor = clrYellow; // Low volatility
   
   ObjectSetString(0, DashboardATR, OBJPROP_TEXT, "ATR: " + DoubleToString(atrPoints, 1) + " pts");
   ObjectSetInteger(0, DashboardATR, OBJPROP_COLOR, atrColor);
   
   // Force chart redraw
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Delete dashboard objects                                         |
//+------------------------------------------------------------------+
void DeleteDashboard() {
   ObjectDelete(0, DashboardBackground);
   ObjectDelete(0, DashboardTitle);
   ObjectDelete(0, DashboardSignal);
   ObjectDelete(0, DashboardPhase);
   ObjectDelete(0, DashboardProbability);
   ObjectDelete(0, DashboardRSI);
   ObjectDelete(0, DashboardATR);
}

//+------------------------------------------------------------------+
//| Send pre-trade alert with information about potential trade      |
//+------------------------------------------------------------------+
void SendPreTradeAlert() {
   if(!EnableAlerts && !EnablePushNotifications && !EnableEmailAlerts) return;
   
   string direction = (CurrentSignal == SIGNAL_BUY) ? "BUY" : "SELL";
   string message = "FG ScalpingPro: High probability " + direction + " signal forming\n" +
                   "Symbol: " + _Symbol + "\n" +
                   "Probability: " + IntegerToString(CurrentProbability) + "%\n" +
                   "Market Phase: " + MarketPhaseToString(CurrentMarketPhase) + "\n" +
                   "RSI: " + DoubleToString(RSI_Buffer[0], 1) + "\n" +
                   "Time: " + TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES);
   
   if(EnableAlerts) {
      Alert(message);
      PlaySound("alert.wav");
   }
   
   if(EnablePushNotifications) {
      SendNotification(message);
   }
   
   if(EnableEmailAlerts) {
      SendMail("FG ScalpingPro Pre-Trade Alert", message);
   }
}

//+------------------------------------------------------------------+
//| Convert market phase enum to string                             |
//+------------------------------------------------------------------+
string MarketPhaseToString(ENUM_MARKET_PHASE phase) {
   switch(phase) {
      case PHASE_UPTREND: return "UPTREND";
      case PHASE_DOWNTREND: return "DOWNTREND";
      case PHASE_RANGING: return "RANGING";
      case PHASE_VOLATILE: return "VOLATILE";
      default: return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| Execute trade based on signal                                    |
//+------------------------------------------------------------------+
void ExecuteTrade(ENUM_TRADE_SIGNAL signal) {
   // Get current symbol information
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   
   // Calculate ATR multiplier based on market phase
   double tpMultiplier = ATR_Multiplier_TP;
   double slMultiplier = ATR_Multiplier_SL;
   
   // Adjust multipliers based on market phase if enabled
   if(UseDynamicMultiplier) {
      switch(CurrentMarketPhase) {
         case PHASE_UPTREND:
            tpMultiplier *= 1.5; // Higher TP in uptrend
            break;
         case PHASE_DOWNTREND:
            tpMultiplier *= 0.8; // Lower TP in downtrend
            break;
         case PHASE_VOLATILE:
            slMultiplier *= 1.2; // Wider SL in volatile markets
            break;
      }
   }
   
   // Calculate TP and SL distances based on ATR
   double atrValue = ATR_Buffer[0];
   double tpDistance = atrValue * tpMultiplier;
   double slDistance = atrValue * slMultiplier;
   
   // Normalize TP and SL to account for minimum distance requirements
   tpDistance = MathMax(tpDistance, 10 * point);
   slDistance = MathMax(slDistance, 10 * point);
   
   // Round to tick size
   tpDistance = MathRound(tpDistance / tickSize) * tickSize;
   slDistance = MathRound(slDistance / tickSize) * tickSize;
   
   // Get pair-specific settings if enabled
   if(EnablePairSettings) {
      string pairSettings = "";
      string currentPair = _Symbol;
      
      // Match current pair with settings
      if(currentPair == "EURUSD") pairSettings = EURUSD_Settings;
      else if(currentPair == "GBPUSD") pairSettings = GBPUSD_Settings;
      else if(currentPair == "USDJPY") pairSettings = USDJPY_Settings;
      else if(currentPair == "AUDUSD") pairSettings = AUDUSD_Settings;
      
      // Parse settings if available
      if(pairSettings != "") {
         // Custom parsing of pair settings string
         string parts[];
         StringSplit(pairSettings, ',', parts);
         
         for(int i = 0; i < ArraySize(parts); i++) {
            string setting = parts[i];
            string keyValue[];
            StringSplit(setting, ':', keyValue);
            
            if(ArraySize(keyValue) == 2) {
               string key = keyValue[0];
               string value = keyValue[1];
               // Apply trim functions to the variables directly
               StringTrimLeft(key);
               StringTrimRight(key);
               StringTrimLeft(value);
               StringTrimRight(value);
               
               if(key == "TP") {
                  tpDistance = StringToDouble(value) * point;
               }
               else if(key == "ATR") {
                  tpMultiplier = StringToDouble(value);
                  tpDistance = atrValue * tpMultiplier;
               }
            }
         }
      }
   }
   
   // Calculate lot size
   double lotSize = CalculateLotSize(slDistance);
   
   // Execute trade based on signal
   if(signal == SIGNAL_BUY) {
      double tp = NormalizeDouble(ask + tpDistance, digits);
      double sl = NormalizeDouble(bid - slDistance, digits);
      
      if(Trade.Buy(lotSize, _Symbol, 0, sl, tp, TradeComment)) {
         // Add to active trades array
         int idx = ArraySize(ActiveTrades);
         ArrayResize(ActiveTrades, idx + 1);
         
         ActiveTrades[idx].ticket = Trade.ResultOrder();
         ActiveTrades[idx].openTime = TimeCurrent();
         ActiveTrades[idx].type = POSITION_TYPE_BUY;
         ActiveTrades[idx].openPrice = ask;
         ActiveTrades[idx].lots = lotSize;
         ActiveTrades[idx].tp = tp;
         ActiveTrades[idx].sl = sl;
         ActiveTrades[idx].partialClosed = false;
         
         Print("Buy position opened: Ticket #", Trade.ResultOrder(), 
               ", Lot Size: ", lotSize, 
               ", SL: ", sl, 
               ", TP: ", tp,
               ", ATR: ", DoubleToString(atrValue, 5),
               ", RSI: ", DoubleToString(RSI_Buffer[0], 2));
         
         // Prepare trade notification
         string tradeInfo = "FG ScalpingPro: BUY Order Executed\n" +
                    "Symbol: " + _Symbol + "\n" +
                    "Entry: " + DoubleToString(ask, digits) + "\n" +
                    "Stop Loss: " + DoubleToString(sl, digits) + "\n" +
                    "Take Profit: " + DoubleToString(tp, digits) + "\n" +
                    "Lot Size: " + DoubleToString(lotSize, 2) + "\n" +
                    "Probability: " + IntegerToString(CurrentProbability) + "%\n" +
                    "Market Phase: " + MarketPhaseToString(CurrentMarketPhase);
         bool tradeExecuted = true;
         
         // Send trade execution notification if trade was successful
         if(tradeExecuted) {
            if(EnableAlerts) {
               Alert(tradeInfo);
               PlaySound("alert2.wav"); // Different sound for execution
            }
            
            if(EnablePushNotifications) {
               SendNotification(tradeInfo);
            }
            
            if(EnableEmailAlerts) {
               SendMail("FG ScalpingPro Trade Executed", tradeInfo);
            }
         }
      }
   }
   else if(signal == SIGNAL_SELL) {
      double tp = NormalizeDouble(bid - tpDistance, digits);
      double sl = NormalizeDouble(ask + slDistance, digits);
      
      if(Trade.Sell(lotSize, _Symbol, 0, sl, tp, TradeComment)) {
         // Add to active trades array
         int idx = ArraySize(ActiveTrades);
         ArrayResize(ActiveTrades, idx + 1);
         
         ActiveTrades[idx].ticket = Trade.ResultOrder();
         ActiveTrades[idx].openTime = TimeCurrent();
         ActiveTrades[idx].type = POSITION_TYPE_SELL;
         ActiveTrades[idx].openPrice = bid;
         ActiveTrades[idx].lots = lotSize;
         ActiveTrades[idx].tp = tp;
         ActiveTrades[idx].sl = sl;
         ActiveTrades[idx].partialClosed = false;
         
         Print("Sell position opened: Ticket #", Trade.ResultOrder(), 
               ", Lot Size: ", lotSize, 
               ", SL: ", sl, 
               ", TP: ", tp,
               ", ATR: ", DoubleToString(atrValue, 5),
               ", RSI: ", DoubleToString(RSI_Buffer[0], 2));
         
         // Prepare trade notification
         string tradeInfo = "FG ScalpingPro: SELL Order Executed\n" +
                    "Symbol: " + _Symbol + "\n" +
                    "Entry: " + DoubleToString(bid, digits) + "\n" +
                    "Stop Loss: " + DoubleToString(sl, digits) + "\n" +
                    "Take Profit: " + DoubleToString(tp, digits) + "\n" +
                    "Lot Size: " + DoubleToString(lotSize, 2) + "\n" +
                    "Probability: " + IntegerToString(CurrentProbability) + "%\n" +
                    "Market Phase: " + MarketPhaseToString(CurrentMarketPhase);
         bool tradeExecuted = true;
         
         // Send trade execution notification if trade was successful
         if(tradeExecuted) {
            if(EnableAlerts) {
               Alert(tradeInfo);
               PlaySound("alert2.wav"); // Different sound for execution
            }
            
            if(EnablePushNotifications) {
               SendNotification(tradeInfo);
            }
            
            if(EnableEmailAlerts) {
               SendMail("FG ScalpingPro Trade Executed", tradeInfo);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Calculate lot size based on risk percentage                      |
//+------------------------------------------------------------------+
double CalculateLotSize(double sl_points) {
   // If fixed lot size is enabled, use it
   if(UseFixedLotSize) return FixedLotSize;
   
   // Get account info
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double risk_amount = balance * RiskPercent / 100.0;
   
   // Get symbol info
   double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double lot_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   
   // Calculate risk per pip
   double risk_per_pip = risk_amount / sl_points;
   
   // Calculate lot size
   double lot_size = risk_per_pip * _Point / tick_value;
   
   // Round to nearest lot step
   lot_size = MathFloor(lot_size / lot_step) * lot_step;
   
   // Ensure lot size is within acceptable range
   if(lot_size < min_lot) lot_size = min_lot;
   if(lot_size > MaxLotSize) lot_size = MaxLotSize;
   
   return lot_size;
}

//+------------------------------------------------------------------+
//| Manage open positions (trailing stop, partial close)             |
//+------------------------------------------------------------------+
void ManagePositions() {
   // Get current symbol information
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   // Loop through active trades
   for(int i = 0; i < ArraySize(ActiveTrades); i++) {
      // Skip if position doesn't exist
      if(!PositionSelectByTicket(ActiveTrades[i].ticket)) continue;
      
      // Get current position data
      double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double stopLoss = PositionGetDouble(POSITION_SL);
      double takeProfit = PositionGetDouble(POSITION_TP);
      double posLot = PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      
      // Calculate profit in points
      double profitPoints = 0;
      
      if(posType == POSITION_TYPE_BUY) {
         profitPoints = (bid - openPrice) / point;
      }
      else if(posType == POSITION_TYPE_SELL) {
         profitPoints = (openPrice - ask) / point;
      }
      
      // Calculate distance to TP in points
      double tpDistance = MathAbs(takeProfit - openPrice) / point;
      
      // Check if we should perform partial close
      if(UsePartialClose && !ActiveTrades[i].partialClosed && 
         profitPoints >= tpDistance * PartialCloseAt) {
         
         // Calculate lot size to close
         double lotToClose = NormalizeDouble(posLot * (PartialClosePercent / 100.0), 2);
         
         // Ensure minimum lot size
         if(lotToClose >= 0.01 && lotToClose < posLot) {
            // Close part of the position
            if(Trade.PositionClosePartial(ActiveTrades[i].ticket, lotToClose)) {
               ActiveTrades[i].partialClosed = true;
               Print("Partial close executed for ticket #", ActiveTrades[i].ticket, 
                     ", Closed: ", lotToClose, " lots, Remaining: ", 
                     NormalizeDouble(posLot - lotToClose, 2), " lots");
            }
         }
      }
      
      // Check if we should apply trailing stop
      if(UseTrailingStop && profitPoints >= tpDistance * TrailingStart) {
         double newSL = 0;
         
         // Calculate new stop loss level
         if(posType == POSITION_TYPE_BUY) {
            newSL = NormalizeDouble(bid - (TrailingStep * point), digits);
            
            // Only modify if new SL is higher than current
            if(newSL > stopLoss) {
               Trade.PositionModify(ActiveTrades[i].ticket, newSL, takeProfit);
               Print("Trailing stop updated for ticket #", ActiveTrades[i].ticket, 
                     ", New SL: ", newSL);
            }
         }
         else if(posType == POSITION_TYPE_SELL) {
            newSL = NormalizeDouble(ask + (TrailingStep * point), digits);
            
            // Only modify if new SL is lower than current
            if(newSL < stopLoss || stopLoss == 0) {
               Trade.PositionModify(ActiveTrades[i].ticket, newSL, takeProfit);
               Print("Trailing stop updated for ticket #", ActiveTrades[i].ticket, 
                     ", New SL: ", newSL);
            }
         }
      }
   }
} 