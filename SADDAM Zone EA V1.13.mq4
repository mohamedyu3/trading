//+------------------------------------------------------------------+
//|              www.arabictrader.com                                |
//|              MR.dollar                                           |
//+------------------------------------------------------------------+

#property copyright "MR.dollarEA"
#property link      "mrdollar.cs@gmail.com"
#property version   "1.13"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum order
  {
   BUY,
   SELL
  };

input int MaxTrades=0;
input bool CloseAtMaxTrades=false;
input bool RunOnce=false;
input bool  EnableTimeFilter=false;
input string  Start_Hour="00:00";
input string  End_Hour="23:00";

input string info_1=" Multiplier Settings ";
input order FirstOrder=BUY;
input int Step=20;
input int TakeProfit=20;
input int StopLoss=0;
input double Multiplier=2;

input int MultiplierNumber=4;
input int WaitingMinutes=30;
input int PipsToTransfair=10;
input double PF_Percent=50;
input double F_Lots=0.1;
input double TARGET=100;
input bool EnableProfitUSD=false;
input double TotalProfitUSD=100;
input string  MM_Parameters=" Money Management ";
input double  Lots=0.1;
input bool  MoneyManagement=false;
input double  Risk=1;
input int MagicNumber=2035;
input double MaxLots=10.0;
input double MinLots=1.0;
input string hedge_params=" Dynamic Hedging Parameters ";
input int Step2 = 50; // Buffer for secondary cycles
input int MaxSecondaryCycles = 3; // Maximum number of autonomous secondary cycles

double point;
int digits,P;
int lot_digits;
bool IsHedgingMode=false;
double HedgeEntryPrice=0;
datetime SecondaryStartTimes[100]; // Track start times for secondary magic numbers
bool transfair=false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(MarketInfo(Symbol(),MODE_MINLOT)<0.1)lot_digits=2;
   else lot_digits=1;
   if(Digits==5 || Digits==3)P=10;
   else P=1;
   if(Digits<4)
     {
      point=0.01;
      digits=2;
     }
   else
     {
      point=0.0001;
      digits=4;
     }

   CreatePanel("Panel_info_Rec1",OBJ_RECTANGLE_LABEL,"",5,280,110,65,Black,Red,Blue,8);
   CreatePanel("Panel_Info_close",OBJ_BUTTON,"Close All",10,285,100,25,DarkGoldenrod,White,DarkGoldenrod,7,false,false,0,ALIGN_CENTER);
   CreatePanel("Panel_Info_transfair",OBJ_BUTTON,"TransfairOrders",10,315,100,25,DarkGoldenrod,White,DarkGoldenrod,7,false,false,0,ALIGN_CENTER);
   
   for(int i=0; i<100; i++) SecondaryStartTimes[i] = 0;

   return(INIT_SUCCEEDED);
  }
  
