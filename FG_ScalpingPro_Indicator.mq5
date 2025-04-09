//+------------------------------------------------------------------+
//|                             FG_ScalpingPro_Indicator_FIXED.mq5 |
//|                       Copyright 2025, FGCompany Original Trading |
//|                                     Developed by Faiz Nasir      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, FGCompany Original Trading"
#property link      "https://www.fgtrading.com"
#property version   "1.01"
#property description "FG ScalpingPro Trading System Indicator (Display Only)"
#property indicator_chart_window
#property indicator_separate_window 0
#property indicator_buffers 19
#property indicator_plots   14
#property indicator_applied_price PRICE_CLOSE

// Plot properties for Bollinger Bands
#property indicator_label1  "BB Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_style1  STYLE_DASH
#property indicator_width1  1

#property indicator_label2  "BB Middle"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "BB Lower"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGray
#property indicator_style3  STYLE_DASH
#property indicator_width3  1

// Plot properties for EMAs
#property indicator_label4  "EMA Fast"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDodgerBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2

#property indicator_label5  "EMA Slow"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrCrimson
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2

// Plot properties for Buy/Sell signals
#property indicator_label6  "Buy Signal"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrLime
#property indicator_width6  3
#property indicator_label7  "Sell Signal"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrRed
#property indicator_width7  3

// Plot properties for Bollinger squeeze zones
#property indicator_label8  "Bollinger Squeeze"
#property indicator_type8   DRAW_COLOR_BARS
#property indicator_color8  clrSilver, clrOrange, clrPurple
#property indicator_width8  1

// Plot properties for signal strength histogram
#property indicator_label9  "Signal Strength"
#property indicator_type9   DRAW_COLOR_HISTOGRAM
#property indicator_color9  clrDarkGray, clrLime, clrGreen, clrRed, clrMaroon
#property indicator_width9  2

// Plot properties for Fractal indicators
#property indicator_label10  "Upper Fractal"
#property indicator_type10   DRAW_ARROW
#property indicator_color10  clrAqua
#property indicator_width10  2

#property indicator_label11  "Lower Fractal"
#property indicator_type11   DRAW_ARROW
#property indicator_color11  clrMagenta
#property indicator_width11  2

// Plot properties for Support/Resistance levels
#property indicator_label12  "Support Level"
#property indicator_type12   DRAW_LINE
#property indicator_color12  clrForestGreen
#property indicator_style12  STYLE_DASHDOT
#property indicator_width12  2

#property indicator_label13  "Resistance Level"
#property indicator_type13   DRAW_LINE
#property indicator_color13  clrFireBrick
#property indicator_style13  STYLE_DASHDOT
#property indicator_width13  2

// Plot properties for trend strength
#property indicator_label14  "Trend Strength"
#property indicator_type14   DRAW_HISTOGRAM
#property indicator_color14  clrOrange
#property indicator_width14  3

// Input parameters
input string GeneralSection = "===== Indicator Settings ====="; // General Settings
input int    BB_Period = 20;              // Bollinger Bands period
input double BB_Deviation = 2.5;          // Bollinger Bands deviation
input int    BB_Shift = 0;                // Bollinger Bands shift
input int    EMA_Fast_Period = 9;         // Fast EMA period
input int    EMA_Slow_Period = 21;        // Slow EMA period
input int    ATR_Period = 14;             // ATR period
input int    Volume_Period = 20;          // Volume SMA period
input bool   ShowBollingerSqueeze = true; // Show Bollinger squeeze alerts
input bool   EnableVolumeFilter = true;   // Apply volume filter to signals
input int    ATR_MinValue = 15;           // Minimum ATR value in points

// RSI Settings
input string RSISection = "===== RSI Settings ====="; // RSI Settings
input int    RSI_Period = 14;             // RSI period
input int    RSI_Overbought = 70;         // RSI overbought level
input int    RSI_Oversold = 30;           // RSI oversold level
input bool   UseRSIFilter = true;         // Use RSI for signal filtering

// Fractal and S/R settings
input string FractalSection = "===== Fractal & Support/Resistance Settings ====="; // Fractal Settings
input int    Fractal_Period = 5;          // Fractal period
input int    SR_LookbackPeriod = 200;     // Lookback period for S/R
input int    SR_Depth = 12;               // S/R detection depth
input int    SR_Deviation = 5;            // S/R detection deviation in points
input bool   ShowAllFractals = false;     // Show all fractals or just S/R defining ones
input int    SR_MaxLevels = 5;            // Maximum number of S/R levels to display

// Dashboard settings
input string DashboardSection = "===== Dashboard Settings ====="; // Dashboard Settings
input bool   ShowDashboard = true;        // Show dashboard panel
input int    DashboardX = 20;             // Dashboard X position
input int    DashboardY = 20;             // Dashboard Y position
input int    DashboardFontSize = 10;      // Dashboard font size
input color  DashboardColor = clrWhite;   // Dashboard text color
input color  DashboardBgColor = C'27,28,36'; // Dashboard background color
input color  DashboardBorderColor = clrDodgerBlue; // Dashboard border color
input color  DashboardHeaderColor = C'65,105,225'; // Dashboard header color

// Extended data panel settings
input string DataPanelSection = "===== Extended Data Panel Settings ====="; // Extended Data Panel
input bool   ShowExtendedPanel = true;    // Show extended data panel
input int    ExtendedPanelX = 20;         // Panel X position
input int    ExtendedPanelY = 180;        // Panel Y position - adjusted down
input int    ExtendedPanelFontSize = 9;   // Panel font size
input color  ExtendedPanelColor = clrWhite; // Panel text color
input color  ExtendedPanelBgColor = C'40,41,59'; // Panel background color
input color  ExtendedPanelBorderColor = clrMediumPurple; // Panel border color
input color  ExtendedPanelHeaderColor = C'138,43,226'; // Panel header color

// Animation settings
input string AnimationSection = "===== Animation Settings ====="; // Animation Settings
input bool   EnableAnimation = true;      // Enable animation effects
input int    AnimationSpeed = 500;        // Animation speed in milliseconds

// Alert settings
input string AlertsSection = "===== Alert Settings ====="; // Alert Settings
input bool   EnableAlerts = false;        // Enable alerts
input bool   EnablePushNotifications = false; // Enable push notifications
input bool   EnableEmailAlerts = false;   // Enable email alerts

// Indicator buffers
double BB_Upper_Buffer[];
double BB_Middle_Buffer[];
double BB_Lower_Buffer[];
double EMA_Fast_Buffer[];
double EMA_Slow_Buffer[];
double Buy_Signal_Buffer[];
double Sell_Signal_Buffer[];
double Squeeze_Color_Buffer[];
double Squeeze_Buffer[];
double Signal_Strength_Buffer[];
double Signal_Strength_Color_Buffer[];
double Upper_Fractal_Buffer[];
double Lower_Fractal_Buffer[];
double Support_Level_Buffer[];
double Resistance_Level_Buffer[];
double Trend_Strength_Buffer[];
double ADX_Buffer[];
double RSI_Buffer[];

// Additional buffers (not plotted)
double ATR_Buffer[];
long Volume_Buffer[];
double BB_Width_Buffer[];

// Indicator handles
int BB_Handle;
int EMA_Fast_Handle;
int EMA_Slow_Handle;
int ATR_Handle;
int Fractal_Up_Handle;
int Fractal_Down_Handle;
int ADX_Handle;
int RSI_Handle;

// Support/Resistance levels
struct SRLevel {
   double price;
   datetime time;
   bool isSupport;
   int strength;
   int touches;
};

SRLevel SRLevels[];

// Dashboard objects
string ObjectPrefix = "FGScalpingPro_";
string FontName = "Arial";
color Buy_Color = clrLime;
color Strong_Buy_Color = clrGreen;
color Sell_Color = clrRed;
color Strong_Sell_Color = clrMaroon;
color Neutral_Color = clrGray;
datetime LastAnimationTime = 0; // For animation timing

