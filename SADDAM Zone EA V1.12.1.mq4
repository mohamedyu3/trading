//+------------------------------------------------------------------+
//|              www.arabictrader.com                                |
//|              MR.dollar                                           |
//+------------------------------------------------------------------+

#property copyright "MR.dollarEA"
#property link      "mrdollar.cs@gmail.com"
#property version   "1.12"
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
  
void DrawAccountInfo(datetime StartCycleTime)
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
   CreatePanel("Panel_Info_8",OBJ_EDIT,TotalGainedProfit_m(StartCycleTime, MagicNumber),X_Shift+Added_X,Y_Shift+Added_Y,70,20,Black,White,Red,10,true,false,0,ALIGN_CENTER);Added_X-=95;Added_Y+=35;
   
   CreatePanel("Panel_Info_9",OBJ_EDIT,"Cycle Open Trades Profit: ",X_Shift+Added_X,Y_Shift+Added_Y,80,20,Black,White,Black,10,true,false,0,ALIGN_LEFT);Added_X+=95;
   CreatePanel("Panel_Info_10",OBJ_EDIT,TotalProfit_m(-1, MagicNumber),X_Shift+Added_X,Y_Shift+Added_Y,70,20,Black,White,Red,10,true,false,0,ALIGN_CENTER);Added_X-=95;Added_Y+=35;
   
   CreatePanel("Panel_Info_11",OBJ_EDIT,"Total : ",X_Shift+Added_X,Y_Shift+Added_Y,80,20,Black,White,Black,10,true,false,0,ALIGN_LEFT);Added_X+=95;
   CreatePanel("Panel_Info_12",OBJ_EDIT,TotalGainedProfit_m(StartCycleTime, MagicNumber)+TotalProfit_m(-1, MagicNumber),X_Shift+Added_X,Y_Shift+Added_Y,70,20,Black,White,Red,10,true,false,0,ALIGN_CENTER);Added_X-=95;Added_Y+=35;
  }        

void OnDeinit(const int reason)
  {
   Comment("");
  }