void DrawAccountInfo(datetime StartTime)
  {
   int X_Shift=10;
   int Y_Shift=40;
   int Added_X=0,Added_Y=0;
   CreatePanel("Panel_Info_1",OBJ_EDIT,"BUY Lots",X_Shift+Added_X,Y_Shift+Added_Y,80,20,Black,White,Black,10,true,false,0,ALIGN_LEFT);Added_X+=95;
   CreatePanel("Panel_Info_2",OBJ_EDIT,DoubleToStr(TotalLots_m(MagicNumber, OP_BUY),2),X_Shift+Added_X,Y_Shift+Added_Y,70,20,Black,White,Red,10,true,false,0,ALIGN_CENTER);Added_X-=95;Added_Y+=35;
   
   CreatePanel("Panel_Info_3",OBJ_EDIT,"SELL Lots",X_Shift+Added_X,Y_Shift+Added_Y,80,20,Black,White,Black,10,true,false,0,ALIGN_LEFT);Added_X+=95;
   CreatePanel("Panel_Info_4",OBJ_EDIT,DoubleToStr(TotalLots_m(MagicNumber, OP_SELL),2),X_Shift+Added_X,Y_Shift+Added_Y,70,20,Black,White,Red,10,true,false,0,ALIGN_CENTER);Added_X-=95;Added_Y+=35;
   
   CreatePanel("Panel_Info_5",OBJ_EDIT,"Time Minutes Lots",X_Shift+Added_X,Y_Shift+Added_Y,80,20,Black,White,Black,10,true,false,0,ALIGN_LEFT);Added_X+=95;
   CreatePanel("Panel_Info_6",OBJ_EDIT,NormalizeDouble((TimeCurrent()-LastCurrentOrderInfo("Time", -1, MagicNumber))/60,1),X_Shift+Added_X,Y_Shift+Added_Y,70,20,Black,White,Red,10,true,false,0,ALIGN_CENTER);Added_X-=95;Added_Y+=35;
   
   CreatePanel("Panel_Info_7",OBJ_EDIT,"Cycle Closed Trades Profit: ",X_Shift+Added_X,Y_Shift+Added_Y,80,20,Black,White,Black,10,true,false,0,ALIGN_LEFT);Added_X+=95;
   CreatePanel("Panel_Info_8",OBJ_EDIT,TotalGainedProfit(StartTime, MagicNumber),X_Shift+Added_X,Y_Shift+Added_Y,70,20,Black,White,Red,10,true,false,0,ALIGN_CENTER);Added_X-=95;Added_Y+=35;
   
   CreatePanel("Panel_Info_9",OBJ_EDIT,"Cycle Open Trades Profit: ",X_Shift+Added_X,Y_Shift+Added_Y,80,20,Black,White,Black,10,true,false,0,ALIGN_LEFT);Added_X+=95;
   CreatePanel("Panel_Info_10",OBJ_EDIT,TotalProfit(MagicNumber),X_Shift+Added_X,Y_Shift+Added_Y,70,20,Black,White,Red,10,true,false,0,ALIGN_CENTER);Added_X-=95;Added_Y+=35;
   
   CreatePanel("Panel_Info_11",OBJ_EDIT,"Total : ",X_Shift+Added_X,Y_Shift+Added_Y,80,20,Black,White,Black,10,true,false,0,ALIGN_LEFT);Added_X+=95;
   CreatePanel("Panel_Info_12",OBJ_EDIT,TotalGainedProfit(StartTime, MagicNumber)+TotalProfit(MagicNumber),X_Shift+Added_X,Y_Shift+Added_Y,70,20,Black,White,Red,10,true,false,0,ALIGN_CENTER);Added_X-=95;Added_Y+=35;
  }        

void OnDeinit(const int reason)
  {
   Comment("");
  }

void OnTick()
  {
   if(ObjectGetInteger(0,"Panel_Info_close",OBJPROP_STATE))
     {
      CloseAll(-1, -1); // Close EVERYTHING (all magics)
      ObjectSetInteger(0,"Panel_Info_close",OBJPROP_STATE,false);
     }
   if(ObjectGetInteger(0,"Panel_Info_transfair",OBJPROP_STATE))
     {
      transfair=true;
      ObjectSetInteger(0,"Panel_Info_transfair",OBJPROP_STATE,false);
     }

   if(EnableTimeFilter && !TimeFilter(Start_Hour, End_Hour)) return;

   static datetime MainStartCycleTime;
   if(orderscnt_m(MagicNumber) == 0) MainStartCycleTime = TimeCurrent();

   DrawAccountInfo(MainStartCycleTime);

   // HEDGING LOGIC FOR MAIN CYCLE
   if(!IsHedgingMode)
     {
      if(TotalLots_m(MagicNumber, OP_BUY) >= MaxLots || TotalLots_m(MagicNumber, OP_SELL) >= MaxLots)
        {
         IsHedgingMode=true;
         HedgeEntryPrice = Bid;
         Print("MaxLots reached. Switching to Hedging Mode. Entry Price: ", HedgeEntryPrice);
         DisableAllTakeProfits_m(MagicNumber);
         DeleteAllPendingOrders_m(MagicNumber);
         ExecuteLock();
        }
     }

   if(IsHedgingMode)
     {
      // Step 0: Ensure 1:1 Balance (Continuous Lock)
      double balanceDiff = TotalLots_m(MagicNumber, OP_BUY) - TotalLots_m(MagicNumber, OP_SELL);
      if(MathAbs(balanceDiff) > 0.001) ExecuteLock();

      // Step 1: Manage Main Cycle Reduction
      ManageMainCycleReduction();

      // Step 2: Manage Dynamic Secondary Cycles
      for(int i=0; i < MaxSecondaryCycles; i++)
        {
         int currentM = MagicNumber + i + 1;
         int cnt = orderscnt_m(currentM);
         
         if(cnt == 0)
           {
            // Trigger Condition: Bid is inside current Main Zone with Step2 buffer
            double mainBuyPrice = LastCurrentOrderInfo("Price", OP_BUY, MagicNumber);
            double mainSellPrice = LastCurrentOrderInfo("Price", OP_SELL, MagicNumber);
            
            if(mainBuyPrice > 0 && mainSellPrice > 0)
              {
               if(Bid < mainBuyPrice - Step2*point && Bid > mainSellPrice + Step2*point)
                 {
                  Print("Dynamic Secondary Cycle triggered: ", currentM);
                  StartMagicGrid(currentM);
                  SecondaryStartTimes[i] = TimeCurrent();
                 }
              }
           }
         else
           {
            ManageMagicProcess(currentM, SecondaryStartTimes[i]);
           }
        }

      // Step 3: Exit Hedging Mode check
      if(MathMax(TotalLots_m(MagicNumber, OP_BUY), TotalLots_m(MagicNumber, OP_SELL)) <= MinLots)
        {
         IsHedgingMode = false;
         Print("Hedge reduction completed. Returning to normal strategy.");
        }
      return; 
     }

   // NORMAL MODE: Manage Main Magic Number
   ManageMagicProcess(MagicNumber, MainStartCycleTime, true);
  }