// Enumeration for signals
enum ENUM_SIGNAL_STRENGTH {
   SIGNAL_NEUTRAL = 0,    // Neutral
   SIGNAL_BUY = 1,        // Buy
   SIGNAL_STRONG_BUY = 2, // Strong Buy
   SIGNAL_SELL = 3,       // Sell
   SIGNAL_STRONG_SELL = 4 // Strong Sell
};

// Enumeration for market conditions (expanded for more accuracy)
enum ENUM_MARKET_CONDITION {
   MARKET_NEUTRAL = 0,        // Neutral
   MARKET_BULLISH = 1,        // Bullish
   MARKET_STRONGLY_BULLISH = 2, // Strongly Bullish
   MARKET_BEARISH = 3,        // Bearish
   MARKET_STRONGLY_BEARISH = 4, // Strongly Bearish
   MARKET_RANGING = 5,        // Ranging/Consolidating
   MARKET_VOLATILE = 6,       // Volatile/Unstable
   MARKET_BREAKOUT = 7,       // Breakout Potential
   MARKET_REVERSAL = 8        // Potential Reversal
};

// Global variables
ENUM_SIGNAL_STRENGTH CurrentSignal = SIGNAL_NEUTRAL;
string SignalText = "NEUTRAL";
color SignalColor = Neutral_Color;
datetime LastAlertTime = 0;
datetime LastSignalTime = 0;
bool SignalChanged = false;
int WinProbability = 50; // Default win probability
int RiskProbability = 50; // Default risk probability
ENUM_MARKET_CONDITION CurrentMarketCondition = MARKET_NEUTRAL;
string MarketConditionText = "NEUTRAL";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit() {
   // Set indicator buffers
   SetIndexBuffer(0, BB_Upper_Buffer, INDICATOR_DATA);
   SetIndexBuffer(1, BB_Middle_Buffer, INDICATOR_DATA);
   SetIndexBuffer(2, BB_Lower_Buffer, INDICATOR_DATA);
   SetIndexBuffer(3, EMA_Fast_Buffer, INDICATOR_DATA);
   SetIndexBuffer(4, EMA_Slow_Buffer, INDICATOR_DATA);
   SetIndexBuffer(5, Buy_Signal_Buffer, INDICATOR_DATA);
   SetIndexBuffer(6, Sell_Signal_Buffer, INDICATOR_DATA);
   SetIndexBuffer(7, Squeeze_Buffer, INDICATOR_DATA);
   SetIndexBuffer(8, Squeeze_Color_Buffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(9, Signal_Strength_Buffer, INDICATOR_DATA);
   SetIndexBuffer(10, Signal_Strength_Color_Buffer, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(11, Upper_Fractal_Buffer, INDICATOR_DATA);
   SetIndexBuffer(12, Lower_Fractal_Buffer, INDICATOR_DATA);
   SetIndexBuffer(13, Support_Level_Buffer, INDICATOR_DATA);
   SetIndexBuffer(14, Resistance_Level_Buffer, INDICATOR_DATA);
   SetIndexBuffer(15, Trend_Strength_Buffer, INDICATOR_DATA);
   SetIndexBuffer(16, ATR_Buffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(17, RSI_Buffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(18, BB_Width_Buffer, INDICATOR_CALCULATIONS);
   
   // Set arrow codes for buy/sell signals and fractals
   PlotIndexSetInteger(5, PLOT_ARROW, 233); // Buy arrow
   PlotIndexSetInteger(6, PLOT_ARROW, 234); // Sell arrow
   PlotIndexSetInteger(10, PLOT_ARROW, 119); // Upper fractal (up triangle)
   PlotIndexSetInteger(11, PLOT_ARROW, 119); // Lower fractal (down triangle)
   
   // Initialize indicator handles
   BB_Handle = iBands(_Symbol, PERIOD_CURRENT, BB_Period, BB_Shift, BB_Deviation, PRICE_CLOSE);
   EMA_Fast_Handle = iMA(_Symbol, PERIOD_CURRENT, EMA_Fast_Period, 0, MODE_EMA, PRICE_CLOSE);
   EMA_Slow_Handle = iMA(_Symbol, PERIOD_CURRENT, EMA_Slow_Period, 0, MODE_EMA, PRICE_CLOSE);
   ATR_Handle = iATR(_Symbol, PERIOD_CURRENT, ATR_Period);
   Fractal_Up_Handle = iFractals(_Symbol, PERIOD_CURRENT);
   Fractal_Down_Handle = iFractals(_Symbol, PERIOD_CURRENT);
   ADX_Handle = iADX(_Symbol, PERIOD_CURRENT, 14); // ADX with default period of 14
   RSI_Handle = iRSI(_Symbol, PERIOD_CURRENT, RSI_Period, PRICE_CLOSE); // RSI handle
   
   // Check indicator handles
   if(BB_Handle == INVALID_HANDLE || 
      EMA_Fast_Handle == INVALID_HANDLE || 
      EMA_Slow_Handle == INVALID_HANDLE || 
      ATR_Handle == INVALID_HANDLE ||
      Fractal_Up_Handle == INVALID_HANDLE ||
      Fractal_Down_Handle == INVALID_HANDLE ||
      ADX_Handle == INVALID_HANDLE ||
      RSI_Handle == INVALID_HANDLE) {
      Print("Error creating indicator handles: ", GetLastError());
      return(INIT_FAILED);
   }
   
   // Set indicator name and short name
   string short_name = "FG ScalpingPro Indicator";
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   
   // Set indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   
   // Initialize S/R levels array
   ArrayResize(SRLevels, 0);
   
   // Initialize dashboard and extended panel
   if(ShowDashboard) {
      CreateDashboard();
   }
   
   if(ShowExtendedPanel) {
      CreateExtendedPanel();
   }
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   // Release indicator handles
   IndicatorRelease(BB_Handle);
   IndicatorRelease(EMA_Fast_Handle);
   IndicatorRelease(EMA_Slow_Handle);
   IndicatorRelease(ATR_Handle);
   IndicatorRelease(Fractal_Up_Handle);
   IndicatorRelease(Fractal_Down_Handle);
   IndicatorRelease(ADX_Handle);
   IndicatorRelease(RSI_Handle);
   
   // Remove dashboard objects
   ObjectsDeleteAll(0, ObjectPrefix);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
               const int prev_calculated,
               const datetime &time[],
               const double &open[],
               const double &high[],
               const double &low[],
               const double &close[],
               const long &tick_volume[],
               const long &volume[],
               const int &spread[]) {

   // Check for rates total
   if(rates_total < BB_Period + 5) return(0);
   
   // Calculate start position
   int start;
   if(prev_calculated == 0) {
      start = BB_Period + 5;
      
      // Initialize buffers with empty values
      ArrayInitialize(BB_Upper_Buffer, EMPTY_VALUE);
      ArrayInitialize(BB_Middle_Buffer, EMPTY_VALUE);
      ArrayInitialize(BB_Lower_Buffer, EMPTY_VALUE);
      ArrayInitialize(EMA_Fast_Buffer, EMPTY_VALUE);
      ArrayInitialize(EMA_Slow_Buffer, EMPTY_VALUE);
      ArrayInitialize(Buy_Signal_Buffer, EMPTY_VALUE);
      ArrayInitialize(Sell_Signal_Buffer, EMPTY_VALUE);
      ArrayInitialize(Squeeze_Buffer, 0);
      ArrayInitialize(Squeeze_Color_Buffer, 0);
      ArrayInitialize(Signal_Strength_Buffer, 0);
      ArrayInitialize(Signal_Strength_Color_Buffer, 0);
      ArrayInitialize(Upper_Fractal_Buffer, EMPTY_VALUE);
      ArrayInitialize(Lower_Fractal_Buffer, EMPTY_VALUE);
      ArrayInitialize(Support_Level_Buffer, EMPTY_VALUE);
      ArrayInitialize(Resistance_Level_Buffer, EMPTY_VALUE);
      ArrayInitialize(Trend_Strength_Buffer, 0);
      ArrayInitialize(ATR_Buffer, EMPTY_VALUE);
      ArrayInitialize(RSI_Buffer, EMPTY_VALUE);
      ArrayResize(Volume_Buffer, rates_total);
      ArrayInitialize(Volume_Buffer, 0);
      ArrayResize(BB_Width_Buffer, rates_total);
      ArrayInitialize(BB_Width_Buffer, EMPTY_VALUE);
   }
   else {
      start = prev_calculated - 1;
   }
   
   // Copy indicator data
   if(CopyBuffer(BB_Handle, 0, 0, rates_total, BB_Middle_Buffer) <= 0) return(0);
   if(CopyBuffer(BB_Handle, 1, 0, rates_total, BB_Upper_Buffer) <= 0) return(0);
   if(CopyBuffer(BB_Handle, 2, 0, rates_total, BB_Lower_Buffer) <= 0) return(0);
   if(CopyBuffer(EMA_Fast_Handle, 0, 0, rates_total, EMA_Fast_Buffer) <= 0) return(0);
   if(CopyBuffer(EMA_Slow_Handle, 0, 0, rates_total, EMA_Slow_Buffer) <= 0) return(0);
   if(CopyBuffer(ATR_Handle, 0, 0, rates_total, ATR_Buffer) <= 0) return(0);
   if(CopyBuffer(RSI_Handle, 0, 0, rates_total, RSI_Buffer) <= 0) return(0);
   
   // Copy fractal data
   if(CopyBuffer(Fractal_Up_Handle, 0, 0, rates_total, Upper_Fractal_Buffer) <= 0) return(0);
   if(CopyBuffer(Fractal_Down_Handle, 1, 0, rates_total, Lower_Fractal_Buffer) <= 0) return(0);
   
   // Copy ADX data
   double adx_main[], adx_plus[], adx_minus[];
   ArraySetAsSeries(adx_main, true);
   ArrayResize(adx_main, rates_total);
   if(CopyBuffer(ADX_Handle, 0, 0, rates_total, adx_main) <= 0) return(0);
   
   // Copy volume data directly from function parameter
   for(int i = 0; i < rates_total; i++) {
      if(i < ArraySize(tick_volume)) {
         Volume_Buffer[i] = tick_volume[i];
      }
   }
   
   // Initialize signal changed flag
   SignalChanged = false;
   
   // Find support and resistance levels
   if(prev_calculated == 0 || rates_total % 50 == 0) { // Recalculate periodically to reduce CPU load
      DetectSupportResistanceLevels(high, low, close, time, rates_total);
   }
   
   // Apply existing S/R levels to buffers
   ApplySupportResistanceLevels(rates_total);
   
   // Loop through bars for calculations
   for(int i = Fractal_Period; i < rates_total; i++) {
      // Calculate Bollinger Band width
      BB_Width_Buffer[i] = BB_Upper_Buffer[i] - BB_Lower_Buffer[i];
      
      // Calculate squeeze conditions
      bool is_bb_squeeze = false;
      if(i >= 3) {
         is_bb_squeeze = BB_Width_Buffer[i] < BB_Width_Buffer[i-1] && 
                         BB_Width_Buffer[i-1] < BB_Width_Buffer[i-2];
      }
      
      // Set squeeze buffer and color
      Squeeze_Buffer[i] = (high[i] + low[i]) / 2; // Middle of the candle
      
      if(is_bb_squeeze) {
         Squeeze_Color_Buffer[i] = 2; // Purple for squeeze
      }
      else if(BB_Width_Buffer[i] < BB_Width_Buffer[i-1]) {
         Squeeze_Color_Buffer[i] = 1; // Orange for narrowing bands
      }
      else {
         Squeeze_Color_Buffer[i] = 0; // Silver for normal
      }
      
      // Calculate trend strength based on ADX
      if(i < ArraySize(adx_main)) {
         Trend_Strength_Buffer[i] = adx_main[i] / 10.0;
      }
   }
   
   // Generate signals
   for(int i = start; i < rates_total; i++) {
      // Initialize signal buffers
      Buy_Signal_Buffer[i] = EMPTY_VALUE;
      Sell_Signal_Buffer[i] = EMPTY_VALUE;
      
      // Skip if not enough bars
      if(i < 3) continue;
      
      // Calculate Volume SMA
      double volume_sma = 0;
      if(i >= Volume_Period) {
         long volume_sum = 0;
         for(int j = 0; j < Volume_Period; j++) {
            volume_sum += Volume_Buffer[i - j];
         }
         volume_sma = (double)volume_sum / Volume_Period;
      }
      
      // Check for Bollinger squeeze
      bool is_bb_squeeze = false;
      if(ShowBollingerSqueeze) {
         is_bb_squeeze = BB_Width_Buffer[i] < BB_Width_Buffer[i-1] && 
                         BB_Width_Buffer[i-1] < BB_Width_Buffer[i-2];
      }
      else {
         is_bb_squeeze = true; // Skip squeeze check if disabled
      }
      
      // Check volume filter
      bool volume_ok = true;
      if(EnableVolumeFilter && volume_sma > 0) {
         volume_ok = Volume_Buffer[i] > volume_sma;
      }
      
      // Check ATR filter
      bool atr_ok = ATR_Buffer[i] * _Point > ATR_MinValue * _Point;
      
      // Check RSI filter
      bool rsi_ok = true;
      if(UseRSIFilter) {
         // For buy signals, RSI should be coming up from oversold or in bullish territory
         // For sell signals, RSI should be coming down from overbought or in bearish territory
         if(EMA_Fast_Buffer[i] > EMA_Slow_Buffer[i]) { // Bullish trend check
            rsi_ok = RSI_Buffer[i] > RSI_Buffer[i-1] || RSI_Buffer[i] > 50;
         } else if(EMA_Fast_Buffer[i] < EMA_Slow_Buffer[i]) { // Bearish trend check
            rsi_ok = RSI_Buffer[i] < RSI_Buffer[i-1] || RSI_Buffer[i] < 50;
         }
      }
      
      // Calculate trend strength
      double trend_strength = 0;
      if(EMA_Fast_Buffer[i] > EMA_Slow_Buffer[i]) {
         trend_strength = (EMA_Fast_Buffer[i] - EMA_Slow_Buffer[i]) / _Point;
      }
      else if(EMA_Fast_Buffer[i] < EMA_Slow_Buffer[i]) {
         trend_strength = (EMA_Slow_Buffer[i] - EMA_Fast_Buffer[i]) / _Point;
         trend_strength = -trend_strength; // Negative for downtrend
      }
      
      // Calculate distance to nearest support/resistance
      double distToSupport = DistanceToNearestLevel(close[i], false);
      double distToResistance = DistanceToNearestLevel(close[i], true);
      bool nearSupport = (distToSupport > 0 && distToSupport < 20 * _Point);
      bool nearResistance = (distToResistance > 0 && distToResistance < 20 * _Point);
      
      // Determine signal strength
      ENUM_SIGNAL_STRENGTH signal_strength = SIGNAL_NEUTRAL;
      
      // Calculate win probability in real-time for EVERY bar
      // This ensures probability is always updated, not just on signals
      CalculateWinProbability(i, close[i], trend_strength, nearSupport, nearResistance, is_bb_squeeze, volume_ok, atr_ok, rsi_ok);
      
      // Buy signal conditions
      if(EMA_Fast_Buffer[i] > EMA_Slow_Buffer[i]) { // Bullish trend
         if(close[i-1] <= EMA_Slow_Buffer[i-1] && close[i] > EMA_Slow_Buffer[i] && // Price bounce
            is_bb_squeeze && // Bollinger squeeze
            volume_ok && // Volume filter
            atr_ok && // ATR filter
            rsi_ok) { // RSI filter
            Buy_Signal_Buffer[i] = low[i] - 5 * _Point; // Place arrow below candle
            
            // Strong buy conditions
            bool strongBuy = close[i] > BB_Upper_Buffer[i] && trend_strength > 20;
            
            // Adjust signal based on S/R levels
            if(nearResistance) {
               signal_strength = SIGNAL_BUY; // Normal buy when near resistance (caution)
            }
            else if(nearSupport) {
               signal_strength = strongBuy ? SIGNAL_STRONG_BUY : SIGNAL_BUY;
            }
            else {
               signal_strength = strongBuy ? SIGNAL_STRONG_BUY : SIGNAL_BUY;
            }
         }
         else if(trend_strength > 10 && nearSupport) {
            signal_strength = SIGNAL_BUY; // Support bounce signal based on trend
         }
      }
      
      // Sell signal conditions
      if(EMA_Fast_Buffer[i] < EMA_Slow_Buffer[i]) { // Bearish trend
         if(close[i-1] >= EMA_Slow_Buffer[i-1] && close[i] < EMA_Slow_Buffer[i] && // Price rejection
            is_bb_squeeze && // Bollinger squeeze
            volume_ok && // Volume filter
            atr_ok && // ATR filter
            rsi_ok) { // RSI filter
            Sell_Signal_Buffer[i] = high[i] + 5 * _Point; // Place arrow above candle
            
            // Strong sell conditions
            bool strongSell = close[i] < BB_Lower_Buffer[i] && trend_strength < -20;
            
            // Adjust signal based on S/R levels
            if(nearSupport) {
               signal_strength = SIGNAL_SELL; // Normal sell when near support (caution)
            }
            else if(nearResistance) {
               signal_strength = strongSell ? SIGNAL_STRONG_SELL : SIGNAL_SELL;
            }
            else {
               signal_strength = strongSell ? SIGNAL_STRONG_SELL : SIGNAL_SELL;
            }
         }
         else if(trend_strength < -10 && nearResistance) {
            signal_strength = SIGNAL_SELL; // Resistance rejection signal based on trend
         }
      }
      
      // Set signal strength buffer
      Signal_Strength_Buffer[i] = 0.5 * trend_strength / 10.0; // Scale for display
      Signal_Strength_Color_Buffer[i] = signal_strength;
      
      // Update current signal for the latest bar
      if(i == rates_total - 1) {
         // Calculate market condition in real-time
         CalculateMarketCondition(i, close[i], trend_strength, nearSupport, nearResistance, is_bb_squeeze, adx_main[i], ATR_Buffer[i]);
         
         // Check if signal has changed
         if(CurrentSignal != signal_strength) {
            SignalChanged = true;
            LastSignalTime = time[i];
         }
         
         CurrentSignal = signal_strength;
         
         // Set signal text and color
         switch(CurrentSignal) {
            case SIGNAL_BUY:
               SignalText = "BUY";
               SignalColor = Buy_Color;
               break;
            case SIGNAL_STRONG_BUY:
               SignalText = "STRONG BUY";
               SignalColor = Strong_Buy_Color;
               break;
            case SIGNAL_SELL:
               SignalText = "SELL";
               SignalColor = Sell_Color;
               break;
            case SIGNAL_STRONG_SELL:
               SignalText = "STRONG SELL";
               SignalColor = Strong_Sell_Color;
               break;
            default:
               SignalText = "NEUTRAL";
               SignalColor = Neutral_Color;
               break;
         }
         
         // Calculate risk probability (always the inverse of win probability)
         RiskProbability = 100 - WinProbability;
         
         // Update dashboard and extended panel
         if(ShowDashboard) {
            UpdateDashboard(close[i], volume_sma, ATR_Buffer[i], is_bb_squeeze, time[i]);
         }
         
         if(ShowExtendedPanel) {
            UpdateExtendedPanel(close[i], trend_strength, time[i], ATR_Buffer[i], adx_main[i]);
         }
         
         // Send alerts if enabled and signal has changed
         if(EnableAlerts && SignalChanged && CurrentSignal != SIGNAL_NEUTRAL) {
            SendAlerts();
         }
      }
   }
   
   // Return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Calculate win probability based on all market conditions          |
//+------------------------------------------------------------------+
void CalculateWinProbability(int index, double price, double trend_strength, bool nearSupport, bool nearResistance, 
                            bool is_squeeze, bool volume_ok, bool atr_ok, bool rsi_ok) {
   // Start with base probability
   int probability = 50;
   
   // Strong trend gives higher probability
   if(MathAbs(trend_strength) > 20) {
      probability += 10;
   }
   else if(MathAbs(trend_strength) > 10) {
      probability += 5;
   }
   
   // RSI conditions
   if(RSI_Buffer[index] >= RSI_Overbought) {
      if(EMA_Fast_Buffer[index] < EMA_Slow_Buffer[index]) {
         // Overbought in bearish trend - good for sell signals
         probability += 10;
      }
      else {
         // Overbought in bullish trend - caution
         probability -= 5;
      }
   }
   else if(RSI_Buffer[index] <= RSI_Oversold) {
      if(EMA_Fast_Buffer[index] > EMA_Slow_Buffer[index]) {
         // Oversold in bullish trend - good for buy signals
         probability += 10;
      }
      else {
         // Oversold in bearish trend - caution
         probability -= 5;
      }
   }
   else if(RSI_Buffer[index] > 50 && RSI_Buffer[index] < RSI_Overbought) {
      if(EMA_Fast_Buffer[index] > EMA_Slow_Buffer[index]) {
         // Bullish RSI in bullish trend
         probability += 5;
      }
   }
   else if(RSI_Buffer[index] < 50 && RSI_Buffer[index] > RSI_Oversold) {
      if(EMA_Fast_Buffer[index] < EMA_Slow_Buffer[index]) {
         // Bearish RSI in bearish trend
         probability += 5;
      }
   }
   
   // Support/Resistance considerations
   if(EMA_Fast_Buffer[index] > EMA_Slow_Buffer[index]) { // Bullish trend
      if(nearSupport) {
         // Price near support in bullish trend - good for bounce
         probability += 8;
      }
      else if(nearResistance) {
         // Price near resistance in bullish trend - caution
         probability -= 5;
      }
   }
   else if(EMA_Fast_Buffer[index] < EMA_Slow_Buffer[index]) { // Bearish trend
      if(nearResistance) {
         // Price near resistance in bearish trend - good for rejection
         probability += 8;
      }
      else if(nearSupport) {
         // Price near support in bearish trend - caution
         probability -= 5;
      }
   }
   
   // Volatility factors
   if(is_squeeze) {
      // Bollinger squeeze indicates potential breakout
      probability += 3;
   }
   
   // Volume and ATR
   if(volume_ok && atr_ok) {
      // Good volume and adequate volatility
      probability += 4;
   }
   else if(!volume_ok && atr_ok) {
      // Low volume but adequate volatility
      probability -= 2;
   }
   else if(volume_ok && !atr_ok) {
      // Good volume but low volatility
      probability -= 3;
   }
   else {
      // Low volume and low volatility
      probability -= 5;
   }
   
   // ADX strength check - get ADX from buffer
   double adx = 0;
   if(index < ArraySize(ADX_Buffer)) {
      adx = ADX_Buffer[index];
      
      if(adx > 40) {
         // Strong trend - higher probability
         probability += 5;
      }
      else if(adx < 20) {
         // Weak trend - lower probability
         probability -= 2;
      }
   }
   
   // Ensure probability stays within bounds
   WinProbability = MathMax(MathMin(probability, 95), 5);
   RiskProbability = 100 - WinProbability;
}

//+------------------------------------------------------------------+
//| Calculate market condition based on comprehensive analysis        |
//+------------------------------------------------------------------+
void CalculateMarketCondition(int index, double price, double trend_strength, bool nearSupport, 
                             bool nearResistance, bool is_squeeze, double adx, double atr) {
   // Get current trend direction
   bool bullishTrend = EMA_Fast_Buffer[index] > EMA_Slow_Buffer[index];
   bool bearishTrend = EMA_Fast_Buffer[index] < EMA_Slow_Buffer[index];
   
   // Default to neutral
   CurrentMarketCondition = MARKET_NEUTRAL;
   MarketConditionText = "NEUTRAL";
   
   // Check for ranging market
   if(adx < 20 && MathAbs(trend_strength) < 10) {
      CurrentMarketCondition = MARKET_RANGING;
      MarketConditionText = "RANGING/CONSOLIDATING";
      return;
   }
   
   // Check for volatility
   if(atr * _Point > ATR_MinValue * _Point * 2) {
      CurrentMarketCondition = MARKET_VOLATILE;
      MarketConditionText = "VOLATILE/UNSTABLE";
      
      // Check for potential breakout conditions
      if(is_squeeze && adx > 25) {
         CurrentMarketCondition = MARKET_BREAKOUT;
         MarketConditionText = "POTENTIAL BREAKOUT";
         return;
      }
   }
   
   // Check for potential reversal patterns
   if((bullishTrend && RSI_Buffer[index] < 40 && RSI_Buffer[index] > RSI_Buffer[index-1] && nearSupport) ||
      (bearishTrend && RSI_Buffer[index] > 60 && RSI_Buffer[index] < RSI_Buffer[index-1] && nearResistance)) {
      CurrentMarketCondition = MARKET_REVERSAL;
      MarketConditionText = "POTENTIAL REVERSAL";
      return;
   }
   
   // Strong trends
   if(bullishTrend) {
      if(trend_strength > 20 && adx > 30 && RSI_Buffer[index] > 50) {
         CurrentMarketCondition = MARKET_STRONGLY_BULLISH;
         MarketConditionText = "STRONGLY BULLISH";
      } else {
         CurrentMarketCondition = MARKET_BULLISH;
         MarketConditionText = "BULLISH";
      }
   } else if(bearishTrend) {
      if(trend_strength < -20 && adx > 30 && RSI_Buffer[index] < 50) {
         CurrentMarketCondition = MARKET_STRONGLY_BEARISH;
         MarketConditionText = "STRONGLY BEARISH";
      } else {
         CurrentMarketCondition = MARKET_BEARISH;
         MarketConditionText = "BEARISH";
      }
   }
}

//+------------------------------------------------------------------+
//| Create dashboard panel                                            |
//+------------------------------------------------------------------+
void CreateDashboard() {
   // Calculate dynamic sizes based on content and font size
   int panelWidth = 300;
   int rowHeight = DashboardFontSize + 10;
   int headerHeight = DashboardFontSize + 20;
   int numRows = 6; // Number of data rows
   int padding = 10;
   int totalHeight = headerHeight + (numRows * rowHeight) + (padding * 2);
   
   // Create main panel with rounded corners and gradient effect
   string name = ObjectPrefix + "Panel";
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, DashboardX);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, DashboardY);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, panelWidth);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, totalHeight);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, DashboardBgColor);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_COLOR, DashboardBorderColor);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
   }
   
   // Add shadow effect for modern look
   name = ObjectPrefix + "PanelShadow";
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, DashboardX + 5);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, DashboardY + 5);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, panelWidth);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, totalHeight);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrBlack);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, -1);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, C'0,0,0,40'); // Semi-transparent
   }
   
   // Title background
   name = ObjectPrefix + "TitleBg";
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, DashboardX);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, DashboardY);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, panelWidth);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, headerHeight);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, DashboardHeaderColor);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_COLOR, DashboardHeaderColor);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 1);
   }
   
   // Animated accent bar
   name = ObjectPrefix + "AccentBar";
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, DashboardX);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, DashboardY + headerHeight);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, panelWidth);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, 2);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, DashboardBorderColor);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_COLOR, DashboardBorderColor);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 2);
   }
   
   // Title
   name = ObjectPrefix + "Title";
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, DashboardX + 10);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, DashboardY + 7);
      ObjectSetString(0, name, OBJPROP_TEXT, "FG ScalpingPro Dashboard");
      ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, DashboardFontSize + 2);
      ObjectSetInteger(0, name, OBJPROP_COLOR, DashboardColor);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 3);
   }
   
   // Create labels for data display
   string labels[] = {"Current Price:", "Signal:", "Trend Direction:", "Volatility (ATR):", "Volume Status:", "Market Condition:"};
   
   for(int i = 0; i < ArraySize(labels); i++) {
      name = ObjectPrefix + "Label" + IntegerToString(i);
      if(ObjectFind(0, name) < 0) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, DashboardX + 10);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, DashboardY + headerHeight + 5 + i * rowHeight);
         ObjectSetString(0, name, OBJPROP_TEXT, labels[i]);
         ObjectSetString(0, name, OBJPROP_FONT, FontName);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, DashboardFontSize);
         ObjectSetInteger(0, name, OBJPROP_COLOR, DashboardColor);
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_ZORDER, 3);
      }
      
      name = ObjectPrefix + "Value" + IntegerToString(i);
      if(ObjectFind(0, name) < 0) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, DashboardX + 150);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, DashboardY + headerHeight + 5 + i * rowHeight);
         ObjectSetString(0, name, OBJPROP_TEXT, "---");
         ObjectSetString(0, name, OBJPROP_FONT, FontName);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, DashboardFontSize);
         ObjectSetInteger(0, name, OBJPROP_COLOR, DashboardColor);
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_ZORDER, 3);
      }
   }
}

