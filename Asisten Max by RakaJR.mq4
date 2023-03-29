//+------------------------------------------------------------------+
//|                                        Asisten Max by RakaJR.mq4 |
//|                                        Copyright 2022, PapaCoder |
//|                                                  t.me/PrdnNvnRnt |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, PapaCoder"
#property link      "t.me/PrdnNvnRnt"
#property version   "1.00"
#property strict

#include  <stdlib.mqh>
#include <WinUser32.mqh>

#import "user32.dll"
int GetAncestor(int, int);
#import

#define MT4_WMCMD_EXPERTS 33020
#define ENABLED 1
#define DISABLED 0


input int         MaxSL       = 100;//Max Daily SL Order
input int         MaxTP       = 100;//Max Daily TP Order
input int         MaxOrder    = 100;//Max Daily Order Berjalan
input int         MaxClosed   = 100;//Max Daily Closed Order


int AutoTradeInfo;
int main;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   main = GetAncestor(WindowHandle(Symbol(), Period()), 2);

   if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) == 0) {
      int confirm = MessageBox("Current AutoTrading Button is Off. Please Turn It On First, then Re-Attach this EA", "Autotrading Button is Off", MB_ICONWARNING | MB_OK);
      if(confirm == IDOK) {
         ExpertRemove();
      }
   }
//--- create timer
   if(!IsTesting()) {
      int count = 0;
      bool timerSet = false;
      while(!timerSet && count < 5) {
         timerSet = EventSetTimer(1);
         if(!timerSet) {
            printf("Set Timer Error. Description %s. Trying %d...", ErrorDescription(_LastError), count);
            EventKillTimer();
            Sleep(200);
            timerSet = EventSetTimer(1);
            count++;
         }
      }
      if(!timerSet) {
         Alert("Cannot Set Timer. Please Re Init Your Experts");
         return INIT_FAILED;
      } else {
         printf("Set Timer at %s Success", Symbol());
      }
   }

//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//--- destroy timer
   EventKillTimer();

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
//---
   if(IsTesting()) {
      OnTimer();
   }
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
//---
   static datetime timeDay = 0;

   AutoTradeInfo = TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);

   int countSL = CountSL();
   int countTP = CountTP();
   int countOrder = CountOrder();
   int countClosed = CountClosed();

   if((countSL >= MaxSL) || (countTP >= MaxTP) || (countOrder >= MaxOrder) || (countClosed >= MaxClosed)) {
      if(iTime(Symbol(), PERIOD_D1, 0) != timeDay) {
         if(AutoTradeInfo == ENABLED) {
            PostMessageA(main, WM_COMMAND, MT4_WMCMD_EXPERTS, 0);
         }
         timeDay = iTime(Symbol(), PERIOD_D1, 0);
      }
   }

   if(iTime(Symbol(), PERIOD_D1, 0) != timeDay) {
      if(AutoTradeInfo == DISABLED) {
         PostMessageA(main, WM_COMMAND, MT4_WMCMD_EXPERTS, 0);
      }
   }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountOrder() {
   int count = 0;
   int i, total = OrdersTotal();
   for(i = 0; i < total; i++) {
      if(OrderSelect(i, SELECT_BY_POS)) {
         if(OrderType() < OP_BUYLIMIT) {
            count ++;
         }
      }
   }
   return count;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountSL() {

   int count = 0;

   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         if(OrderType() < OP_BUYLIMIT) {
            if(OrderCloseTime() >= iTime(Symbol(), PERIOD_D1, 0)) {
               if(OrderProfit() < 0) {
                  count++;
               }
            }
         }
      }
   }
   return count;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTP() {

   int count = 0;

   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         if(OrderType() < OP_BUYLIMIT) {
            if(OrderCloseTime() >= iTime(Symbol(), PERIOD_D1, 0)) {
               if(OrderProfit() > 0) {
                  count++;
               }
            }
         }
      }
   }
   return count;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountClosed() {

   int count = 0;

   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         if(OrderType() < OP_BUYLIMIT) {
            if(OrderCloseTime() >= iTime(Symbol(), PERIOD_D1, 0)) {
               count++;
            }
         }
      }
   }
   return count;
}
//+------------------------------------------------------------------+