//+------------------------------------------------------------------+
//| CORE PROCESS FOR A SINGLE MAGIC NUMBER                           |
//+------------------------------------------------------------------+
void ManageMagicProcess(int magic, datetime &startTime, bool isMain=false)
  {
   int cnt = orderscnt_m(magic);
   
   // 1. Sync TP
   ModifyAllOrdersTP_m(OP_SELL, magic);
   ModifyAllOrdersTP_m(OP_BUY, magic);

   // 2. Closure Logic
   if(cnt > 0)
     {
      double prof = TotalGainedProfit(startTime, magic) + TotalProfit(magic);
      if((TARGET != 0 && prof >= TARGET) || (EnableProfitUSD && TotalProfit(magic) >= TotalProfitUSD))
        {
         CloseAll(-1, magic);
         startTime = TimeCurrent();
         return;
        }
      
      if(CloseAtMaxTrades && MaxTrades != 0 && cnt >= MaxTrades)
        {
         CloseAll(-1, magic);
         startTime = TimeCurrent();
         return;
        }
    
      if(!isMain && (orderscnt_m(magic, OP_BUY) + orderscnt_m(magic, OP_SELL) == 0) && cnt > 0)
        {
         CloseAll(-1, magic);
         return;
        }
     }

   // 3. Grid Management (Pending Orders)
   if(cnt > 0 && (cnt < MaxTrades || MaxTrades == 0))
     {
      double price, TP, SL, newLot;
      if(LastCurrentOrderInfo("Type", -1, magic) == OP_BUY && orderscnt_m(magic, OP_SELLSTOP) == 0)
        {
         price = LastCurrentOrderInfo("Price", -1, magic) - Step * point;
         TP = (TakeProfit !=0) ? price - TakeProfit * point : 0;
         SL = (StopLoss != 0) ? price + StopLoss * point : 0;
         newLot = NormalizeDouble(LastCurrentOrderInfo("Lots", OP_BUY, magic) * Multiplier, lot_digits);
         if(OrderSend(Symbol(), OP_SELLSTOP, newLot, NormalizeDouble(price, Digits), 3 * P, SL, TP, "Grid", magic, 0, Red) < 0)
            Print("Magic ", magic, " OP_SELLSTOP Error: ", GetLastError());
        }
      if(LastCurrentOrderInfo("Type", -1, magic) == OP_SELL && orderscnt_m(magic, OP_BUYSTOP) == 0)
        {
         price = LastCurrentOrderInfo("Price", -1, magic) + Step * point;
         TP = (TakeProfit !=0) ? price + TakeProfit * point : 0;
         SL = (StopLoss != 0) ? price - StopLoss * point : 0;
         newLot = NormalizeDouble(LastCurrentOrderInfo("Lots", OP_SELL, magic) * Multiplier, lot_digits);
         if(OrderSend(Symbol(), OP_BUYSTOP, newLot, NormalizeDouble(price, Digits), 3 * P, SL, TP, "Grid", magic, 0, Blue) < 0)
            Print("Magic ", magic, " OP_BUYSTOP Error: ", GetLastError());
        }
     }

   // 4. Selective Profit Harvesting (Transfair Logic) - Only for Main cycle
   if(isMain && cnt > MultiplierNumber && (TimeCurrent() - LastCurrentOrderInfo("Time", -1, magic) >= WaitingMinutes * 60 || transfair))
     {
      transfair = false;
      ExecuteTransfair(magic);
     }

   // 5. Start Cycle if 0
   if(cnt == 0 && isMain)
     {
      StartMagicGrid(magic);
     }
  }