//+------------------------------------------------------------------+
//| Update dashboard with current data                                |
//+------------------------------------------------------------------+
void UpdateDashboard(double price, double volume_avg, double atr, bool is_squeeze, datetime current_time) {
   // Update animation if enabled
   if(EnableAnimation && TimeCurrent() - LastAnimationTime > AnimationSpeed / 1000.0) {
      AnimateDashboard();
      LastAnimationTime = TimeCurrent();
   }

   // Update price
   string name = ObjectPrefix + "Value0";
   ObjectSetString(0, name, OBJPROP_TEXT, DoubleToString(price, _Digits));
   
   // Update signal
   name = ObjectPrefix + "Value1";
   ObjectSetString(0, name, OBJPROP_TEXT, SignalText);
   ObjectSetInteger(0, name, OBJPROP_COLOR, SignalColor);
   
   // Update trend
   name = ObjectPrefix + "Value2";
   string trend = "NEUTRAL";
   color trend_color = Neutral_Color;
   
   if(EMA_Fast_Buffer[0] > EMA_Slow_Buffer[0]) {
      trend = "BULLISH";
      trend_color = Buy_Color;
   }
   else if(EMA_Fast_Buffer[0] < EMA_Slow_Buffer[0]) {
      trend = "BEARISH";
      trend_color = Sell_Color;
   }
   
   ObjectSetString(0, name, OBJPROP_TEXT, trend);
   ObjectSetInteger(0, name, OBJPROP_COLOR, trend_color);
   
   // Update ATR
   name = ObjectPrefix + "Value3";
   string atr_text = DoubleToString(atr, _Digits) + " (" + (atr * _Point > ATR_MinValue * _Point ? "ACTIVE" : "LOW") + ")";
   color atr_color = atr * _Point > ATR_MinValue * _Point ? clrWhite : clrGray;
   ObjectSetString(0, name, OBJPROP_TEXT, atr_text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, atr_color);
   
   // Update volume
   name = ObjectPrefix + "Value4";
   string vol_text = Volume_Buffer[0] > volume_avg ? "ABOVE AVERAGE" : "BELOW AVERAGE";
   color vol_color = Volume_Buffer[0] > volume_avg ? clrWhite : clrGray;
   ObjectSetString(0, name, OBJPROP_TEXT, vol_text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, vol_color);
   
   // Update Market Condition
   name = ObjectPrefix + "Value5";
   ObjectSetString(0, name, OBJPROP_TEXT, MarketConditionText);
   
   // Set market condition color
   color condition_color = Neutral_Color;
   switch(CurrentMarketCondition) {
      case MARKET_BULLISH:
         condition_color = Buy_Color;
         break;
      case MARKET_STRONGLY_BULLISH:
         condition_color = Strong_Buy_Color;
         break;
      case MARKET_BEARISH:
         condition_color = Sell_Color;
         break;
      case MARKET_STRONGLY_BEARISH:
         condition_color = Strong_Sell_Color;
         break;
      case MARKET_RANGING:
         condition_color = clrYellow;
         break;
      case MARKET_VOLATILE:
         condition_color = clrOrange;
         break;
      case MARKET_BREAKOUT:
         condition_color = clrMagenta;
         break;
      case MARKET_REVERSAL:
         condition_color = clrAqua;
         break;
      default:
         condition_color = Neutral_Color;
         break;
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, condition_color);
}