void OnTick()
  {
   if(ObjectGetInteger(0,"Panel_Info_close",OBJPROP_STATE))
     {
      CloseAll_m(-1, -1); // Close EVERYTHING
      ObjectSetInteger(0,"Panel_Info_close",OBJPROP_STATE,false);
     }
   if(ObjectGetInteger(0,"Panel_Info_transfair",OBJPROP_STATE))
     {
      transfair=true;
      ObjectSetInteger(0,"Panel_Info_transfair",OBJPROP_STATE,false);
     }

   if(EnableTimeFilter && !TimeFilter(Start_Hour, End_Hour)) return;
   
   static bool stopEA;
   static datetime StartCycleTime;
   if(orderscnt_m(MagicNumber) == 0) StartCycleTime = TimeCurrent();

   DrawAccountInfo(StartCycleTime);

   // HEDGING MODE LOGIC (Based on V1.11 scenario)
   if(!IsHedgingMode)
     {
      if(TotalLots_m(MagicNumber, OP_BUY) >= MaxLots || TotalLots_m(MagicNumber, OP_SELL) >= MaxLots)
        {
         IsHedgingMode=true;
         Print("MaxLots reached. Switching to Hedging Mode.");
         DisableAllTakeProfits_m(MagicNumber);
         DeleteAllPendingOrders_m(MagicNumber);
         ExecuteLock();
        }
     }

   if(IsHedgingMode)
     {
      // Step 0: Ensure 1:1 Balance (Continuous Lock) for Main Magic
      double balanceDiff = TotalLots_m(MagicNumber, OP_BUY) - TotalLots_m(MagicNumber, OP_SELL);
      if(MathAbs(balanceDiff) > 0.001) ExecuteLock();

      // Step 1: Manage SEQUENTIAL Dynamic Secondary Cycles
      // Check if any secondary cycle is active to prevent duplicates in the same tick
      bool isAnySecondaryActive = false;
      for(int j=0; j < MaxSecondaryCycles; j++)
        {
         if(orderscnt_m(MagicNumber + j + 1) > 0)
           {
            isAnySecondaryActive = true;
            break;
           }
        }

      for(int i=0; i < MaxSecondaryCycles; i++)
        {
         int currentM = MagicNumber + i + 1;
         int cnt = orderscnt_m(currentM);
         
         if(cnt == 0)
           {
            // Trigger Condition: Bid is inside current Main Zone with Step2 buffer
            // AND we don't already have an active secondary cycle
            if(!isAnySecondaryActive)
              {
               double mainBuyPrice = LastCurrentOrderInfo("Price", OP_BUY, MagicNumber);
               double mainSellPrice = LastCurrentOrderInfo("Price", OP_SELL, MagicNumber);
               
               if(mainBuyPrice > 0 && mainSellPrice > 0)
                 {
                   if(Bid < (mainBuyPrice - Step2*point) && Bid > (mainSellPrice + Step2*point))
                     {
                      Print("Sequential Secondary Cycle triggered: ", currentM);
                      StartSecondaryGrid(currentM);
                      SecondaryStartTimes[i] = TimeCurrent();
                      isAnySecondaryActive = true; // Prevent others from spawning simultaneously
                     }
                 }
              }
           }
         else
           {
            ManageSecondaryProcess(currentM, SecondaryStartTimes[i]);
           }
        }

      // Step 2: Main Hedge Reduction Logic (Identical to V1.11)
      if(MathMax(TotalLots_m(MagicNumber, OP_BUY), TotalLots_m(MagicNumber, OP_SELL)) <= MinLots)
        {
         IsHedgingMode = false;
         Print("Hedge reduction completed. Returning to normal strategy.");
        }
      else
        {
         if(orderscnt_m(MagicNumber) > 0 && (TimeCurrent() - LastCurrentOrderInfo("Time", -1, MagicNumber) >= WaitingMinutes * 60 || transfair))
           {
            bool reduced = false;
            double hedge_profit = 0;
            double lastBuyPrice = LastCurrentOrderInfo("Price", OP_BUY, MagicNumber);
            double lastSellPrice = LastCurrentOrderInfo("Price", OP_SELL, MagicNumber);

            if(lastBuyPrice > 0 && Bid - lastBuyPrice >= PipsToTransfair * point)
              {
                hedge_profit = CloseSelectedWinners_m(OP_BUY, MagicNumber);
                if(hedge_profit > 0) { ClosePercentOfLoss_m(OP_SELL, hedge_profit, MagicNumber); reduced = true; }
              }
            else if(lastSellPrice > 0 && lastSellPrice - Ask >= PipsToTransfair * point)
              {
                hedge_profit = CloseSelectedWinners_m(OP_SELL, MagicNumber);
                if(hedge_profit > 0) { ClosePercentOfLoss_m(OP_BUY, hedge_profit, MagicNumber); reduced = true; }
              }

            if(reduced) { transfair = false; ExecuteLock(); }
           }
         return; // Bypass original grid logic for Main Magic while in Hedging Mode
        }
     }

   // NORMAL MODE (Identical to V1.11 for MagicNumber)
   double newLot,TP=0,SL=0,price,newLotPending,profit;
   int ticket;

   ModifyAllOrdersTP_m(OP_SELL, MagicNumber);
   ModifyAllOrdersTP_m(OP_BUY, MagicNumber);
   
   if(orderscnt_m(MagicNumber, OP_BUY)+orderscnt_m(MagicNumber, OP_SELL)==0 && orderscnt_m(MagicNumber)>0) CloseAll_m(-1, MagicNumber);
   if(orderscnt_m(MagicNumber)>0 && TotalGainedProfit_m(StartCycleTime, MagicNumber)+TotalProfit_m(-1, MagicNumber)>=TARGET && TARGET!=0) CloseAll_m(-1, MagicNumber);
   if(CloseAtMaxTrades && orderscnt_m(MagicNumber)>=MaxTrades && MaxTrades!=0) CloseAll_m(-1, MagicNumber);
   if(EnableProfitUSD && TotalProfit_m(-1, MagicNumber)>=TotalProfitUSD) CloseAll_m(-1, MagicNumber);
   if(((orderscnt_m(MagicNumber, OP_SELL)+orderscnt_m(MagicNumber, OP_SELLSTOP)==0) || (orderscnt_m(MagicNumber, OP_BUY)+orderscnt_m(MagicNumber, OP_BUYSTOP)==0)) && orderscnt_m(MagicNumber)>1) CloseAll_m(-1, MagicNumber);

   if(orderscnt_m(MagicNumber)>0 && (orderscnt_m(MagicNumber)<MaxTrades || MaxTrades==0))
     {
      if(LastCurrentOrderInfo("Type", -1, MagicNumber)==OP_BUY && orderscnt_m(MagicNumber, OP_SELLSTOP)==0)
        {
         price=LastCurrentOrderInfo("Price", -1, MagicNumber)-Step*point;
         if(TakeProfit!=0)TP=price-TakeProfit*point;
         if(StopLoss!=0)SL=price+StopLoss*point;
         newLot=NormalizeDouble(LastCurrentOrderInfo("Lots", OP_BUY, MagicNumber)*Multiplier,lot_digits);
         ticket=SmartOrderSend(OP_SELLSTOP,newLot,price,3*P,SL,TP,"Grid",MagicNumber,0,Red);
        }
      if(LastCurrentOrderInfo("Type", -1, MagicNumber)==OP_SELL && orderscnt_m(MagicNumber, OP_BUYSTOP)==0)
        {
         price=LastCurrentOrderInfo("Price", -1, MagicNumber)+Step*point;
         if(TakeProfit!=0)TP=price+TakeProfit*point;
         if(StopLoss!=0)SL=price-StopLoss*point;
         newLot=NormalizeDouble(LastCurrentOrderInfo("Lots", OP_SELL, MagicNumber)*Multiplier,lot_digits);
         ticket=SmartOrderSend(OP_BUYSTOP,newLot,price,3*P,SL,TP,"Grid",MagicNumber,0,Blue);
        }
     }
     
   if(orderscnt_m(MagicNumber)>MultiplierNumber && (TimeCurrent()-LastCurrentOrderInfo("Time", -1, MagicNumber)>=WaitingMinutes*60 || transfair))
     {
      transfair=false;
      if(LastCurrentOrderInfo("Type", -1, MagicNumber)==OP_BUY)
        {
         if(Bid-LastCurrentOrderInfo("Price", -1, MagicNumber)>=PipsToTransfair*point)
           {
            profit = CloseSelectedWinners_m(OP_BUY, MagicNumber);
            if(profit > 0) ClosePercentOfLoss_m(OP_SELL,profit, MagicNumber);
            TP = (TakeProfit==0)?0:Ask+TakeProfit*point;
            if(StopLoss!=0)SL=Ask-StopLoss*point;
            newLot=NormalizeDouble(TotalLots_m(MagicNumber, OP_SELL)*Multiplier,lot_digits);
            CloseAll_m(OP_SELLSTOP, MagicNumber);
            ticket=SmartOrderSend(OP_BUY,newLot,Ask,3*P,SL,TP,"Grid",MagicNumber,0,Blue);
            price=LastCurrentOrderInfo("Price", -1, MagicNumber)-Step*point-PipsToTransfair*point;
            if(TakeProfit!=0)TP=price-TakeProfit*point;
            if(StopLoss!=0)SL=price+StopLoss*point;
            newLotPending=NormalizeDouble(newLot*Multiplier,lot_digits);
            ticket=SmartOrderSend(OP_SELLSTOP,newLotPending,price,3*P,SL,TP,"Grid",MagicNumber,0,Red);
           }
        }
      else if(LastCurrentOrderInfo("Type", -1, MagicNumber)==OP_SELL)
        {
         if(LastCurrentOrderInfo("Price", -1, MagicNumber)-Ask>=PipsToTransfair*point)
           {
            profit = CloseSelectedWinners_m(OP_SELL, MagicNumber);
            if(profit > 0) ClosePercentOfLoss_m(OP_BUY,profit, MagicNumber);
            TP = (TakeProfit==0)?0:Bid-TakeProfit*point;
            if(StopLoss!=0)SL=Bid+StopLoss*point;
            newLot=NormalizeDouble(TotalLots_m(MagicNumber, OP_BUY)*Multiplier,lot_digits);
            CloseAll_m(OP_BUYSTOP, MagicNumber);
            ticket=SmartOrderSend(OP_SELL,newLot,Bid,3*P,SL,TP,"Grid",MagicNumber,0,Red);
            price=LastCurrentOrderInfo("Price", -1, MagicNumber)+Step*point+PipsToTransfair*point;
            if(TakeProfit!=0)TP=price+TakeProfit*point;
            if(StopLoss!=0)SL=price-StopLoss*point;
            newLotPending=NormalizeDouble(newLot*Multiplier,lot_digits);
            ticket=SmartOrderSend(OP_BUYSTOP,newLotPending,price,3*P,SL,TP,"Grid",MagicNumber,0,Blue);
           }
        }
     }

   if(orderscnt_m(MagicNumber)<1 && !stopEA)
     {
      StartCycleTime=TimeCurrent();
      if(RunOnce)stopEA=true;
      newLot = MoneyManagement ? LotManage() : Lots;
      if(FirstOrder==BUY)
        {
         TP = (TakeProfit==0)?0:Ask+TakeProfit*point;
         if(StopLoss!=0)SL=Ask-StopLoss*point;
         ticket=SmartOrderSend(OP_BUY,newLot,Ask,3*P,SL,TP,"Start",MagicNumber,0,Blue);
        }
      else
        {
         TP = (TakeProfit==0)?0:Bid-TakeProfit*point;
         if(StopLoss!=0)SL=Bid+StopLoss*point;
         ticket=SmartOrderSend(OP_SELL,newLot,Bid,3*P,SL,TP,"Start",MagicNumber,0,Red);
        }
     }
  }

