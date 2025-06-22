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
input string ALL_Settings = "TP:18, ATR:1.5";  // General or All Currencies settings

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
//| Create a variable to track signal timing                           |
//+------------------------------------------------------------------+
datetime LastSignalCheckTime = 0;
datetime LastSignalFoundTime = 0;
int NoSignalCounter = 0;

//+------------------------------------------------------------------+
//| Calculate time for next day's start (midnight)                    |
//+------------------------------------------------------------------+
datetime GetNextDayStartTime() {
   MqlDateTime current_time;
   TimeToStruct(TimeCurrent(), current_time);
   
   // Reset to beginning of next day (midnight)
   current_time.hour = 0;
   current_time.min = 0;
   current_time.sec = 0;
   
   // Add one day
   return StructToTime(current_time) + 86400; // 86400 seconds = 24 hours
}

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
      Print("ERROR: Failed to create indicator handles!");
      return INIT_FAILED;
   }
   
   // Verify auto trading permissions on initialization
   CheckAutoTradingPermissions();

   // Initialize arrays
   ArraySetAsSeries(BB_Upper, true);
   ArraySetAsSeries(BB_Middle, true);
   ArraySetAsSeries(BB_Lower, true);
   ArraySetAsSeries(EMA_Fast, true);
   ArraySetAsSeries(EMA_Slow, true);
   ArraySetAsSeries(ATR_Buffer, true);
   ArraySetAsSeries(RSI_Buffer, true);
   ArraySetAsSeries(Volume_Buffer, true);
   ArraySetAsSeries(Close, true);
   
   // Initial account balance for risk calculation
   InitialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   // Initialize daily stats tracking
   DailyStartBalance = InitialBalance;
   DailyResetTime = GetNextDayStartTime();
   
   // Set up dashboard if enabled
   if(EnableDashboard) {
      CreateDashboard();
   }
   
   // Load active positions on startup
   LoadExistingPositions();
   
   Print("FG ScalpingPro EA v1.30 initialized successfully");
   
   return INIT_SUCCEEDED;
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
   if(!EnableTrading) {
      static datetime lastWarningTime = 0;
      // Only show warning once per hour to avoid log spam
      if(TimeCurrent() - lastWarningTime > 3600) {
      Print("WARNING: Trading is disabled. Set EnableTrading=true in the inputs to allow auto-trading.");
         lastWarningTime = TimeCurrent();
      }
      return;
   }
   
   // Update indicator data - add detailed error checking
   if(!UpdateIndicators()) {
      Print("ERROR: Failed to update indicators, check buffers");
      // Update dashboard anyway with what we have
      if(EnableDashboard) {
         UpdateDashboard();
      }
      return;
   }
   
   // Always calculate market phase on each tick for real-time updates
   DetectMarketPhase();
   
   // Update and manage existing positions first
   UpdateActiveTrades();
   ManagePositions();
   
   // Check for new signals and calculate probability on EVERY tick
   ENUM_TRADE_SIGNAL newSignal = GetTradeSignal();
   
   // If we get a valid signal, record it for monitoring
   if(newSignal != SIGNAL_NONE) {
      RecordSignalFound();
   }
   
   // Monitor for prolonged periods without signals
   MonitorSignalGeneration();
   
   // Always calculate probability on each tick for real-time updates
   CurrentProbability = CalculateTradeProbability(newSignal);
   
   // Detailed market status log - print every 100 ticks to avoid excessive logging
   static int tickCounter = 0;
   if(tickCounter % 100 == 0) {
      Print("MARKET STATUS: Signal = ", SignalToString(newSignal), 
            ", Probability = ", CurrentProbability, "%", 
            ", Phase = ", MarketPhaseToString(CurrentMarketPhase),
         ", RSI = ", DoubleToString(RSI_Buffer[0], 1),
            ", ATR = ", DoubleToString(ATR_Buffer[0] * _Point, 1),
            ", Fast EMA = ", DoubleToString(EMA_Fast[0], _Digits),
            ", Slow EMA = ", DoubleToString(EMA_Slow[0], _Digits));
   }
   tickCounter++;
   
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
   
   // Lowered threshold - send pre-trade alert if probability is decent
   // Changed from 70% to 60% to be more responsive
   if(CurrentSignal != SIGNAL_NONE && CurrentProbability >= 60) {
      // Only alert once every 5 minutes for the same signal
      if(TimeCurrent() - LastAlertTime > 300) {
         SendPreTradeAlert();
         LastAlertTime = TimeCurrent();
      }
   }
   
   // *** IMPORTANT: Full trading permission check ***
   bool canTrade = true;
   
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
      Print("ERROR: Trading is not allowed in the terminal. Enable AutoTrading in MT5.");
      canTrade = false;
   }
   
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) {
      Print("ERROR: EA is not allowed to trade. Check 'Allow live trading' in EA settings.");
      canTrade = false;
   }
   
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) {
      Print("ERROR: Trading is not allowed for this account. Check with your broker.");
      canTrade = false;
   }
   
   if(!canTrade) {
      // Show continuous warning about trading permissions
      static datetime lastPermissionWarningTime = 0;
      if(TimeCurrent() - lastPermissionWarningTime > 300) { // Every 5 minutes
         CheckAutoTradingPermissions(); // Detailed check with Alert
         lastPermissionWarningTime = TimeCurrent();
      }
      return; // Exit if we can't trade
   }
   
   // Check if we can open new trades
   int currentTrades = ArraySize(ActiveTrades);
   if(currentTrades < MaxTrades) {
      // LOWERED THRESHOLD - Execute trades at 60% probability (was previously higher)
      // This makes the EA more responsive while still maintaining good risk management
      if(CurrentSignal != SIGNAL_NONE && CurrentProbability >= 60 && CheckFilters()) {
         Print("EXECUTING TRADE: ", SignalToString(CurrentSignal), 
               ", Probability: ", CurrentProbability, 
               "%, Market Phase: ", MarketPhaseToString(CurrentMarketPhase));
         ExecuteTrade(CurrentSignal);
      }
      else if(CurrentSignal != SIGNAL_NONE && CurrentProbability > 0) {
         // Log why we're not trading despite having a signal
         static datetime lastLogTime = 0;
         if(TimeCurrent() - lastLogTime > 60) { // Log no more than once per minute
            Print("Trade signal detected but not executing because: ",
                  CurrentProbability < 60 ? "Probability too low (" + IntegerToString(CurrentProbability) + "% < 60%)" : "Failed filters check");
            lastLogTime = TimeCurrent();
         }
      }
   } else if(currentTrades >= MaxTrades) {
      Print("Maximum number of trades (" + IntegerToString(MaxTrades) + ") already open. Not opening new positions.");
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
//| Detect current market phase                                       |
//+------------------------------------------------------------------+
void DetectMarketPhase() {
   // This function determines if the market is in an uptrend, downtrend, ranging or volatile phase
   
   // Previous market phase for logging
   ENUM_MARKET_PHASE prevPhase = CurrentMarketPhase;
   
   // Calculate EMA separation relative to ATR
   double emaSeparation = MathAbs(EMA_Fast[0] - EMA_Slow[0]) / ATR_Buffer[0];
   
   // Calculate BB width relative to price
   double bbWidth = (BB_Upper[0] - BB_Lower[0]) / BB_Middle[0] * 100;
   
   // Calculate ADX strength (use 14 as default period if needed)
   double adxValue = 0;
   double plusDI = 0;
   double minusDI = 0;
   
   // Use custom ADX calculations
   int adx_handle = iADX(_Symbol, PERIOD_CURRENT, 14);
   if(adx_handle != INVALID_HANDLE) {
      double adx_buffer[];
      double plusdi_buffer[];
      double minusdi_buffer[];
      
      ArraySetAsSeries(adx_buffer, true);
      ArraySetAsSeries(plusdi_buffer, true);
      ArraySetAsSeries(minusdi_buffer, true);
      
      CopyBuffer(adx_handle, 0, 0, 3, adx_buffer);
      CopyBuffer(adx_handle, 1, 0, 3, plusdi_buffer);
      CopyBuffer(adx_handle, 2, 0, 3, minusdi_buffer);
      
      adxValue = adx_buffer[0];
      plusDI = plusdi_buffer[0];
      minusDI = minusdi_buffer[0];
      
      IndicatorRelease(adx_handle);
   }
   
   // Check ATR rate of change
   double atrChange = 0;
   if(ATR_Buffer[1] > 0) {
      atrChange = (ATR_Buffer[0] - ATR_Buffer[1]) / ATR_Buffer[1] * 100;
   }
   
   // Check price trend (multiple candles)
   int bullishCandles = 0;
   int bearishCandles = 0;
   
   double prices[];
   ArraySetAsSeries(prices, true);
   if(CopyClose(_Symbol, PERIOD_CURRENT, 0, 10, prices) > 0) {
      // Count consecutive bullish/bearish candles
      for(int i = 1; i < 10; i++) {
         if(prices[i-1] > prices[i]) bullishCandles++;
         else if(prices[i-1] < prices[i]) bearishCandles++;
      }
   }
   
   // More sensitive uptrend detection
   if((EMA_Fast[0] > EMA_Slow[0] && emaSeparation > 0.25) || // Less separation required
      (plusDI > minusDI && adxValue > 20) ||                // Lower ADX threshold
      (bullishCandles >= 6)) {                              // 6 out of 9 candles bullish
      
      if(adxValue > 25 || emaSeparation > 0.5) {
         // Strong uptrend
         CurrentMarketPhase = PHASE_UPTREND;
         if(prevPhase != PHASE_UPTREND)
            Print("Market phase changed to UPTREND (Strong): ADX = ", adxValue, 
                  ", EMA Separation = ", emaSeparation, 
                  ", Bullish Candles = ", bullishCandles);
      } else {
         // Moderate uptrend still counts as uptrend
         CurrentMarketPhase = PHASE_UPTREND;
         if(prevPhase != PHASE_UPTREND)
            Print("Market phase changed to UPTREND (Moderate): ADX = ", adxValue, 
                  ", EMA Separation = ", emaSeparation, 
                  ", Bullish Candles = ", bullishCandles);
      }
   }
   // Downtrend detection (kept as original)
   else if((EMA_Fast[0] < EMA_Slow[0] && emaSeparation > 0.5) || 
           (minusDI > plusDI && adxValue > 25) || 
           (bearishCandles >= 7)) {
      
      CurrentMarketPhase = PHASE_DOWNTREND;
      if(prevPhase != PHASE_DOWNTREND)
         Print("Market phase changed to DOWNTREND: ADX = ", adxValue, 
               ", EMA Separation = ", emaSeparation, 
               ", Bearish Candles = ", bearishCandles);
   }
   // Volatile market detection
   else if(atrChange > 20 || bbWidth > 2.0) {
      CurrentMarketPhase = PHASE_VOLATILE;
      if(prevPhase != PHASE_VOLATILE)
         Print("Market phase changed to VOLATILE: ATR Change = ", atrChange, 
               "%, BB Width = ", bbWidth, "%");
   }
   // Ranging market
   else if(emaSeparation < 0.3 && adxValue < 20) {
      CurrentMarketPhase = PHASE_RANGING;
      if(prevPhase != PHASE_RANGING)
         Print("Market phase changed to RANGING: ADX = ", adxValue, 
               ", EMA Separation = ", emaSeparation);
   }
   // Default - keep previous phase if no clear change detected
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
   Print("Checking filters...");
   
   // Check volatility filter (ATR)
   double atr_points = ATR_Buffer[0] * _Point;
   bool atrOk = atr_points >= ATR_MinValue * _Point;
   Print("ATR filter: ", atr_points, " points, min required: ", ATR_MinValue * _Point, " - ", (atrOk ? "PASSED" : "FAILED"));
   if(!atrOk) return false;
   
   // Check volume filter
   bool volumeOk = true;
   if(EnableVolumeFilter) {
      volumeOk = Volume_Buffer[0] > Volume_SMA;
      Print("Volume filter: Current = ", Volume_Buffer[0], ", Average = ", Volume_SMA, " - ", (volumeOk ? "PASSED" : "FAILED"));
      if(!volumeOk) return false;
   }
   
   // Check time filter
   bool timeOk = true;
   if(EnableTimeFilter) {
      TimeToStruct(TimeCurrent(), dt_struct);
      
      // Check day of week filter
      bool dayOk = true;
      if((dt_struct.day_of_week == 1 && !MondayFilter) ||
         (dt_struct.day_of_week == 2 && !TuesdayFilter) ||
         (dt_struct.day_of_week == 3 && !WednesdayFilter) ||
         (dt_struct.day_of_week == 4 && !ThursdayFilter) ||
         (dt_struct.day_of_week == 5 && !FridayFilter)) {
         dayOk = false;
      }
      
      // Check trading hours (EST time)
      bool hourOk = true;
      int current_hour = dt_struct.hour;
      if(current_hour < StartHour || current_hour >= EndHour) {
         hourOk = false;
      }
      
      timeOk = dayOk && hourOk;
      Print("Time filter: Day = ", dt_struct.day_of_week, ", Hour = ", current_hour, 
            " (Range ", StartHour, "-", EndHour, ") - ", (timeOk ? "PASSED" : "FAILED"));
      if(!timeOk) return false;
   }
   
   // Check news filter
   bool newsOk = true;
   if(EnableNewsFilter) {
      newsOk = !IsHighImpactNews();
      Print("News filter: ", (newsOk ? "PASSED" : "FAILED"));
      if(!newsOk) return false;
   }
   
   // Add RSI filter
   bool rsiOk = true;
   if(UseRSIFilter) {
      // For buy signals: ensure RSI is not extremely overbought
      if(CurrentSignal == SIGNAL_BUY && RSI_Buffer[0] > RSI_Overbought) {
         rsiOk = false;
      }
      
      // For sell signals: ensure RSI is not extremely oversold
      if(CurrentSignal == SIGNAL_SELL && RSI_Buffer[0] < RSI_Oversold) {
         rsiOk = false;
      }
      
      Print("RSI filter: Current RSI = ", RSI_Buffer[0], " - ", (rsiOk ? "PASSED" : "FAILED"));
      if(!rsiOk) return false;
   }
   
   // Check daily loss limit
   bool lossOk = true;
   if(UseDailyLossLimit) {
      lossOk = !IsDailyLossLimitReached();
      Print("Daily loss limit: ", (lossOk ? "PASSED" : "FAILED"));
      if(!lossOk) return false;
   }
   
   Print("All filters PASSED");
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
   
   // Enhanced debug info
   string debug = "Signal debug: ";
   bool emaCondition = EMA_Fast[0] > EMA_Slow[0];
   bool priceCondition = Close[0] > EMA_Fast[0];
   bool touchCondition = (Close[1] <= EMA_Fast[1] || Close[2] <= EMA_Fast[2]);
   bool rsiMomentumCondition = RSI_Buffer[0] > RSI_Buffer[1];
   bool rsiOversoldCondition = (RSI_Buffer[1] < RSI_Oversold || RSI_Buffer[2] < RSI_Oversold);
   
   debug += "EMA(F>S): " + (emaCondition ? "YES" : "NO") + ", ";
   debug += "Price>EMA: " + (priceCondition ? "YES" : "NO") + ", ";
   debug += "EMA Touch: " + (touchCondition ? "YES" : "NO") + ", ";
   debug += "RSI Up: " + (rsiMomentumCondition ? "YES" : "NO") + ", ";
   debug += "RSI was Oversold: " + (rsiOversoldCondition ? "YES" : "NO");
   Print(debug);
   
   // Modified buy signal - relaxed conditions for strong uptrend
   if(emaCondition && priceCondition) { // Core trend conditions
      if(CurrentMarketPhase == PHASE_UPTREND) {
         // In a confirmed uptrend, we're more flexible with other conditions
         if(rsiMomentumCondition || touchCondition) {
      signal = SIGNAL_BUY;
            Print("BUY SIGNAL: Uptrend conditions with relaxed parameters");
         }
      }
      // Original strict conditions
      else if(touchCondition && rsiMomentumCondition && rsiOversoldCondition) {
         signal = SIGNAL_BUY;
         Print("BUY SIGNAL: Standard conditions met");
      }
   }
   
   // Check for sell signal - keeping original conditions
   else if(EMA_Fast[0] < EMA_Slow[0] && // Bearish trend
           Close[0] < EMA_Fast[0] &&    // Price below Fast EMA
           (Close[1] >= EMA_Fast[1] || Close[2] >= EMA_Fast[2]) && // Recent cross or touch of EMA
           RSI_Buffer[0] < RSI_Buffer[1] && // RSI momentum down
           (RSI_Buffer[1] > RSI_Overbought || RSI_Buffer[2] > RSI_Overbought)) { // Coming from overbought
      
      signal = SIGNAL_SELL;
      Print("SELL SIGNAL: Standard conditions met");
   }
   
   return signal;
}

//+------------------------------------------------------------------+
//| Calculate trade probability based on indicator readings          |
//+------------------------------------------------------------------+
int CalculateTradeProbability(ENUM_TRADE_SIGNAL signal) {
   int probability = 0;
   
   // Start with base probability
   probability = 10; // Minimum base
   
   // Even if no signal, calculate a probability based on market conditions
   if(signal == SIGNAL_NONE) {
      // Check if close to generating a signal
      bool potentialBuy = (EMA_Fast[0] > EMA_Slow[0] && Close[0] > EMA_Fast[0]);
      bool potentialSell = (EMA_Fast[0] < EMA_Slow[0] && Close[0] < EMA_Fast[0]);
      
      if(potentialBuy || potentialSell) {
         probability = 25; // Base probability for potential signal
      }
   } else {
      // Base score - having a valid signal gives 40 points
      probability = 40;
   }
   
   // Add points based on trend strength - use the same calculation as indicator
   double emaSeparation = MathAbs(EMA_Fast[0] - EMA_Slow[0]) / ATR_Buffer[0];
   int trendPoints = (int)MathMin(emaSeparation * 70, 25); // Increased weight for trend strength
   probability += trendPoints;
   
   // Add points based on RSI strength - match indicator calculation
   if(signal == SIGNAL_BUY || (signal == SIGNAL_NONE && EMA_Fast[0] > EMA_Slow[0])) {
      // For buy signals
      if(RSI_Buffer[0] > 50 && RSI_Buffer[0] < RSI_Overbought - 5) {
         probability += 10; // Bullish but not overbought
      }
      
      // For recently oversold conditions
      if(RSI_Buffer[1] < RSI_Oversold || RSI_Buffer[2] < RSI_Oversold) {
         probability += 15; // Coming from oversold is bullish
      }
      
      // For upward momentum
      double rsiMomentum = RSI_Buffer[0] - RSI_Buffer[1];
      probability += (int)MathMin(rsiMomentum * 3, 15); // Increased weight for momentum
   }
   else if(signal == SIGNAL_SELL || (signal == SIGNAL_NONE && EMA_Fast[0] < EMA_Slow[0])) {
      // For sell signals
      if(RSI_Buffer[0] < 50 && RSI_Buffer[0] > RSI_Oversold + 5) {
         probability += 10; // Bearish but not oversold
      }
      
      // For recently overbought conditions
      if(RSI_Buffer[1] > RSI_Overbought || RSI_Buffer[2] > RSI_Overbought) {
         probability += 15; // Coming from overbought is bearish
      }
      
      // For downward momentum
      double rsiMomentum = RSI_Buffer[1] - RSI_Buffer[0];
      probability += (int)MathMin(rsiMomentum * 3, 15); // Increased weight for momentum
   }
   
   // Add ADX influence for trend strength - this matches the indicator better
   double adxValue = 0;
   double plusDI = 0;
   double minusDI = 0;
   
   // Use custom ADX calculations
   int adx_handle = iADX(_Symbol, PERIOD_CURRENT, 14);
   if(adx_handle != INVALID_HANDLE) {
      double adx_buffer[];
      double plusdi_buffer[];
      double minusdi_buffer[];
      
      ArraySetAsSeries(adx_buffer, true);
      ArraySetAsSeries(plusdi_buffer, true);
      ArraySetAsSeries(minusdi_buffer, true);
      
      CopyBuffer(adx_handle, 0, 0, 3, adx_buffer);
      CopyBuffer(adx_handle, 1, 0, 3, plusdi_buffer);
      CopyBuffer(adx_handle, 2, 0, 3, minusdi_buffer);
      
      adxValue = adx_buffer[0];
      plusDI = plusdi_buffer[0];
      minusDI = minusdi_buffer[0];
      
      // Add ADX-based points
      if(adxValue > 25) probability += 10;  // Strong trend
      else if(adxValue > 15) probability += 5;  // Medium trend
      
      IndicatorRelease(adx_handle);
   }
   
   // Market condition factor - updated to match indicator
   switch(CurrentMarketPhase) {
      case PHASE_UPTREND:
         // Higher probability for buy signals in uptrend
         if(signal == SIGNAL_BUY) probability += 15;
         else if(signal == SIGNAL_SELL) probability -= 10; // Counter-trend trade
         break;
      case PHASE_DOWNTREND:
         // Higher probability for sell signals in downtrend
         if(signal == SIGNAL_SELL) probability += 15;
         else if(signal == SIGNAL_BUY) probability -= 10; // Counter-trend trade
         break;
      case PHASE_RANGING:
         // Slightly lower probability in ranging markets
         probability -= 5;
         break;
      case PHASE_VOLATILE:
         // Higher risk in volatile markets
         probability -= 10;
         break;
   }
   
   // Cap at 100, minimum 5
   probability = MathMax(MathMin(probability, 100), 5);
   
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
   // Force recalculation of indicators to ensure the most current data
   UpdateIndicators();
   
   // Recalculate probability with the current values
   CurrentProbability = CalculateTradeProbability(CurrentSignal);

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
   
   // Update probability display - match the indicator's probability format for consistency
   string probText = "Trade Probability: " + IntegerToString(CurrentProbability) + "%";
   color probColor = DashboardTextColor;
   
   if(CurrentProbability >= 80) probColor = clrLime;
   else if(CurrentProbability >= 70) probColor = clrLime; // Make 70%+ also green
   else if(CurrentProbability >= 60) probColor = clrYellow;
   else if(CurrentProbability >= 40) probColor = clrOrange;
   else probColor = clrRed; // Low probability
   
   // Add trade status indicator
   if(CurrentProbability >= 60) {
      probText += " (READY)";
   }
   else if(CurrentProbability >= 40) {
      probText += " (MONITORING)";
   }
   else {
      probText += " (WAITING)";
   }
   
   ObjectSetString(0, DashboardProbability, OBJPROP_TEXT, probText);
   ObjectSetInteger(0, DashboardProbability, OBJPROP_COLOR, probColor);
   
   // Update RSI - protect against invalid values
   double rsiValue = RSI_Buffer[0];
   if(rsiValue <= 0 || rsiValue > 100) {
      rsiValue = 50.0; // Use neutral value if invalid
      Print("Warning: Invalid RSI value, using default");
   }
   
   string rsiText = "RSI: " + DoubleToString(rsiValue, 1);
   color rsiColor = DashboardTextColor;
   
   // Enhanced RSI interpretation
   if(rsiValue > RSI_Overbought) {
      rsiText += " (OVERBOUGHT)";
      rsiColor = clrRed;
   }
   else if(rsiValue < RSI_Oversold) {
      rsiText += " (OVERSOLD)";
      rsiColor = clrLime;
   }
   else if(rsiValue > 60) {
      rsiText += " (BULLISH)";
      rsiColor = clrLime;
   }
   else if(rsiValue < 40) {
      rsiText += " (BEARISH)";
      rsiColor = clrRed;
   }
   else {
      rsiText += " (NEUTRAL)";
   }
   
   ObjectSetString(0, DashboardRSI, OBJPROP_TEXT, rsiText);
   ObjectSetInteger(0, DashboardRSI, OBJPROP_COLOR, rsiColor);
   
   // Update ATR - protect against invalid values
   double atrValue = ATR_Buffer[0];
   if(atrValue <= 0) {
      atrValue = _Point * 10; // Use small default value if invalid
      Print("Warning: Invalid ATR value, using default");
   }
   
   double atrPoints = atrValue / _Point;
   color atrColor = DashboardTextColor;
   
   string atrStatus = "";
   if(atrPoints > ATR_MinValue * 2) {
      atrStatus = " (HIGH)";
      atrColor = clrYellow;
   }
   else if(atrPoints >= ATR_MinValue) {
      atrStatus = " (ADEQUATE)";
      atrColor = clrLime;
   }
   else {
      atrStatus = " (LOW)";
      atrColor = clrRed;
   }
   
   ObjectSetString(0, DashboardATR, OBJPROP_TEXT, "ATR: " + DoubleToString(atrPoints, 1) + " pts" + atrStatus);
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
   // Add a debugging print statement to confirm we're attempting to execute a trade
   Print("Attempting to execute trade: ", SignalToString(signal));
   
   // Get current symbol information
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   
   // Verify we have valid prices
   if(ask <= 0 || bid <= 0) {
      Print("ERROR: Invalid prices - Ask: ", ask, ", Bid: ", bid);
      return;
   }
   
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
   
   // Verify ATR is valid
   if(atrValue <= 0) {
      Print("ERROR: Invalid ATR value: ", atrValue, ". Using minimum value instead.");
      atrValue = 10 * _Point; // Use a minimum value
   }
   
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
      else pairSettings = ALL_Settings;
      
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
   
   // Verify lot size is valid
   if(lotSize <= 0) {
      Print("ERROR: Invalid lot size: ", lotSize, ". Using minimum lot size.");
      lotSize = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   }
   
   // Execute trade based on signal
   if(signal == SIGNAL_BUY) {
      double tp = NormalizeDouble(ask + tpDistance, digits);
      double sl = NormalizeDouble(bid - slDistance, digits);
      
      // Verify we have valid TP/SL
      if(tp <= ask || sl >= bid) {
         Print("ERROR: Invalid TP/SL values - TP: ", tp, ", SL: ", sl, 
               ", Ask: ", ask, ", Bid: ", bid);
         return;
      }
      
      Print("Attempting to OPEN BUY: Lot=", lotSize, ", SL=", sl, ", TP=", tp);
      
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
      else {
         // Print error if trade failed
         Print("ERROR: Buy order failed! Error code: ", GetLastError(), 
               ", Error description: ", Trade.ResultRetcodeDescription());
      }
   }
   else if(signal == SIGNAL_SELL) {
      double tp = NormalizeDouble(bid - tpDistance, digits);
      double sl = NormalizeDouble(ask + slDistance, digits);
      
      // Verify we have valid TP/SL
      if(tp >= bid || sl <= ask) {
         Print("ERROR: Invalid TP/SL values - TP: ", tp, ", SL: ", sl, 
               ", Ask: ", ask, ", Bid: ", bid);
         return;
      }
      
      Print("Attempting to OPEN SELL: Lot=", lotSize, ", SL=", sl, ", TP=", tp);
      
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
      else {
         // Print error if trade failed
         Print("ERROR: Sell order failed! Error code: ", GetLastError(), 
               ", Error description: ", Trade.ResultRetcodeDescription());
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
   
   // First, check for manual trades and optimize their TP settings
   DetectAndOptimizeManualTrades();
   
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

//+------------------------------------------------------------------+
//| Detect manual trades and set optimal take profit                 |
//+------------------------------------------------------------------+
void DetectAndOptimizeManualTrades() {
   // Strict time check to avoid excessive runs
   static datetime lastCheckTime = 0;
   if(TimeCurrent() - lastCheckTime < 30) { // Run at most every 30 seconds
      return;
   }
   lastCheckTime = TimeCurrent();
   
   Print("===== CHECKING FOR MANUAL TRADES =====");
   
   // Get current symbol information
   string currentSymbol = _Symbol;
   double point = SymbolInfoDouble(currentSymbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(currentSymbol, SYMBOL_DIGITS);
   double ask = SymbolInfoDouble(currentSymbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(currentSymbol, SYMBOL_BID);
   
   Print("Current Symbol: ", currentSymbol);
   Print("Current Price: Bid=", DoubleToString(bid, digits), " Ask=", DoubleToString(ask, digits));
   
   // Track whether we found any trades to optimize
   bool anyTradesOptimized = false;
   
   // Get all positions
   for(int i = 0; i < PositionsTotal(); i++) {
      ulong ticket = PositionGetTicket(i);
      
      if(ticket <= 0) {
         Print("Failed to get position ticket #", i);
         continue;
      }
      
      // Check if this position is for the current symbol
      if(PositionGetString(POSITION_SYMBOL) != currentSymbol) {
         continue;
      }
      
      // Skip positions already managed by our EA (using MagicNumber)
      if(PositionGetInteger(POSITION_MAGIC) == MagicNumber) {
         continue;
      }
      
      // This is a manual trade or from another EA - let's check if it needs optimization
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);
      double currentTP = PositionGetDouble(POSITION_TP);
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      
      Print("Found manual position #", ticket, " - Type: ", (posType == POSITION_TYPE_BUY ? "BUY" : "SELL"), 
            ", Open Price: ", DoubleToString(openPrice, digits), 
            ", Current SL: ", DoubleToString(currentSL, digits),
            ", Current TP: ", DoubleToString(currentTP, digits));
      
      // Check for invalid/default TP values
      bool needsOptimization = false;
      
      // Case 1: No TP set
      if(currentTP == 0) {
         Print("Position #", ticket, " has no TP set - will optimize");
         needsOptimization = true; 
      }
      // Case 2: Buy position with TP too close or below entry
      else if(posType == POSITION_TYPE_BUY && (currentTP <= openPrice || currentTP - openPrice < 10 * point)) {
         Print("BUY position #", ticket, " has invalid TP (", DoubleToString(currentTP, digits), 
               ") too close to entry price (", DoubleToString(openPrice, digits), ") - will optimize");
         needsOptimization = true;
      }
      // Case 3: Sell position with TP too close or above entry
      else if(posType == POSITION_TYPE_SELL && (currentTP >= openPrice || openPrice - currentTP < 10 * point)) {
         Print("SELL position #", ticket, " has invalid TP (", DoubleToString(currentTP, digits), 
               ") too close to entry price (", DoubleToString(openPrice, digits), ") - will optimize");
         needsOptimization = true;
      }
      // Case 4: TP far from current market (could be outdated)
      else if((posType == POSITION_TYPE_BUY && MathAbs(currentTP - bid) > 300 * point) ||
              (posType == POSITION_TYPE_SELL && MathAbs(currentTP - ask) > 300 * point)) {
         Print("Position #", ticket, " has TP (", DoubleToString(currentTP, digits),
               ") far from current market - will re-optimize");
         needsOptimization = true;
      }
      
      if(needsOptimization) {
         // Calculate optimal TP based on current market conditions
         double optimalTP = CalculateOptimalTakeProfit(posType, openPrice);
         
         // Verify calculated TP is valid
         bool isValidTp = (optimalTP > 0) &&
                         ((posType == POSITION_TYPE_BUY && optimalTP > openPrice) ||
                          (posType == POSITION_TYPE_SELL && optimalTP < openPrice));
         
         if(!isValidTp) {
            Print("WARNING: Failed to calculate valid TP for position #", ticket);
            continue;
         }
         
         // Safety check: for buy positions, make sure TP isn't too high
         if(posType == POSITION_TYPE_BUY && optimalTP > openPrice + 200 * point) {
            Print("WARNING: Calculated TP is too high - limiting to 200 pips from entry");
            optimalTP = NormalizeDouble(openPrice + 200 * point, digits);
         }
         // Safety check: for sell positions, make sure TP isn't too low
         else if(posType == POSITION_TYPE_SELL && optimalTP < openPrice - 200 * point) {
            Print("WARNING: Calculated TP is too low - limiting to 200 pips from entry");
            optimalTP = NormalizeDouble(openPrice - 200 * point, digits);
         }
         
         // Only modify if new TP is better than current
         bool shouldModify = (currentTP == 0) || // No TP set
                             (posType == POSITION_TYPE_BUY && optimalTP > currentTP) || // Better buy TP
                             (posType == POSITION_TYPE_SELL && optimalTP < currentTP); // Better sell TP
         
         if(shouldModify) {
            Print("Modifying position #", ticket, " - setting TP to ", DoubleToString(optimalTP, digits));
            
            // Don't modify SL - only update TP
            if(Trade.PositionModify(ticket, currentSL, optimalTP)) {
               Print("✓ SUCCESS: Optimized TP for ticket #", ticket, 
                     " to ", DoubleToString(optimalTP, digits), 
                     " (", DoubleToString(MathAbs(optimalTP - openPrice) / point, 1), " pips)");
               anyTradesOptimized = true;
            } else {
               Print("✗ ERROR: Failed to modify position #", ticket, " - Error: ", GetLastError());
            }
         } else {
            Print("Current TP is already optimal or better than calculated TP - no modification needed");
         }
      } else {
         Print("Position #", ticket, " has appropriate TP - no optimization needed");
      }
   }
   
   if(!anyTradesOptimized) {
      Print("No manual trades found or all trades already have optimal TP levels");
   }
   
   Print("===== MANUAL TRADE CHECK COMPLETED =====");
}

//+------------------------------------------------------------------+
//| Calculate optimal take profit based on market conditions         |
//+------------------------------------------------------------------+
double CalculateOptimalTakeProfit(ENUM_POSITION_TYPE posType, double openPrice) {
   // Get proper symbol information for correct calculations
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Print debug information
   Print("---- TP CALCULATION DEBUG ----");
   Print("Symbol: ", _Symbol);
   Print("Position Type: ", (posType == POSITION_TYPE_BUY ? "BUY" : "SELL"));
   Print("Open Price: ", DoubleToString(openPrice, digits));
   Print("Current Ask/Bid: ", DoubleToString(ask, digits), "/", DoubleToString(bid, digits));
   Print("Symbol Point: ", DoubleToString(point, digits));
   Print("Symbol Digits: ", digits);
   
   // Get current ATR for volatility-based TP
   double atrValue = ATR_Buffer[0];
   if(atrValue <= 0) {
      Print("ATR is invalid, using minimum value");
      atrValue = 15 * point; // Increased minimum value for safer TP
   }
   Print("ATR Value: ", DoubleToString(atrValue, digits));
   
   // Enhanced TP calculation for manual trades
   // Start with a higher base multiplier for manual trades
   double tpMultiplier = ATR_Multiplier_TP * 2.0; // Double the normal multiplier
   Print("Base ATR multiplier (enhanced): ", DoubleToString(tpMultiplier, 2));
   
   // Adjust multiplier based on market phase with more aggressive settings
   if(UseDynamicMultiplier) {
      double phaseMultiplier = 1.0;
      
      switch(CurrentMarketPhase) {
         case PHASE_UPTREND:
            phaseMultiplier = 2.0; // More aggressive TP in strong uptrend
            if(posType == POSITION_TYPE_BUY) phaseMultiplier *= 1.2; // Extra boost for buys in uptrend
            break;
         case PHASE_DOWNTREND:
            phaseMultiplier = 2.0; // More aggressive TP in strong downtrend
            if(posType == POSITION_TYPE_SELL) phaseMultiplier *= 1.2; // Extra boost for sells in downtrend
            break;
         case PHASE_RANGING:
            phaseMultiplier = 1.5; // Moderate but still profitable TP in ranging market
            break;
         case PHASE_VOLATILE:
            phaseMultiplier = 2.5; // More aggressive TP in volatile markets for better profit potential
            break;
      }
      
      tpMultiplier *= phaseMultiplier;
      Print("Market phase: ", MarketPhaseToString(CurrentMarketPhase), 
            ", adjusted multiplier: ", DoubleToString(tpMultiplier, 2));
   }
   
   // Consider RSI for additional TP adjustment
   if(RSI_Buffer[0] > 70 && posType == POSITION_TYPE_BUY) {
      tpMultiplier *= 0.8; // Reduce TP distance for buys in overbought conditions
      Print("RSI overbought adjustment for BUY");
   }
   else if(RSI_Buffer[0] < 30 && posType == POSITION_TYPE_SELL) {
      tpMultiplier *= 0.8; // Reduce TP distance for sells in oversold conditions
      Print("RSI oversold adjustment for SELL");
   }
   
   // Calculate TP distance based on ATR and enhanced multiplier
   double tpDistance = atrValue * tpMultiplier;
   
   // Set minimum TP distance to ensure worthwhile profit potential
   // Minimum 30 pips or current ATR value, whichever is larger
   double minDistance = MathMax(30 * point, atrValue);
   if(tpDistance < minDistance) {
      Print("Adjusting to minimum safe TP distance");
      tpDistance = minDistance;
   }
   
   // Cap maximum TP distance at 150 pips or 3x ATR, whichever is larger
   double maxDistance = MathMax(150 * point, atrValue * 3);
   if(tpDistance > maxDistance) {
      Print("Capping TP distance to maximum safe level");
      tpDistance = maxDistance;
   }
   
   Print("Final TP distance: ", DoubleToString(tpDistance, digits), 
         " (", DoubleToString(tpDistance / point, 1), " pips)");
   
   // Calculate TP level based on position type
   double tpLevel;
   if(posType == POSITION_TYPE_BUY) {
      tpLevel = NormalizeDouble(openPrice + tpDistance, digits);
      Print("BUY TP calculation: ", DoubleToString(openPrice, digits), " + ", 
            DoubleToString(tpDistance, digits), " = ", DoubleToString(tpLevel, digits));
   } else {
      tpLevel = NormalizeDouble(openPrice - tpDistance, digits);
      Print("SELL TP calculation: ", DoubleToString(openPrice, digits), " - ", 
            DoubleToString(tpDistance, digits), " = ", DoubleToString(tpLevel, digits));
   }
   
   // Additional safety checks
   if(posType == POSITION_TYPE_BUY) {
      // Ensure minimum 30 pip distance for buy orders
      if(tpLevel - openPrice < 30 * point) {
         tpLevel = NormalizeDouble(openPrice + 30 * point, digits);
         Print("Adjusted BUY TP to minimum 30 pip distance");
      }
   } else {
      // Ensure minimum 30 pip distance for sell orders
      if(openPrice - tpLevel < 30 * point) {
         tpLevel = NormalizeDouble(openPrice - 30 * point, digits);
         Print("Adjusted SELL TP to minimum 30 pip distance");
      }
   }
   
   Print("Final TP level: ", DoubleToString(tpLevel, digits));
   return tpLevel;
}

//+------------------------------------------------------------------+
//| Check auto trading permissions and log status                    |
//+------------------------------------------------------------------+
void CheckAutoTradingPermissions() {
   bool canAutoTrade = true;
   string errorMessage = "Auto-trading status check:\n";
   
   // Check if EA input allows trading
   if(!EnableTrading) {
      errorMessage += "- ERROR: Trading is disabled in EA parameters. Set EnableTrading=true\n";
      canAutoTrade = false;
   } else {
      errorMessage += "- EnableTrading parameter: OK\n";
   }
   
   // Check if terminal allows auto-trading (button in MT5)
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
      errorMessage += "- ERROR: Trading is not allowed in terminal. Click 'AutoTrading' button in MT5\n";
      canAutoTrade = false;
   } else {
      errorMessage += "- Terminal AutoTrading permission: OK\n";
   }
   
   // Check if EA has permissions to trade
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) {
      errorMessage += "- ERROR: This EA is not allowed to trade. Enable 'Allow live trading' in EA settings\n";
      canAutoTrade = false;
   } else {
      errorMessage += "- EA live trading permission: OK\n";
   }
   
   // Check if account allows trading
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) {
      errorMessage += "- ERROR: Trading is not allowed for this account. Check with your broker\n";
      canAutoTrade = false;
   } else {
      errorMessage += "- Account trading permission: OK\n";
   }
   
   // Print the full report
   Print(errorMessage);
   
   // Show alert if can't auto-trade
   if(!canAutoTrade) {
      string alertMessage = "FG ScalpingPro EA cannot auto-trade. Check MT5 logs for details.";
      if(!EnableTrading) {
         alertMessage = "FG ScalpingPro EA: Trading is disabled. Set EnableTrading=true in EA parameters.";
      } else if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
         alertMessage = "FG ScalpingPro EA: Click the 'AutoTrading' button in MT5 to enable trading.";
      }
      
      Alert(alertMessage);
   }
}

//+------------------------------------------------------------------+
//| Check if the EA is having trouble generating signals              |
//+------------------------------------------------------------------+
void MonitorSignalGeneration() {
   // Check every hour if we've generated any signals
   if(TimeCurrent() - LastSignalCheckTime > 3600) { // 1 hour interval
      LastSignalCheckTime = TimeCurrent();
      
      // If we've had a signal recently (within 4 hours), reset counter
      if(LastSignalFoundTime > 0 && TimeCurrent() - LastSignalFoundTime < 14400) {
         NoSignalCounter = 0;
         return;
      }
      
      // Increment counter for each hour without signals
      NoSignalCounter++;
      
      // After 8 hours with no signals (during market hours), warn user
      if(NoSignalCounter >= 8) {
         // Only alert every 8 hours to avoid spam
         if(NoSignalCounter % 8 == 0) {
            string message = "WARNING: No trade signals have been generated for " + 
                             IntegerToString(NoSignalCounter) + " hours. Check configuration and market conditions.";
            Print(message);
            if(EnableAlerts) Alert(message);
            
            // Perform detailed check of indicators
            double rsi = RSI_Buffer[0];
            double atr = ATR_Buffer[0] * _Point;
            double emaFast = EMA_Fast[0];
            double emaSlow = EMA_Slow[0];
            double emaDiff = emaFast - emaSlow;
            
            Print("Detailed indicator status:");
            Print("RSI(14): ", DoubleToString(rsi, 1), " (Oversold < ", RSI_Oversold, ", Overbought > ", RSI_Overbought, ")");
            Print("ATR(14): ", DoubleToString(atr, 1), " points (Min required: ", ATR_MinValue * _Point, ")");
            Print("EMA Fast-Slow Gap: ", DoubleToString(emaDiff, _Digits), " (", (emaDiff > 0 ? "Bullish" : "Bearish"), ")");
            Print("Market Phase: ", MarketPhaseToString(CurrentMarketPhase));
            Print("Current Close Price: ", DoubleToString(Close[0], _Digits));
            
            // Additional troubleshooting suggestions
            Print("Troubleshooting tips:");
            if(rsi > RSI_Overbought - 5) Print("- RSI is near overbought, preventing buy signals");
            if(rsi < RSI_Oversold + 5) Print("- RSI is near oversold, preventing sell signals");
            if(atr < ATR_MinValue * _Point) Print("- ATR is below minimum threshold, preventing trades due to low volatility");
            if(MathAbs(emaDiff) < 0.0002) Print("- EMAs are too close, waiting for clearer trend direction");
            if(EnableTimeFilter) Print("- Check if current trading time is within allowed hours (", StartHour, "-", EndHour, " EST)");
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Record when a valid signal is found                               |
//+------------------------------------------------------------------+
void RecordSignalFound() {
   LastSignalFoundTime = TimeCurrent();
   NoSignalCounter = 0; // Reset counter when valid signal found
} 