//+------------------------------------------------------------------+
//| Animate dashboard elements for modern look                        |
//+------------------------------------------------------------------+
void AnimateDashboard() {
   // Animated color transitions for accent bar based on current signal
   string name = ObjectPrefix + "AccentBar";
   
   // Get current color
   color currentColor = (color)ObjectGetInteger(0, name, OBJPROP_BGCOLOR);
   color targetColor;
   
   // Determine target color based on signal
   switch(CurrentSignal) {
      case SIGNAL_BUY:
         targetColor = Buy_Color;
         break;
      case SIGNAL_STRONG_BUY:
         targetColor = Strong_Buy_Color;
         break;
      case SIGNAL_SELL:
         targetColor = Sell_Color;
         break;
      case SIGNAL_STRONG_SELL:
         targetColor = Strong_Sell_Color;
         break;
      default:
         targetColor = DashboardBorderColor;
         break;
   }
   
   // Apply color transition
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, targetColor);
   ObjectSetInteger(0, name, OBJPROP_COLOR, targetColor);
   
   // Pulse effect for signal value when signal changes
   if(SignalChanged) {
      name = ObjectPrefix + "Value1";
      
      // Temporarily increase font size for pulse effect
      int currentSize = (int)ObjectGetInteger(0, name, OBJPROP_FONTSIZE);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, currentSize + 2);
      
      // Reset after a brief delay - using EventSetTimer instead of undeclared ObjectSetTimer
      EventSetTimer(0.5);  // 0.5 seconds delay
      
      // Will reset in the next animation cycle
   }
   else {
      // Reset font size if needed
      name = ObjectPrefix + "Value1";
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, DashboardFontSize);
   }
}