//+------------------------------------------------------------------+
//| SECONDARY CYCLE PROCESS (Autonomous Grid)                        |
//+------------------------------------------------------------------+
void ManageSecondaryProcess(int magic, datetime &startTime)
  {
   int cnt = orderscnt_m(magic);
   double profit, TP, SL, newLot, pr, newLotPending, price;
   ModifyAllOrdersTP_m(OP_SELL, magic);
   ModifyAllOrdersTP_m(OP_BUY, magic);

   // 1. Closure Logic (Target/USD Profit)
   if(cnt > 0)
     {
      double prof = TotalGainedProfit_m(startTime, magic) + TotalProfit_m(-1, magic);
      if((TARGET != 0 && prof >= TARGET) || (EnableProfitUSD && TotalProfit_m(-1, magic) >= TotalProfitUSD))
        {
         CloseAll_m(-1, magic);
         return;
        }
      if((orderscnt_m(magic, OP_BUY) + orderscnt_m(magic, OP_SELL) == 0) && cnt > 0)
        {
         CloseAll_m(-1, magic);
         return;
        }
     }

   // 2. Harvesting Logic (Transfair) - Match Main Flow
   if(cnt > MultiplierNumber && (TimeCurrent() - LastCurrentOrderInfo("Time", -1, magic) >= WaitingMinutes * 60 || transfair))
     {
      if(LastCurrentOrderInfo("Type", -1, magic) == OP_BUY)
        {
         if(Bid - LastCurrentOrderInfo("Price", -1, magic) >= PipsToTransfair * point)
           {
            profit = CloseSelectedWinners_m(OP_BUY, magic);
            if(profit > 0) ClosePercentOfLoss_m(OP_SELL, profit, magic);
            
            TP = (TakeProfit == 0) ? 0 : Ask + TakeProfit * point;
            SL = (StopLoss != 0) ? Ask - StopLoss * point : 0;
            newLot = NormalizeDouble(TotalLots_m(magic, OP_SELL) * Multiplier, lot_digits);
            
            CloseAll_m(OP_SELLSTOP, magic);
            SmartOrderSend(OP_BUY, newLot, Ask, 3 * P, SL, TP, "SecHarvest", magic, 0, Blue);
            
            pr = LastCurrentOrderInfo("Price", -1, magic) - Step * point - PipsToTransfair * point;
            TP = (TakeProfit != 0) ? pr - TakeProfit * point : 0;
            SL = (StopLoss != 0) ? pr + StopLoss * point : 0;
            newLotPending = NormalizeDouble(newLot * Multiplier, lot_digits);
            SmartOrderSend(OP_SELLSTOP, newLotPending, pr, 3 * P, SL, TP, "SecHarvest", magic, 0, Red);
            return; // Exit after modification
           }
        }
      else if(LastCurrentOrderInfo("Type", -1, magic) == OP_SELL)
        {
         if(LastCurrentOrderInfo("Price", -1, magic) - Ask >= PipsToTransfair * point)
           {
            profit = CloseSelectedWinners_m(OP_SELL, magic);
            if(profit > 0) ClosePercentOfLoss_m(OP_BUY, profit, magic);
            
            TP = (TakeProfit == 0) ? 0 : Bid - TakeProfit * point;
            SL = (StopLoss != 0) ? Bid + StopLoss * point : 0;
            newLot = NormalizeDouble(TotalLots_m(magic, OP_BUY) * Multiplier, lot_digits);
            
            CloseAll_m(OP_BUYSTOP, magic);
            SmartOrderSend(OP_SELL, newLot, Bid, 3 * P, SL, TP, "SecHarvest", magic, 0, Red);
            
            pr = LastCurrentOrderInfo("Price", -1, magic) + Step * point + PipsToTransfair * point;
            TP = (TakeProfit != 0) ? pr + TakeProfit * point : 0;
            SL = (StopLoss != 0) ? pr - StopLoss * point : 0;
            newLotPending = NormalizeDouble(newLot * Multiplier, lot_digits);
            SmartOrderSend(OP_BUYSTOP, newLotPending, pr, 3 * P, SL, TP, "SecHarvest", magic, 0, Blue);
            return; // Exit after modification
           }
        }
     }

   // 3. Grid Management
   if(cnt > 0 && (cnt < MaxTrades || MaxTrades == 0))
     {
      if(LastCurrentOrderInfo("Type", -1, magic) == OP_BUY && orderscnt_m(magic, OP_SELLSTOP) == 0)
        {
         price = LastCurrentOrderInfo("Price", -1, magic) - Step * point;
         TP = (TakeProfit !=0) ? price - TakeProfit * point : 0;
         SL = (StopLoss != 0) ? price + StopLoss * point : 0;
         newLot = NormalizeDouble(LastCurrentOrderInfo("Lots", OP_BUY, magic) * Multiplier, lot_digits);
         SmartOrderSend(OP_SELLSTOP, newLot, price, 3 * P, SL, TP, "Secondary", magic, 0, Red);
        }
      if(LastCurrentOrderInfo("Type", -1, magic) == OP_SELL && orderscnt_m(magic, OP_BUYSTOP) == 0)
        {
         price = LastCurrentOrderInfo("Price", -1, magic) + Step * point;
         TP = (TakeProfit !=0) ? price + TakeProfit * point : 0;
         SL = (StopLoss != 0) ? price - StopLoss * point : 0;
         newLot = NormalizeDouble(LastCurrentOrderInfo("Lots", OP_SELL, magic) * Multiplier, lot_digits);
         SmartOrderSend(OP_BUYSTOP, newLot, price, 3 * P, SL, TP, "Secondary", magic, 0, Blue);
        }
     }
  }