void ExecuteTransfair(int magic)
  {
   double lastType = LastCurrentOrderInfo("Type", -1, magic);
   double lastPrice = LastCurrentOrderInfo("Price", -1, magic);
   double profit = 0;
   int ticket;
   double TP, SL=0, nl, pPrice;

   if(lastType == OP_BUY && Bid - lastPrice >= PipsToTransfair * point)
     {
      profit = CloseSelectedWinners_m(OP_BUY, magic);
      if(profit > 0) ClosePercentOfLoss_m(OP_SELL, profit, magic);
      
      TP = (TakeProfit == 0) ? 0 : Ask + TakeProfit * point;
      if(StopLoss != 0) SL = Ask - StopLoss * point;
      nl = NormalizeDouble(TotalLots_m(magic, OP_SELL) * Multiplier, lot_digits);
      CloseAll(OP_SELLSTOP, magic);
      ticket = OrderSend(Symbol(), OP_BUY, nl, Ask, 3 * P, SL, TP, "EA", magic, 0, Blue);
      
      pPrice = LastCurrentOrderInfo("Price", -1, magic) - Step * point - PipsToTransfair * point;
      TP = (TakeProfit != 0) ? pPrice - TakeProfit * point : 0;
      if(StopLoss != 0) SL = pPrice + StopLoss * point;
      if(OrderSend(Symbol(), OP_SELLSTOP, NormalizeDouble(nl * Multiplier, lot_digits), pPrice, 3 * P, SL, TP, "EA", magic, 0, Red) < 0)
         Print("Transfair OP_SELLSTOP Error: ", GetLastError());
     }
   else if(lastType == OP_SELL && lastPrice - Ask >= PipsToTransfair * point)
     {
      profit = CloseSelectedWinners_m(OP_SELL, magic);
      if(profit > 0) ClosePercentOfLoss_m(OP_BUY, profit, magic);

      TP = (TakeProfit == 0) ? 0 : Bid - TakeProfit * point;
      if(StopLoss != 0) SL = Bid + StopLoss * point;
      nl = NormalizeDouble(TotalLots_m(magic, OP_BUY) * Multiplier, lot_digits);
      CloseAll(OP_BUYSTOP, magic);
      ticket = OrderSend(Symbol(), OP_SELL, nl, Bid, 3 * P, SL, TP, "EA", magic, 0, Red);

      pPrice = LastCurrentOrderInfo("Price", -1, magic) + Step * point + PipsToTransfair * point;
      TP = (TakeProfit != 0) ? pPrice + TakeProfit * point : 0;
      if(StopLoss != 0) SL = pPrice - StopLoss * point;
      if(OrderSend(Symbol(), OP_BUYSTOP, NormalizeDouble(nl * Multiplier, lot_digits), pPrice, 3 * P, SL, TP, "EA", magic, 0, Blue) < 0)
         Print("Transfair OP_BUYSTOP Error: ", GetLastError());
     }
  }

void ManageMainCycleReduction()
  {
   if(orderscnt_m(MagicNumber) == 0) return;
   if(TimeCurrent() - LastCurrentOrderInfo("Time", -1, MagicNumber) < WaitingMinutes * 60 && !transfair) return;

   double lBuy = LastCurrentOrderInfo("Price", OP_BUY, MagicNumber);
   double lSell = LastCurrentOrderInfo("Price", OP_SELL, MagicNumber);
   double profit = 0;

   if(lBuy > 0 && Bid - lBuy >= PipsToTransfair * point)
     {
      profit = CloseSelectedWinners_m(OP_BUY, MagicNumber);
      if(profit > 0) ClosePercentOfLoss_m(OP_SELL, profit, MagicNumber);
      transfair = false;
      ExecuteLock();
     }
   else if(lSell > 0 && lSell - Ask >= PipsToTransfair * point)
     {
      profit = CloseSelectedWinners_m(OP_SELL, MagicNumber);
      if(profit > 0) ClosePercentOfLoss_m(OP_BUY, profit, MagicNumber);
      transfair = false;
      ExecuteLock();
     }
  }