//+------------------------------------------------------------------+
//| Create extended panel with support/resistance and probabilities   |
//+------------------------------------------------------------------+
void CreateExtendedPanel() {
   // Calculate dynamic sizes based on content and font size
   int panelWidth = 300;
   int rowHeight = ExtendedPanelFontSize + 10;
   int headerHeight = ExtendedPanelFontSize + 20;
   int numRows = 14; // Number of data rows in extended panel
   int padding = 10;
   int totalHeight = headerHeight + (numRows * rowHeight) + (padding * 2);
   
   // Create main panel with rounded corners
   string name = ObjectPrefix + "ExtPanel";
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, ExtendedPanelX);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, ExtendedPanelY);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, panelWidth);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, totalHeight);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, ExtendedPanelBgColor);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_COLOR, ExtendedPanelBorderColor);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
   }
   
   // Add shadow effect for modern look
   name = ObjectPrefix + "ExtPanelShadow";
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, ExtendedPanelX + 5);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, ExtendedPanelY + 5);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, panelWidth);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, totalHeight);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrBlack);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, -1);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, C'0,0,0,40'); // Semi-transparent
   }
   
   // Title background
   name = ObjectPrefix + "ExtTitleBg";
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, ExtendedPanelX);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, ExtendedPanelY);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, panelWidth);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, headerHeight);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, ExtendedPanelHeaderColor);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_COLOR, ExtendedPanelHeaderColor);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 1);
   }
   
   // Animated accent bar
   name = ObjectPrefix + "ExtAccentBar";
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, ExtendedPanelX);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, ExtendedPanelY + headerHeight);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, panelWidth);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, 2);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, ExtendedPanelBorderColor);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_COLOR, ExtendedPanelBorderColor);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 2);
   }
   
   // Title
   name = ObjectPrefix + "ExtTitle";
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, ExtendedPanelX + 10);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, ExtendedPanelY + 7);
      ObjectSetString(0, name, OBJPROP_TEXT, "FGTrading Advanced Market Analysis");
      ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, ExtendedPanelFontSize + 2);
      ObjectSetInteger(0, name, OBJPROP_COLOR, ExtendedPanelColor);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 3);
   }
   
   // Create labels for extended data display
   string extLabels[] = {
      "Market Condition:", 
      "Win Probability:", 
      "Risk Probability:", 
      "RSI Value:", 
      "Trend Strength (ADX):", 
      "Support Level 1:", 
      "Support Level 2:", 
      "Resistance Level 1:", 
      "Resistance Level 2:",
      "Distance to Support:",
      "Distance to Resistance:",
      "Recommended Action:",
      "Target TP (pips):",
      "Recommended SL (pips):"
   };
   
   for(int i = 0; i < ArraySize(extLabels); i++) {
      name = ObjectPrefix + "ExtLabel" + IntegerToString(i);
      if(ObjectFind(0, name) < 0) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, ExtendedPanelX + 10);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, ExtendedPanelY + 40 + i * 20);
         ObjectSetString(0, name, OBJPROP_TEXT, extLabels[i]);
         ObjectSetString(0, name, OBJPROP_FONT, FontName);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, ExtendedPanelFontSize);
         ObjectSetInteger(0, name, OBJPROP_COLOR, ExtendedPanelColor);
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_ZORDER, 1);
      }
      
      name = ObjectPrefix + "ExtValue" + IntegerToString(i);
      if(ObjectFind(0, name) < 0) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, name, OBJPROP_XDISTANCE, ExtendedPanelX + 150);
         ObjectSetInteger(0, name, OBJPROP_YDISTANCE, ExtendedPanelY + 40 + i * 20);
         ObjectSetString(0, name, OBJPROP_TEXT, "---");
         ObjectSetString(0, name, OBJPROP_FONT, FontName);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, ExtendedPanelFontSize);
         ObjectSetInteger(0, name, OBJPROP_COLOR, ExtendedPanelColor);
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, name, OBJPROP_ZORDER, 1);
      }
   }
}