void StartSecondaryGrid(int magic)
  {
   double newLot = MoneyManagement ? LotManage() : Lots;
   double TP=0, SL=0;
   if(FirstOrder==BUY)
     {
      TP = (TakeProfit == 0) ? 0 : Ask + TakeProfit * point;
      if(StopLoss != 0) SL = Ask - StopLoss * point;
      SmartOrderSend(OP_BUY, newLot, Ask, 3 * P, SL, TP, "SecStart", magic, 0, Blue);
     }
   else
     {
      TP = (TakeProfit == 0) ? 0 : Bid - TakeProfit * point;
      if(StopLoss != 0) SL = Bid + StopLoss * point;
      SmartOrderSend(OP_SELL, newLot, Bid, 3 * P, SL, TP, "SecStart", magic, 0, Red);
     }
  }

//+------------------------------------------------------------------+
//| SMART ORDER SEND (Prevents Error 130)                            |
//+------------------------------------------------------------------+
int SmartOrderSend(int type, double volume, double price, int slip, double sl, double tp, string comment, int magic, int expiration, color arrow)
  {
   double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * point;
   int finalType = type;
   double finalPrice = price;
   double finalSL = sl;
   double finalTP = tp;

   if(type == OP_BUYSTOP && Ask + stopLevel >= price) 
     { 
      finalType = OP_BUY; finalPrice = Ask; 
      if(tp > 0) finalTP = Ask + MathAbs(price - tp);
      if(sl > 0) finalSL = Ask - MathAbs(price - sl);
     }
   else if(type == OP_SELLSTOP && Bid - stopLevel <= price) 
     { 
      finalType = OP_SELL; finalPrice = Bid; 
      if(tp > 0) finalTP = Bid - MathAbs(price - tp);
      if(sl > 0) finalSL = Bid + MathAbs(price - sl);
     }

   double ref = 0;
   if(finalType == OP_BUY || finalType == OP_BUYSTOP)
     {
      ref = (finalType == OP_BUY) ? Ask : finalPrice;
      if(finalTP > 0 && finalTP < ref + stopLevel) finalTP = ref + stopLevel;
      if(finalSL > 0 && finalSL > ref - stopLevel) finalSL = ref - stopLevel;
     }
   else if(finalType == OP_SELL || finalType == OP_SELLSTOP)
     {
      ref = (finalType == OP_SELL) ? Bid : finalPrice;
      if(finalTP > 0 && finalTP > ref - stopLevel) finalTP = ref - stopLevel;
      if(finalSL > 0 && finalSL < ref + stopLevel) finalSL = ref + stopLevel;
     }

   finalPrice = NormalizeDouble(finalPrice, Digits);
   if(finalSL > 0) finalSL = NormalizeDouble(finalSL, Digits);
   if(finalTP > 0) finalTP = NormalizeDouble(finalTP, Digits);

   int ticket = OrderSend(Symbol(), finalType, volume, finalPrice, slip, finalSL, finalTP, comment, magic, expiration, arrow);
   if(ticket < 0) Print("SmartOrderSend Error [", GetLastError(), "] Type:", finalType, " Price:", finalPrice);
   return(ticket);
  }

