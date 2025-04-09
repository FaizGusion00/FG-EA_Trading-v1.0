====================================================
FG ScalpingPro Indicator - IMPORTANT USAGE GUIDE
====================================================

If you are having issues where MetaTrader is trying to use the indicator as a trading robot/EA, please follow these instructions:

1. Use the FG_ScalpingPro_Indicator_FIXED.mq5 file for chart display only. This version is designed to function ONLY as an indicator.

2. The proper way to add the indicator to your chart:
   - In MetaTrader, go to Navigator panel
   - Under "Indicators", not under "Expert Advisors" 
   - Find FG_ScalpingPro_Indicator_FIXED
   - Drag and drop it to your chart

3. If you still see an EA prompt when adding the indicator, try:
   - Removing all previous versions from your charts
   - Recompiling the indicator in MetaEditor
   - Restarting MetaTrader

4. Remember:
   - FG_ScalpingPro_EA.mq5 is the Expert Advisor for automated trading
   - FG_ScalpingPro_Indicator_FIXED.mq5 is ONLY for chart display/analysis

If problems persist, try clearing the MetaTrader cache:
1. Close MetaTrader
2. Navigate to your MetaTrader data folder
3. Delete the "MQL5\Cache" folder
4. Restart MetaTrader

For technical support, please contact:
support@fgtrading.com

==================================================== 