//+------------------------------------------------------------------+
//| Update extended panel with detailed analysis                     |
//+------------------------------------------------------------------+
void UpdateExtendedPanel(double price, double trend_strength, datetime current_time, double atr, double adx) {
   // Update animation for extended panel
   if(EnableAnimation && TimeCurrent() - LastAnimationTime > AnimationSpeed / 1000.0) {
      // Animated color transitions for accent bar
      string name = ObjectPrefix + "ExtAccentBar";
      
      // Get current color
      color currentColor = (color)ObjectGetInteger(0, name, OBJPROP_BGCOLOR);
      color targetColor;
      
      // Determine target color based on signal
      switch(CurrentSignal) {
         case SIGNAL_BUY:
            targetColor = Buy_Color;
            break;
         case SIGNAL_STRONG_BUY:
            targetColor = Strong_Buy_Color;
            break;
         case SIGNAL_SELL:
            targetColor = Sell_Color;
            break;
         case SIGNAL_STRONG_SELL:
            targetColor = Strong_Sell_Color;
            break;
         default:
            targetColor = ExtendedPanelBorderColor;
            break;
      }
      
      // Apply color transition
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, targetColor);
      ObjectSetInteger(0, name, OBJPROP_COLOR, targetColor);
   }

   // Market condition
   string name = ObjectPrefix + "ExtValue0";
   ObjectSetString(0, name, OBJPROP_TEXT, MarketConditionText);
   
   // Colors based on market condition
   color condition_color = Neutral_Color;
   if(MarketConditionText == "BULLISH" || MarketConditionText == "STRONGLY BULLISH") {
      condition_color = (MarketConditionText == "STRONGLY BULLISH") ? Strong_Buy_Color : Buy_Color;
   }
   else if(MarketConditionText == "BEARISH" || MarketConditionText == "STRONGLY BEARISH") {
      condition_color = (MarketConditionText == "STRONGLY BEARISH") ? Strong_Sell_Color : Sell_Color;
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, condition_color);
   
   // Win probability
   name = ObjectPrefix + "ExtValue1";
   ObjectSetString(0, name, OBJPROP_TEXT, IntegerToString(WinProbability) + "%");
   
   // Color for win probability
   color prob_color = Neutral_Color;
   if(WinProbability >= 80) prob_color = Strong_Buy_Color;
   else if(WinProbability >= 70) prob_color = Buy_Color;
   else if(WinProbability >= 60) prob_color = clrYellow;
   ObjectSetInteger(0, name, OBJPROP_COLOR, prob_color);
   
   // Risk probability
   name = ObjectPrefix + "ExtValue2";
   ObjectSetString(0, name, OBJPROP_TEXT, IntegerToString(RiskProbability) + "%");
   
   // Color for risk probability
   color risk_color = Neutral_Color;
   if(RiskProbability <= 20) risk_color = Strong_Buy_Color;
   else if(RiskProbability <= 30) risk_color = Buy_Color;
   else if(RiskProbability <= 40) risk_color = clrYellow;
   else if(RiskProbability >= 60) risk_color = Sell_Color;
   ObjectSetInteger(0, name, OBJPROP_COLOR, risk_color);
   
   // RSI value
   name = ObjectPrefix + "ExtValue3";
   string rsi_text = DoubleToString(RSI_Buffer[0], 1);
   
   // Add descriptive text based on RSI level
   if(RSI_Buffer[0] >= RSI_Overbought) rsi_text += " (OVERBOUGHT)";
   else if(RSI_Buffer[0] <= RSI_Oversold) rsi_text += " (OVERSOLD)";
   else if(RSI_Buffer[0] > 50) rsi_text += " (BULLISH)";
   else rsi_text += " (BEARISH)";
   
   ObjectSetString(0, name, OBJPROP_TEXT, rsi_text);
   
   // Color for RSI
   color rsi_color = Neutral_Color;
   if(RSI_Buffer[0] >= RSI_Overbought) rsi_color = Strong_Sell_Color;
   else if(RSI_Buffer[0] <= RSI_Oversold) rsi_color = Strong_Buy_Color;
   else if(RSI_Buffer[0] > 50) rsi_color = Buy_Color;
   else rsi_color = Sell_Color;
   ObjectSetInteger(0, name, OBJPROP_COLOR, rsi_color);
   
   // Trend strength (ADX)
   name = ObjectPrefix + "ExtValue4";
   string adx_text = DoubleToString(adx, 1);
   if(adx < 20) adx_text += " (WEAK)";
   else if(adx < 40) adx_text += " (MODERATE)";
   else adx_text += " (STRONG)";
   ObjectSetString(0, name, OBJPROP_TEXT, adx_text);
   
   // Support levels
   int supportCount = 0;
   name = ObjectPrefix + "ExtValue5";
   ObjectSetString(0, name, OBJPROP_TEXT, "---");
   name = ObjectPrefix + "ExtValue6";
   ObjectSetString(0, name, OBJPROP_TEXT, "---");
   
   // Resistance levels
   int resistanceCount = 0;
   name = ObjectPrefix + "ExtValue7";
   ObjectSetString(0, name, OBJPROP_TEXT, "---");
   name = ObjectPrefix + "ExtValue8";
   ObjectSetString(0, name, OBJPROP_TEXT, "---");
   
   // Get support and resistance levels
   for(int i = 0; i < ArraySize(SRLevels); i++) {
      if(SRLevels[i].isSupport && supportCount < 2) {
         name = ObjectPrefix + "ExtValue" + IntegerToString(5 + supportCount);
         ObjectSetString(0, name, OBJPROP_TEXT, DoubleToString(SRLevels[i].price, _Digits) + 
                                               " (Touches: " + IntegerToString(SRLevels[i].touches) + ")");
         supportCount++;
      }
      else if(!SRLevels[i].isSupport && resistanceCount < 2) {
         name = ObjectPrefix + "ExtValue" + IntegerToString(7 + resistanceCount);
         ObjectSetString(0, name, OBJPROP_TEXT, DoubleToString(SRLevels[i].price, _Digits) + 
                                               " (Touches: " + IntegerToString(SRLevels[i].touches) + ")");
         resistanceCount++;
      }
      
      if(supportCount >= 2 && resistanceCount >= 2) break;
   }
   
   // Distance to support
   double distToSupport = DistanceToNearestLevel(price, false);
   name = ObjectPrefix + "ExtValue9";
   if(distToSupport > 0) {
      ObjectSetString(0, name, OBJPROP_TEXT, DoubleToString(distToSupport / _Point, 1) + " pips");
   }
   else {
      ObjectSetString(0, name, OBJPROP_TEXT, "No support detected below");
   }
   
   // Distance to resistance
   double distToResistance = DistanceToNearestLevel(price, true);
   name = ObjectPrefix + "ExtValue10";
   if(distToResistance > 0) {
      ObjectSetString(0, name, OBJPROP_TEXT, DoubleToString(distToResistance / _Point, 1) + " pips");
   }
   else {
      ObjectSetString(0, name, OBJPROP_TEXT, "No resistance detected above");
   }
   
   // Recommended action
   name = ObjectPrefix + "ExtValue11";
   string actionText = "WAIT FOR SIGNAL";
   color actionColor = clrGray;
   
   switch(CurrentSignal) {
      case SIGNAL_BUY:
         actionText = "BUY (SET TIGHT SL)";
         actionColor = Buy_Color;
         break;
      case SIGNAL_STRONG_BUY:
         actionText = "BUY WITH CONFIDENCE";
         actionColor = Strong_Buy_Color;
         break;
      case SIGNAL_SELL:
         actionText = "SELL (SET TIGHT SL)";
         actionColor = Sell_Color;
         break;
      case SIGNAL_STRONG_SELL:
         actionText = "SELL WITH CONFIDENCE";
         actionColor = Strong_Sell_Color;
         break;
      default:
         if(distToSupport < 20 * _Point && distToSupport > 0 && MarketConditionText == "BULLISH") {
            actionText = "WAIT FOR SUPPORT BOUNCE";
            actionColor = clrYellow;
         }
         else if(distToResistance < 20 * _Point && distToResistance > 0 && MarketConditionText == "BEARISH") {
            actionText = "WAIT FOR RESISTANCE REJECTION";
            actionColor = clrYellow;
         }
         break;
   }
   
   ObjectSetString(0, name, OBJPROP_TEXT, actionText);
   ObjectSetInteger(0, name, OBJPROP_COLOR, actionColor);
   
   // Target TP
   name = ObjectPrefix + "ExtValue12";
   double tp_pips = atr * ((CurrentSignal == SIGNAL_BUY || CurrentSignal == SIGNAL_STRONG_BUY) ? 1.5 : 1.5) / _Point;
   ObjectSetString(0, name, OBJPROP_TEXT, DoubleToString(tp_pips, 1));
   
   // Recommended SL
   name = ObjectPrefix + "ExtValue13";
   double sl_pips = atr * 1.0 / _Point;
   ObjectSetString(0, name, OBJPROP_TEXT, DoubleToString(sl_pips, 1));
}