//+------------------------------------------------------------------+
//| MAGIC-SPECIFIC UTILITY FUNCTIONS                                 |
//+------------------------------------------------------------------+
int orderscnt_m(int magic, int type=-1)
  {
   int cnt=0;
   for(int i=0;i<OrdersTotal();i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && (magic == -1 || magic==OrderMagicNumber()) && (OrderType()==type || type==-1)) cnt++;
   }
   return(cnt);
  }

double TotalLots_m(int magic, int type)
  {
   double lots=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber() == magic && OrderType() == type) lots += OrderLots();
   return(lots);
  }

double TotalProfit_m(int type, int magic)
  {
   double profit=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && (type == -1 || OrderType()==type))
            profit += OrderProfit() + OrderSwap() + OrderCommission();
   return(profit);
  }

double TotalGainedProfit_m(datetime TimeCheck, int magic)
  {
   double profit=0;
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderOpenTime()>=TimeCheck)
            profit += OrderProfit() + OrderSwap() + OrderCommission();
   return(profit);
  }

double LastCurrentOrderInfo(string info, int type, int magic)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && (OrderType()==type || type==-1) && OrderType() <= OP_SELL)
           {
            if(info=="Type") return(OrderType());
            if(info=="Lots") return(OrderLots());
            if(info=="Price") return(OrderOpenPrice());
            if(info=="TP") return(OrderTakeProfit());
            if(info=="SL") return(OrderStopLoss());
            if(info=="Time") return(OrderOpenTime());
           }
   return(0);
  }

