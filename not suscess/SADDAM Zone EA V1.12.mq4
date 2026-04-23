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
input string magic2_params = " Secondary Cycle Settings ";
input bool EnableMagic2 = false;
input int Step2 = 50;
input int magicNumbr2 = 2036;

double point;
int digits,P;
int lot_digits;
bool IsHedgingMode=false;
double HedgeEntryPrice=0;
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
   
   return(INIT_SUCCEEDED);
  }
  
  void DrawAccountInfo(datetime StartCycleTime)
   {
    int X_Shift=10;
    int Y_Shift=40;
    int Added_X=0,Added_Y=0;
    CreatePanel("Panel_Info_1",OBJ_EDIT,"BUY Lots",X_Shift+Added_X,Y_Shift+Added_Y,80,20,Black,White,Black,10,true,false,0,ALIGN_LEFT);Added_X+=95;
    CreatePanel("Panel_Info_2",OBJ_EDIT,DoubleToStr(TotalLots(OP_BUY),2),X_Shift+Added_X,Y_Shift+Added_Y,70,20,Black,White,Red,10,true,false,0,ALIGN_CENTER);Added_X-=95;Added_Y+=35;
    
    CreatePanel("Panel_Info_3",OBJ_EDIT,"SELL Lots",X_Shift+Added_X,Y_Shift+Added_Y,80,20,Black,White,Black,10,true,false,0,ALIGN_LEFT);Added_X+=95;
    CreatePanel("Panel_Info_4",OBJ_EDIT,DoubleToStr(TotalLots(OP_SELL),2),X_Shift+Added_X,Y_Shift+Added_Y,70,20,Black,White,Red,10,true,false,0,ALIGN_CENTER);Added_X-=95;Added_Y+=35;
    
    CreatePanel("Panel_Info_5",OBJ_EDIT,"Time Minutes Lots",X_Shift+Added_X,Y_Shift+Added_Y,80,20,Black,White,Black,10,true,false,0,ALIGN_LEFT);Added_X+=95;
    CreatePanel("Panel_Info_6",OBJ_EDIT,NormalizeDouble((TimeCurrent()-LastCurrentOrderInfo("Time"))/60,1),X_Shift+Added_X,Y_Shift+Added_Y,70,20,Black,White,Red,10,true,false,0,ALIGN_CENTER);Added_X-=95;Added_Y+=35;
    
    CreatePanel("Panel_Info_7",OBJ_EDIT,"Cycle Closed Trades Profit: ",X_Shift+Added_X,Y_Shift+Added_Y,80,20,Black,White,Black,10,true,false,0,ALIGN_LEFT);Added_X+=95;
    CreatePanel("Panel_Info_8",OBJ_EDIT,TotalGainedProfit(StartCycleTime),X_Shift+Added_X,Y_Shift+Added_Y,70,20,Black,White,Red,10,true,false,0,ALIGN_CENTER);Added_X-=95;Added_Y+=35;
    
    CreatePanel("Panel_Info_9",OBJ_EDIT,"Cycle Open Trades Profit: ",X_Shift+Added_X,Y_Shift+Added_Y,80,20,Black,White,Black,10,true,false,0,ALIGN_LEFT);Added_X+=95;
    CreatePanel("Panel_Info_10",OBJ_EDIT,TotalProfit(),X_Shift+Added_X,Y_Shift+Added_Y,70,20,Black,White,Red,10,true,false,0,ALIGN_CENTER);Added_X-=95;Added_Y+=35;
    
    CreatePanel("Panel_Info_11",OBJ_EDIT,"Total : ",X_Shift+Added_X,Y_Shift+Added_Y,80,20,Black,White,Black,10,true,false,0,ALIGN_LEFT);Added_X+=95;
    CreatePanel("Panel_Info_12",OBJ_EDIT,TotalGainedProfit(StartCycleTime)+TotalProfit(),X_Shift+Added_X,Y_Shift+Added_Y,70,20,Black,White,Red,10,true,false,0,ALIGN_CENTER);Added_X-=95;Added_Y+=35;
   }        