//+------------------------------------------------------------------+
//| Send alerts when signal changes                                  |
//+------------------------------------------------------------------+
void SendAlerts() {
   string alert_text = _Symbol + " " + EnumToString(Period()) + ": " + SignalText + " signal detected! Win probability: " + 
                      IntegerToString(WinProbability) + "%, Risk probability: " + IntegerToString(RiskProbability) + 
                      "%, RSI: " + DoubleToString(RSI_Buffer[0], 1);
   
   // Prevent alert spam by checking last alert time
   if(TimeCurrent() - LastAlertTime > 300) { // 5 minutes between alerts
      // Send MT5 alert
      if(EnableAlerts) {
         Alert(alert_text);
      }
      
      // Send push notification
      if(EnablePushNotifications) {
         SendNotification(alert_text);
      }
      
      // Send email
      if(EnableEmailAlerts) {
         SendMail("FG ScalpingPro Alert", alert_text);
      }
      
      LastAlertTime = TimeCurrent();
   }
}

//+------------------------------------------------------------------+
//| Detect support and resistance levels                             |
//+------------------------------------------------------------------+
void DetectSupportResistanceLevels(const double &high[], const double &low[], const double &close[], 
                                  const datetime &time[], int bars) {
   
   // Clear existing levels
   ArrayResize(SRLevels, 0);
   
   int lookbackBars = MathMin(bars, SR_LookbackPeriod);
   
   // Find significant swing highs and lows
   for(int i = Fractal_Period; i < lookbackBars - Fractal_Period; i++) {
      // Upper fractal (swing high)
      if(IsFractalUp(high, i, Fractal_Period)) {
         // Check if price is creating a swing high
         bool isSwingHigh = true;
         for(int j = i - SR_Depth; j <= i + SR_Depth; j++) {
            if(j == i || j < 0 || j >= lookbackBars) continue;
            
            // If another high is too close and higher, skip this one
            if(MathAbs(high[j] - high[i]) < SR_Deviation * _Point && high[j] > high[i]) {
               isSwingHigh = false;
               break;
            }
         }
         
         // Add to S/R levels if it's a significant swing high
         if(isSwingHigh || ShowAllFractals) {
            Upper_Fractal_Buffer[i] = high[i]; // Mark fractal on chart
            
            // Only add significant levels to S/R array
            if(isSwingHigh) {
               int levelIndex = ArraySize(SRLevels);
               ArrayResize(SRLevels, levelIndex + 1);
               
               SRLevels[levelIndex].price = high[i];
               SRLevels[levelIndex].time = time[i];
               SRLevels[levelIndex].isSupport = false; // Resistance
               SRLevels[levelIndex].strength = 1;
               SRLevels[levelIndex].touches = CountTouches(high, low, close, high[i], lookbackBars, false);
            }
         }
      }
      
      // Lower fractal (swing low)
      if(IsFractalDown(low, i, Fractal_Period)) {
         // Check if price is creating a swing low
         bool isSwingLow = true;
         for(int j = i - SR_Depth; j <= i + SR_Depth; j++) {
            if(j == i || j < 0 || j >= lookbackBars) continue;
            
            // If another low is too close and lower, skip this one
            if(MathAbs(low[j] - low[i]) < SR_Deviation * _Point && low[j] < low[i]) {
               isSwingLow = false;
               break;
            }
         }
         
         // Add to S/R levels if it's a significant swing low
         if(isSwingLow || ShowAllFractals) {
            Lower_Fractal_Buffer[i] = low[i]; // Mark fractal on chart
            
            // Only add significant levels to S/R array
            if(isSwingLow) {
               int levelIndex = ArraySize(SRLevels);
               ArrayResize(SRLevels, levelIndex + 1);
               
               SRLevels[levelIndex].price = low[i];
               SRLevels[levelIndex].time = time[i];
               SRLevels[levelIndex].isSupport = true; // Support
               SRLevels[levelIndex].strength = 1;
               SRLevels[levelIndex].touches = CountTouches(high, low, close, low[i], lookbackBars, true);
            }
         }
      }
   }
   
   // Sort S/R levels by touch count (strength)
   SortSRLevels();
   
   // Limit the number of levels if needed
   if(ArraySize(SRLevels) > SR_MaxLevels * 2) { // *2 because we need both support and resistance
      ArrayResize(SRLevels, SR_MaxLevels * 2);
   }
}