void ModifyAllOrdersTP_m(int type, int magic)
  {
   double TP = LastCurrentOrderInfo("TP", type, magic);
   if(TP <= 0) return;
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==type && OrderTakeProfit() != TP)
            if(!OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), TP, 0))
               Print("ModifyAllOrdersTP_m Error: ", GetLastError());
  }

void CloseAll_m(int type, int magic)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==Symbol() && (magic == -1 || OrderMagicNumber()==magic) && (type == -1 || OrderType()==type))
           {
            if(OrderType()==OP_BUY) 
               {
                if(!OrderClose(OrderTicket(), OrderLots(), Bid, 3*P)) Print("CloseAll_m BUY Error: ", GetLastError());
               }
            else if(OrderType()==OP_SELL) 
               {
                if(!OrderClose(OrderTicket(), OrderLots(), Ask, 3*P)) Print("CloseAll_m SELL Error: ", GetLastError());
               }
            else 
               {
                if(!OrderDelete(OrderTicket())) Print("CloseAll_m Delete Error: ", GetLastError());
               }
           }
  }

double CloseSelectedWinners_m(int type, int magic)
  {
   double totalProf=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==type && OrderProfit()>0)
           {
            double p = OrderProfit() + OrderSwap() + OrderCommission();
            double pr = (type == OP_SELL) ? Ask : Bid;
            if(OrderClose(OrderTicket(), OrderLots(), pr, 3 * P)) totalProf += p;
           }
   return(totalProf);
  }