void StartMagicGrid(int magic)
  {
   double newLot = MoneyManagement ? LotManage() : Lots;
   double TP=0, SL=0;
   if(FirstOrder==BUY)
     {
      TP = (TakeProfit == 0) ? 0 : Ask + TakeProfit * point;
      if(StopLoss != 0) SL = Ask - StopLoss * point;
      if(OrderSend(Symbol(), OP_BUY, newLot, Ask, 3 * P, SL, TP, "Start", magic, 0, Blue) < 0)
         Print("StartMagicGrid OP_BUY Error: ", GetLastError());
     }
   else
     {
      TP = (TakeProfit == 0) ? 0 : Bid - TakeProfit * point;
      if(StopLoss != 0) SL = Bid + StopLoss * point;
      if(OrderSend(Symbol(), OP_SELL, newLot, Bid, 3 * P, SL, TP, "Start", magic, 0, Red) < 0)
         Print("StartMagicGrid OP_SELL Error: ", GetLastError());
     }
  }

//+------------------------------------------------------------------+
//| UTILITY FUNCTIONS WITH MAGIC PARAMETER                           |
//+------------------------------------------------------------------+
int orderscnt_m(int magic, int type=-1)
  {
   int cnt=0;
   for(int i=0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && magic==OrderMagicNumber() && (OrderType()==type || type==-1))
           {
            cnt++;
           }
        }
     }
   return(cnt);
  }

double TotalLots_m(int magic, int type)
  {
   double lots=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && (magic == -1 || OrderMagicNumber() == magic) && OrderType() == type)
            lots += OrderLots();
        }
     }
   return(lots);
  }

double TotalProfit(int magic)
  {
   double profit=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && (magic == -1 || OrderMagicNumber()==magic))
            profit += OrderProfit() + OrderSwap() + OrderCommission();
        }
     }
   return(profit);
  }

double TotalGainedProfit(datetime TimeCheck, int magic)
  {
   double profit=0;
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
           {
            if(OrderOpenTime() >= TimeCheck) profit += OrderProfit() + OrderSwap() + OrderCommission();
            else return(profit);
           }
        }
     }
   return(profit);
  }

double LastCurrentOrderInfo(string info, int type, int magic)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && (OrderType()==type || type==-1) && OrderType() <= OP_SELL)
           {
            if(info=="Type") return(OrderType());
            if(info=="Lots") return(OrderLots());
            if(info=="Price") return(OrderOpenPrice());
            if(info=="TP") return(OrderTakeProfit());
            if(info=="SL") return(OrderStopLoss());
            if(info=="Time") return(OrderOpenTime());
           }
        }
     }
   return(0);
  }

void ModifyAllOrdersTP_m(int type, int magic)
  {
   double TP = LastCurrentOrderInfo("TP", type, magic);
   if(TP <= 0) return;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==type)
           {
            if(OrderTakeProfit() != TP) 
               if(!OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), TP, 0))
                  Print("OrderModify Error: ", GetLastError());
           }
        }
     }
  }

void CloseAll(int type, int magic)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && (magic == -1 || OrderMagicNumber()==magic) && (type == -1 || OrderType()==type))
           {
            if(OrderType()==OP_BUY) 
               if(!OrderClose(OrderTicket(), OrderLots(), Bid, 3*P))
                  Print("OrderClose BUY Error: ", GetLastError());
            else if(OrderType()==OP_SELL) 
               if(!OrderClose(OrderTicket(), OrderLots(), Ask, 3*P))
                  Print("OrderClose SELL Error: ", GetLastError());
            else 
               if(!OrderDelete(OrderTicket()))
                  Print("OrderDelete Error: ", GetLastError());
           }
        }
     }
  }

double CloseSelectedWinners_m(int type, int magic)
  {
   double totalProf=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==type)
           {
            if(OrderProfit() > 0)
              {
               double p = OrderProfit() + OrderSwap() + OrderCommission();
               double pr = (type == OP_SELL) ? Ask : Bid;
               if(OrderClose(OrderTicket(), OrderLots(), pr, 3 * P)) totalProf += p;
               else Print("CloseSelectedWinners OrderClose Error: ", GetLastError());
              }
           }
        }
     }
   return(totalProf);
  }