//+------------------------------------------------------------------+
//| FUNCTION DEFINITIONS    deinitialization function                |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
  {
   Comment("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int orderscnt(int type=-1)
  {
   int cnt=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && MagicNumber==OrderMagicNumber() && (OrderType()==type || type==-1))
           {
            cnt++;
           }
        }
     }
   return(cnt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TimeFilter(string StartH,string EndH)
  {
   datetime Start=StrToTime(TimeToStr(TimeCurrent(),TIME_DATE)+" "+StartH);
   datetime End=StrToTime(TimeToStr(TimeCurrent(),TIME_DATE)+" "+EndH);

   if(!(Time[0]>=Start && Time[0]<=End))
     {
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| FUNCTION DEFINITIONS   Start function                            |
//+------------------------------------------------------------------+

bool transfair=false;

void OnTick()
  {
   if(ObjectGetInteger(0,"Panel_Info_close",OBJPROP_STATE))
     {
      CloseAll();
      ObjectSetInteger(0,"Panel_Info_close",OBJPROP_STATE,false);
     }
   if(ObjectGetInteger(0,"Panel_Info_transfair",OBJPROP_STATE))
     {
      transfair=true;
      ObjectSetInteger(0,"Panel_Info_transfair",OBJPROP_STATE,false);
     }

   if(EnableTimeFilter&&TimeFilter(Start_Hour,End_Hour)==false)return;
   static bool stopEA;
   static datetime StartCycleTime;

   DrawAccountInfo(StartCycleTime);

   // Check for transition to Hedging Mode
   if(!IsHedgingMode)
     {
      if(TotalLots(OP_BUY)>=MaxLots || TotalLots(OP_SELL)>=MaxLots)
        {
         IsHedgingMode=true;
         HedgeEntryPrice = Bid;
         Print("MaxLots reached. Switching to Hedging Mode Scenario #2. Entry Price: ", HedgeEntryPrice);
         DisableAllTakeProfits(); // Step 1: Disable TakeProfit
         DeleteAllPendingOrders(); // Step 1: Market orders only
         ExecuteLock(); // Step 1: Lock Positions (Full Hedge)
        }
     }

   if(IsHedgingMode)
     {
      // Scenario #2: Hedging Mode - Crisis Management
      
      // Step 0: Ensure 1:1 Balance (Continuous Lock)
      double balanceDiff = TotalLots(OP_BUY) - TotalLots(OP_SELL);
      if(MathAbs(balanceDiff) > 0.001)
        {
          ExecuteLock();
        }

      // Step 6: Secondary Cycle Stacking
      if(EnableMagic2 && orderscnt_m(magicNumbr2) == 0)
        {
         if(MathAbs(Bid - HedgeEntryPrice) >= Step2 * point)
           {
            Print("Secondary Cycle Triggered at Price: ", Bid, " (Distance from Hedge Start: ", Step2, " pips)");
            StartSecondaryGrid();
           }
        }

      // Step 5: Exit Hedging Mode
      if(MathMax(TotalLots(OP_BUY), TotalLots(OP_SELL)) <= MinLots)
        {
         IsHedgingMode = false;
         Print("Hedge reduction completed. Returning to normal strategy.");
        }
      else
        {
         // Reduction Cycle (Step 2, 3, 4)
         if(orderscnt() > 0 && (TimeCurrent() - LastCurrentOrderInfo("Time") >= WaitingMinutes * 60 || transfair))
           {
            bool reduced = false;
            double hedge_profit = 0;
            
            double lastBuyPrice = LastCurrentOrderInfo("Price", OP_BUY);
            double lastSellPrice = LastCurrentOrderInfo("Price", OP_SELL);

            // Universal Reduction Logic: If price moves in favor of any side
            if(lastBuyPrice > 0 && Bid - lastBuyPrice >= PipsToTransfair * point)
              {
                hedge_profit = CloseSelectedWinners(OP_BUY);
                if(hedge_profit > 0)
                  {
                   ClosePercentOfLoss(OP_SELL, hedge_profit);
                   reduced = true;
                  }
              }
            else if(lastSellPrice > 0 && lastSellPrice - Ask >= PipsToTransfair * point)
              {
                hedge_profit = CloseSelectedWinners(OP_SELL);
                if(hedge_profit > 0)
                  {
                   ClosePercentOfLoss(OP_BUY, hedge_profit);
                   reduced = true;
                  }
              }

            if(reduced)
              {
               transfair = false;
               ExecuteLock(); // Step 3 & 4: Re-Lock correctly
              }
           }
         return; // Bypass original grid logic while in Hedging Mode
        }
     }
  

   
   double newLot,TP=0,SL=0,price,newLotPending,profit;
   int ticket;

   ModifyAllOrdersTP(OP_SELL);
   ModifyAllOrdersTP(OP_BUY);
   if(orderscnt(OP_BUY)+orderscnt(OP_SELL)==0 && orderscnt()>0)
     {
      CloseAll();
     }
   if(orderscnt()>0 && TotalGainedProfit(StartCycleTime)+TotalProfit()>=TARGET && TARGET!=0)
     {
      CloseAll();
     }
   if(CloseAtMaxTrades && orderscnt()>=MaxTrades && MaxTrades!=0)
     {
      CloseAll();
     }
   if(EnableProfitUSD && TotalProfit()>=TotalProfitUSD)
     {
      CloseAll();
     }
     
      if(!IsHedgingMode && ((orderscnt(OP_SELL)+orderscnt(OP_SELLSTOP)==0) || (orderscnt(OP_BUY)+orderscnt(OP_BUYSTOP)==0)) && orderscnt()>1)
     {
      CloseAll();
     }

   if(orderscnt()>0 && (orderscnt()<MaxTrades || MaxTrades==0))
     {

      if(LastCurrentOrderInfo("Type")==OP_BUY && orderscnt(OP_SELLSTOP)==0)
        {

         price=LastCurrentOrderInfo("Price")-Step*point;
         if(TakeProfit!=0)TP=price-TakeProfit*point;
         if(StopLoss!=0)SL=price+StopLoss*point;

         newLot=NormalizeDouble(LastCurrentOrderInfo("Lots",OP_BUY)*Multiplier,lot_digits);

         ticket=OrderSend(Symbol(),OP_SELLSTOP,newLot,NormalizeDouble(price,Digits),3*P,SL,TP,"EA",MagicNumber,0,Red);

         if(ticket<0)Print("Open Sell Stop Error: "+GetLastError());

        }

      if(LastCurrentOrderInfo("Type")==OP_SELL && orderscnt(OP_BUYSTOP)==0)
        {

         price=LastCurrentOrderInfo("Price")+Step*point;
         if(TakeProfit!=0)TP=price+TakeProfit*point;
         if(StopLoss!=0)SL=price-StopLoss*point;
         newLot=NormalizeDouble(LastCurrentOrderInfo("Lots",OP_SELL)*Multiplier,lot_digits);

         ticket=OrderSend(Symbol(),OP_BUYSTOP,newLot,NormalizeDouble(price,Digits),3*P,SL,TP,"EA",MagicNumber,0,Blue);

         if(ticket<0)Print("Open Buy Stop Error: "+GetLastError());

        }
     }
     
   if(orderscnt()>MultiplierNumber && (TimeCurrent()-LastCurrentOrderInfo("Time")>=WaitingMinutes*60 || transfair))
     {
      transfair=false;
      if(LastCurrentOrderInfo("Type")==OP_BUY)
        {

         if(Bid-LastCurrentOrderInfo("Price")>=PipsToTransfair*point)
           {
            profit = CloseSelectedWinners(OP_BUY);
            if(profit > 0)
              {
                ClosePercentOfLoss(OP_SELL,profit);
              }
            if(TakeProfit==0){TP=0;}else{TP=Ask+TakeProfit*point;}
            if(StopLoss!=0)SL=Ask-StopLoss*point;
            newLot=NormalizeDouble(TotalLots(OP_SELL)*Multiplier,lot_digits);
            
            CloseAll(OP_SELLSTOP);

            ticket=OrderSend(Symbol(),OP_BUY,newLot,NormalizeDouble(Ask,Digits),3*P,SL,TP,"EA",MagicNumber,0,Blue);

            price=LastCurrentOrderInfo("Price")-Step*point-PipsToTransfair*point;
            if(TakeProfit!=0)TP=price-TakeProfit*point;
            if(StopLoss!=0)SL=price+StopLoss*point;

            newLotPending=NormalizeDouble(newLot*Multiplier,lot_digits);
            ticket=OrderSend(Symbol(),OP_SELLSTOP,newLotPending,NormalizeDouble(price,Digits),3*P,SL,TP,"EA",MagicNumber,0,Red);
           }
        }
      else if(LastCurrentOrderInfo("Type")==OP_SELL)
        {
         if(LastCurrentOrderInfo("Price")-Ask>=PipsToTransfair*point)
           {
            profit = CloseSelectedWinners(OP_SELL);
            if(profit > 0)
              {
                ClosePercentOfLoss(OP_BUY,profit);
              }

            if(TakeProfit==0){TP=0;}else{TP=Bid-TakeProfit*point;}
            if(StopLoss!=0)SL=Bid+StopLoss*point;
            newLot=NormalizeDouble(TotalLots(OP_BUY)*Multiplier,lot_digits);
            
            CloseAll(OP_BUYSTOP);

            ticket=OrderSend(Symbol(),OP_SELL,newLot,NormalizeDouble(Bid,Digits),3*P,SL,TP,"EA",MagicNumber,0,Red);

            price=LastCurrentOrderInfo("Price")+Step*point+PipsToTransfair*point;
            if(TakeProfit!=0)TP=price+TakeProfit*point;
            if(StopLoss!=0)SL=price-StopLoss*point;
            newLotPending=NormalizeDouble(newLot*Multiplier,lot_digits);
            ticket=OrderSend(Symbol(),OP_BUYSTOP,newLotPending,NormalizeDouble(price,Digits),3*P,SL,TP,"EA",MagicNumber,0,Blue);
           }
        }
     }

   if(MoneyManagement) newLot=LotManage();
   else newLot=Lots;

   if(orderscnt()<1 && !stopEA)
     {
      StartCycleTime=TimeCurrent();
      if(RunOnce)stopEA=true;
      if(FirstOrder==BUY)
        {
         if(TakeProfit==0){TP=0;}else{TP=Ask+TakeProfit*point;}
         if(StopLoss!=0)SL=Ask-StopLoss*point;

         ticket=OrderSend(Symbol(),OP_BUY,newLot,NormalizeDouble(Ask,Digits),3*P,SL,TP,"EA",MagicNumber,0,Blue);
        }
      else
        {
         if(TakeProfit==0){TP=0;}else{TP=Bid-TakeProfit*point;}
         if(StopLoss!=0)SL=Bid+StopLoss*point;

         ticket=OrderSend(Symbol(),OP_SELL,newLot,NormalizeDouble(Bid,Digits),3*P,SL,TP,"EA",MagicNumber,0,Red);
        }
      if(ticket<0)Print("Open Error: "+GetLastError());
      PlaySound("Alert.wav");
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {

   if(id==CHARTEVENT_OBJECT_CLICK)
     {

      string Object_Name=ObjectGetString(0,sparam,OBJPROP_NAME);

      if(Object_Name=="Panel_Info_close")
        {

         CloseAll();

         ObjectSetInteger(0,Object_Name,OBJPROP_STATE,false);

        }

      else if(Object_Name=="Panel_Info_transfair")
        {

         transfair=true;

         ObjectSetInteger(0,Object_Name,OBJPROP_STATE,false);
        }

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LastClosedOrderInfo(string info,int type=-1)
  {
   for(int i=OrdersHistoryTotal()-1;i>=0;i--)
     {
      bool select=OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && (OrderType()==type || type==-1))
        {
         if(info=="Type")return(OrderType());
         else if(info=="Lots")return(OrderLots());
         else if(info=="Price")return(OrderOpenPrice());
         else if(info=="TP")return(OrderTakeProfit());
         else if(info=="SL")return(OrderStopLoss());
         else if(info=="Profit")return(OrderProfit());
         else if(info=="Time")return(OrderCloseTime());

        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TotalGainedProfit(datetime TimeCheck)
  {
   double profit;
   for(int i=OrdersHistoryTotal()-1;i>=0;i--)
     {
      bool select=OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(OrderOpenTime()>=TimeCheck)
            profit+=OrderProfit();
         else return(profit);
        }
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LastCurrentOrderInfo(string info,int type=-1)
  {
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      bool select=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && (OrderType()==type || type==-1) && OrderType()<=OP_SELL)
        {
         if(info=="Type")return(OrderType());
         else if(info=="Lots")return(OrderLots());
         else if(info=="Price")return(OrderOpenPrice());
         else if(info=="TP")return(OrderTakeProfit());
         else if(info=="SL")return(OrderStopLoss());
         else if(info=="Profit")return(OrderProfit());
         else if(info=="Time")return(OrderOpenTime());
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyAllOrdersTP(int type)
  {
   double TP=LastCurrentOrderInfo("TP",type);
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      bool select=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && (OrderType()==type || type==-1))
        {
         if(OrderTakeProfit()!=TP)
           {
            bool modify=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),TP,0);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| FUNCTION DEFINITIONS   Money Managment                           |
//+------------------------------------------------------------------+ 

double LotManage()
  {
   double lot=MathCeil(AccountFreeMargin() *Risk/1000)/100;

   if(lot<MarketInfo(Symbol(),MODE_MINLOT))lot=MarketInfo(Symbol(),MODE_MINLOT);
   if(lot>MarketInfo(Symbol(),MODE_MAXLOT))lot=MarketInfo(Symbol(),MODE_MAXLOT);


   return (NormalizeDouble(lot,2));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll(int type=-1)
  {

   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      bool select=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && (OrderType()==type || type==-1))
        {
         if(OrderType()==OP_BUY)
           {
            bool close_b=OrderClose(OrderTicket(),OrderLots(),Bid,3*P);
           }
         else if(OrderType()==OP_SELL)
           {
            bool close_s=OrderClose(OrderTicket(),OrderLots(),Ask,3*P);
           }
         else
           {
            bool del=OrderDelete(OrderTicket());
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TotalClosedProfit(datetime time,int type)
  {
   double profit;
   for(int i=OrdersHistoryTotal()-1;i>=0;i--)
     {
      bool select=OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==type)
        {
         if(OrderCloseTime()>=time)
            profit+=OrderProfit();
         else
            return(profit);
        }

     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double TotalProfit(int type=-1)
  {
   double profit;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      bool select=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && (OrderType()==type || type==-1))
        {
         profit+=OrderProfit();
        }

     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TotalLots(int type)
  {
   double lots;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      bool select=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==type)
        {
         lots+=OrderLots();
        }
     }
   return(lots);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int orderscnt_m(int magic, int type=-1)
  {
   int cnt=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && magic==OrderMagicNumber() && (OrderType()==type || type==-1))
           {
            cnt++;
           }
        }
     }
   return(cnt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TotalLots_m(int magic, int type)
  {
   double lots=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && magic==OrderMagicNumber() && OrderType()==type)
           {
            lots+=OrderLots();
           }
        }
     }
   return(lots);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StartSecondaryGrid()
  {
   double newLot = Lots;
   if(MoneyManagement) newLot = LotManage();
   
   double TP=0, SL=0;
   int ticket = -1;
   
   if(FirstOrder==BUY)
     {
      if(TakeProfit==0){TP=0;}else{TP=Ask+TakeProfit*point;}
      if(StopLoss!=0)SL=Ask-StopLoss*point;
      ticket=OrderSend(Symbol(),OP_BUY,newLot,NormalizeDouble(Ask,Digits),3*P,SL,TP,"Secondary Magic",magicNumbr2,0,Blue);
     }
   else
     {
      if(TakeProfit==0){TP=0;}else{TP=Bid-TakeProfit*point;}
      if(StopLoss!=0)SL=Bid+StopLoss*point;
      ticket=OrderSend(Symbol(),OP_SELL,newLot,NormalizeDouble(Bid,Digits),3*P,SL,TP,"Secondary Magic",magicNumbr2,0,Red);
     }
   
   if(ticket<0) Print("StartSecondaryGrid Error: ", GetLastError());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CloseSelectedWinners(int type)
  {
   double totalProf=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==type)
           {
            if(OrderProfit()>0)
              {
               double p = OrderProfit();
               double pr = Bid; if(type==OP_SELL) pr = Ask;
               if(OrderClose(OrderTicket(),OrderLots(),pr,3*P))
                 {
                  totalProf += p;
                 }
              }
           }
        }
     }
   return(totalProf);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePercentOfLoss(int type,double closedprofit)
  {
   if(closedprofit <= 0) return;
   double profitToclose=closedprofit*PF_Percent/100;

   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==type && OrderProfit()<0)
           {
            double orderprofit=OrderProfit();
            double orderlots=OrderLots();

            double percentOfLotsToClose=MathAbs(profitToclose/orderprofit)*100;
            double lots;
            if(percentOfLotsToClose>=100)lots=orderlots;
            else lots=NormalizeDouble(orderlots*percentOfLotsToClose/100, lot_digits);

            if(lots < MarketInfo(Symbol(), MODE_MINLOT)) continue;

            double pr = Bid; if(type==OP_SELL) pr = Ask;
            if(OrderClose(OrderTicket(),lots,pr,3*P))
              {
               double realizedLoss = orderprofit * (lots / orderlots);
               profitToclose += realizedLoss; // realizedLoss is negative, reducing profitToclose
              }
            
            if(profitToclose<=0)break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
      ObjectSetString(0,name,OBJPROP_FONT,"Arial Bold");
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
      ObjectSetInteger(0,name,OBJPROP_CORNER,Corner);
      ObjectSetInteger(0,name,OBJPROP_COLOR,InfoColor);
      ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,boarderColor);
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,BGColor_);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,Obj_Selectable);

      if(Type==OBJ_EDIT)
        {
         ObjectSetInteger(0,name,OBJPROP_ALIGN,Align);
         ObjectSetInteger(0,name,OBJPROP_READONLY,readonly);
        }
     }
    if(ObjectGet(name,OBJPROP_TEXT)!=text)
      {
       ObjectSetString(0,name,OBJPROP_TEXT,text);
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExecuteLock()
  {
   double buy_lots = TotalLots(OP_BUY);
   double sell_lots = TotalLots(OP_SELL);
   double volume = 0;
   int ticket = -1;
   double min_lot = MarketInfo(Symbol(), MODE_MINLOT);
   
   if(buy_lots > sell_lots)
     {
      volume = NormalizeDouble(buy_lots - sell_lots, lot_digits);
      if(volume >= min_lot)
        {
         ticket = OrderSend(Symbol(), OP_SELL, volume, NormalizeDouble(Bid, Digits), 3 * P, 0, 0, "Hedge Lock", MagicNumber, 0, Red);
         if(ticket < 0) Print("ExecuteLock SELL Error: ", GetLastError());
        }
     }
   else if(sell_lots > buy_lots)
     {
      volume = NormalizeDouble(sell_lots - buy_lots, lot_digits);
      if(volume >= min_lot)
        {
         ticket = OrderSend(Symbol(), OP_BUY, volume, NormalizeDouble(Ask, Digits), 3 * P, 0, 0, "Hedge Lock", MagicNumber, 0, Blue);
         if(ticket < 0) Print("ExecuteLock BUY Error: ", GetLastError());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisableAllTakeProfits()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()<=OP_SELL)
           {
            if(OrderTakeProfit() != 0)
              {
               bool res = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), 0, 0, clrNONE);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllPendingOrders()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType() > OP_SELL)
           {
            bool res = OrderDelete(OrderTicket());
           }
        }
     }
  }