void ClosePercentOfLoss_m(int type, double closedprofit, int magic)
  {
   if(closedprofit <= 0) return;
   double profitToclose = closedprofit * PF_Percent / 100;
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()==type && OrderProfit()<0)
           {
            double op = OrderProfit(); double ol = OrderLots();
            double pLots = MathAbs(profitToclose/op)*100;
            double lots = (pLots>=100)?ol:NormalizeDouble(ol*pLots/100, lot_digits);
            if(lots < MarketInfo(Symbol(), MODE_MINLOT)) continue;
            double pr = (type == OP_SELL) ? Ask : Bid;
            if(OrderClose(OrderTicket(), lots, pr, 3 * P)) profitToclose += op * (lots / ol);
            if(profitToclose<=0) break;
           }
  }

void ExecuteLock()
  {
   double bl = TotalLots_m(MagicNumber, OP_BUY);
   double sl = TotalLots_m(MagicNumber, OP_SELL);
   double vol = 0; double min_lot = MarketInfo(Symbol(), MODE_MINLOT);
   if(bl > sl) {
      vol = NormalizeDouble(bl - sl, lot_digits);
      if(vol >= min_lot) SmartOrderSend(OP_SELL, vol, Bid, 3 * P, 0, 0, "Lock", MagicNumber, 0, Red);
   } else if(sl > bl) {
      vol = NormalizeDouble(sl - bl, lot_digits);
      if(vol >= min_lot) SmartOrderSend(OP_BUY, vol, Ask, 3 * P, 0, 0, "Lock", MagicNumber, 0, Blue);
   }
  }

void DisableAllTakeProfits_m(int magic)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderTakeProfit() != 0)
            if(!OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), 0, 0))
               Print("DisableAllTakeProfits_m Error: ", GetLastError());
  }

void DeleteAllPendingOrders_m(int magic)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType() > 1)
            if(!OrderDelete(OrderTicket()))
               Print("DeleteAllPendingOrders_m Error: ", GetLastError());
  }

void CreatePanel(string name,ENUM_OBJECT Type,string text,int XDistance,int YDistance,int Width,int Hight,
                 color BGColor_,color InfoColor,color boarderColor,int fontsize,bool readonly=false,bool Obj_Selectable=false,int Corner=0,ENUM_ALIGN_MODE Align=ALIGN_LEFT)
  {
   if(ObjectFind(0,name)==-1) {
      ObjectCreate(0,name,Type,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,XDistance);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,YDistance);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,Width);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,Hight);
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,BGColor_);
      ObjectSetInteger(0,name,OBJPROP_COLOR,InfoColor);
      if(Type==OBJ_EDIT) ObjectSetInteger(0,name,OBJPROP_READONLY,readonly);
   } else if(ObjectGetString(0,name,OBJPROP_TEXT)!=text) ObjectSetString(0,name,OBJPROP_TEXT,text);
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