//+------------------------------------------------------------------+
//| Sort S/R levels by strength                                       |
//+------------------------------------------------------------------+
void SortSRLevels() {
   int size = ArraySize(SRLevels);
   
   // Simple bubble sort to order by touches (most significant first)
   for(int i = 0; i < size - 1; i++) {
      for(int j = 0; j < size - i - 1; j++) {
         if(SRLevels[j].touches < SRLevels[j + 1].touches) {
            // Swap
            SRLevel temp = SRLevels[j];
            SRLevels[j] = SRLevels[j + 1];
            SRLevels[j + 1] = temp;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Count how many times price has touched this level                 |
//+------------------------------------------------------------------+
int CountTouches(const double &high[], const double &low[], const double &close[], 
                double level, int bars, bool isSupport) {
   int touches = 0;
   double threshold = 10 * _Point; // Threshold for considering a touch
   
   for(int i = 0; i < bars; i++) {
      if(isSupport) {
         // Check if price touched support level
         if(MathAbs(low[i] - level) < threshold) {
            touches++;
         }
      }
      else {
         // Check if price touched resistance level
         if(MathAbs(high[i] - level) < threshold) {
            touches++;
         }
      }
   }
   
   return touches;
}

//+------------------------------------------------------------------+
//| Apply S/R levels to the chart buffers                            |
//+------------------------------------------------------------------+
void ApplySupportResistanceLevels(int bars) {
   // Initialize buffers
   ArrayInitialize(Support_Level_Buffer, EMPTY_VALUE);
   ArrayInitialize(Resistance_Level_Buffer, EMPTY_VALUE);
   
   // Draw levels
   for(int i = 0; i < ArraySize(SRLevels); i++) {
      if(SRLevels[i].isSupport) {
         for(int j = 0; j < bars; j++) {
            Support_Level_Buffer[j] = SRLevels[i].price;
         }
      }
      else {
         for(int j = 0; j < bars; j++) {
            Resistance_Level_Buffer[j] = SRLevels[i].price;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Distance to nearest support or resistance level                   |
//+------------------------------------------------------------------+
double DistanceToNearestLevel(double price, bool isResistance) {
   double minDistance = DBL_MAX;
   double closestLevel = 0;
   
   for(int i = 0; i < ArraySize(SRLevels); i++) {
      // Skip levels that don't match what we're looking for
      if(SRLevels[i].isSupport == isResistance) continue;
      
      double distance;
      if(isResistance) {
         // We want resistance (price above current)
         if(SRLevels[i].price > price) {
            distance = SRLevels[i].price - price;
            if(distance < minDistance) {
               minDistance = distance;
               closestLevel = SRLevels[i].price;
            }
         }
      }
      else {
         // We want support (price below current)
         if(SRLevels[i].price < price) {
            distance = price - SRLevels[i].price;
            if(distance < minDistance) {
               minDistance = distance;
               closestLevel = SRLevels[i].price;
            }
         }
      }
   }
   
   return (minDistance == DBL_MAX) ? -1 : minDistance;
}

//+------------------------------------------------------------------+
//| Check if bar forms a fractal (up)                                 |
//+------------------------------------------------------------------+
bool IsFractalUp(const double &high[], int index, int period) {
   if(index < period || index >= ArraySize(high) - period) return false;
   
   double centerValue = high[index];
   
   for(int i = index - period; i <= index + period; i++) {
      if(i == index) continue;
      
      if(high[i] >= centerValue) return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if bar forms a fractal (down)                               |
//+------------------------------------------------------------------+
bool IsFractalDown(const double &low[], int index, int period) {
   if(index < period || index >= ArraySize(low) - period) return false;
   
   double centerValue = low[index];
   
   for(int i = index - period; i <= index + period; i++) {
      if(i == index) continue;
      
      if(low[i] <= centerValue) return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+ 