void ClosePercentOfLoss_m(int type, double closedprofit, int magic)
  {
   if(closedprofit <= 0) return;
   double profitToclose = closedprofit * PF_Percent / 100;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==type && OrderProfit() < 0)
           {
            double op = OrderProfit();
            double ol = OrderLots();
            double pLots = MathAbs(profitToclose / op) * 100;
            double lots = (pLots >= 100) ? ol : NormalizeDouble(ol * pLots / 100, lot_digits);
            if(lots < MarketInfo(Symbol(), MODE_MINLOT)) continue;
            double pr = (type == OP_SELL) ? Ask : Bid;
            if(OrderClose(OrderTicket(), lots, pr, 3 * P))
              {
               profitToclose += op * (lots / ol);
              }
            else Print("ClosePercentOfLoss OrderClose Error: ", GetLastError());
            if(profitToclose <= 0) break;
           }
        }
     }
  }

void ExecuteLock()
  {
   double bl = TotalLots_m(MagicNumber, OP_BUY);
   double sl = TotalLots_m(MagicNumber, OP_SELL);
   double min_lot = MarketInfo(Symbol(), MODE_MINLOT);
   double vol;
   if(bl > sl)
     {
      vol = NormalizeDouble(bl - sl, lot_digits);
      if(vol >= min_lot) 
         if(OrderSend(Symbol(), OP_SELL, vol, Bid, 3 * P, 0, 0, "Lock", MagicNumber, 0, Red) < 0)
            Print("ExecuteLock SELL Error: ", GetLastError());
     }
   else if(sl > bl)
     {
      vol = NormalizeDouble(sl - bl, lot_digits);
      if(vol >= min_lot)
         if(OrderSend(Symbol(), OP_BUY, vol, Ask, 3 * P, 0, 0, "Lock", MagicNumber, 0, Blue) < 0)
            Print("ExecuteLock BUY Error: ", GetLastError());
     }
  }

void DisableAllTakeProfits_m(int magic)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderTakeProfit() != 0)
            if(!OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), 0, 0))
               Print("DisableAllTakeProfits_m OrderModify Error: ", GetLastError());
        }
     }
  }

void DeleteAllPendingOrders_m(int magic)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType() > 1)
            if(!OrderDelete(OrderTicket()))
               Print("DeleteAllPendingOrders_m OrderDelete Error: ", GetLastError());
        }
     }
  }

void CreatePanel(string name,ENUM_OBJECT Type,string text,int XDistance,int YDistance,int Width,int Hight,
                 color BGColor_,color InfoColor,color boarderColor,int fontsize,bool readonly=false,bool Obj_Selectable=false,int Corner=0,ENUM_ALIGN_MODE Align=ALIGN_LEFT)
  {
   if(ObjectFind(0,name)==-1)
     {
      ObjectCreate(0,name,Type,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,XDistance);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,YDistance);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,Width);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,Hight);
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
      ObjectSetInteger(0,name,OBJPROP_CORNER,Corner);
      ObjectSetInteger(0,name,OBJPROP_COLOR,InfoColor);
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,BGColor_);
      if(Type==OBJ_EDIT) { ObjectSetInteger(0,name,OBJPROP_ALIGN,Align); ObjectSetInteger(0,name,OBJPROP_READONLY,readonly); }
     }
   else if(ObjectGetString(0,name,OBJPROP_TEXT)!=text) ObjectSetString(0,name,OBJPROP_TEXT,text);
  }

bool TimeFilter(string StartH,string EndH)
  {
   datetime Start=StrToTime(TimeToStr(TimeCurrent(),TIME_DATE)+" "+StartH);
   datetime End=StrToTime(TimeToStr(TimeCurrent(),TIME_DATE)+" "+EndH);
   return(TimeCurrent()>=Start && TimeCurrent()<=End);
  }

double LotManage()
  {
   double lot=MathCeil(AccountFreeMargin() *Risk/1000)/100;
   if(lot<MarketInfo(Symbol(),MODE_MINLOT))lot=MarketInfo(Symbol(),MODE_MINLOT);
   if(lot>MarketInfo(Symbol(),MODE_MAXLOT))lot=MarketInfo(Symbol(),MODE_MAXLOT);
   return (NormalizeDouble(lot,lot_digits));
  }
