 //+------------------------------------------------------------------+
 //|                                                                  |
 //|                                                                  |
 //|                                      www.arabictrader.com/vb     |
 //|                                                                  |
 //|                                          mrdollar.cs@gmail.com   |
 //+------------------------------------------------------------------+
 
#property copyright "MR.dollarEA"
#property link      "mrdollar.cs@gmail.com"



 extern int MaxMutliplierOrders=100;    
 extern string S1=" Multiplier Settings";
 extern int Step=20;
 extern double Lot_Multi=1.55;
 extern int StartHedgeMultiplier=2;
 extern double FirstHedgeLot=1;
 extern bool Descending_Multiplier=true;
 extern double Hede_Lot_Multi=1.55;
extern int HedgePrecentLot=100;
  extern int TakeProfit=30;
 extern bool CloseOnUSDProfit=false;
 extern double Profit=200;         
 extern double Lots=0.1;                                      
 extern bool  UseMoneyManagement = false;                 
 extern double  RiskPercent = 10;                      

 
 
 double point;
 int digits,Q;
 double FirstHedge;
 extern int MagicNumber=2533;  
 int Lot_Digits;
 
 datetime Time0;                           
 datetime StartCycleTime;
 int init()
{
  if(MarketInfo(Symbol(),MODE_MINLOT)<0.1)Lot_Digits=2;
  else Lot_Digits=1;
  if(Digits==5||Digits==3)Q=10;
  else Q=1;
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
return(0);
}

 //+------------------------------------------------------------------+
 //| FUNCTION DEFINITIONS    deinitialization function                |
 //+------------------------------------------------------------------+

 void deinit() {
    Comment("");
    ObjectsDeleteAll(0, "Panel_Info_");
  }

 int orderscnt(int type,string comment){
  int cnt=0;
   for(int i =0;i<=OrdersTotal();i++){
     if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
       if(OrderSymbol()==Symbol() && MagicNumber==OrderMagicNumber()&&OrderType()==type&&(OrderComment()==comment||comment=="")){
         cnt++;
       }
     }
   }
   return(cnt);
  }

 //+------------------------------------------------------------------+
 //| FUNCTION DEFINITIONS   Start function                            |
 //+------------------------------------------------------------------+

 int start()
   {
    Comment("Programmed by MR.dollar"+"\n"+"ãäÊÏì ÇáãÊÏÇæá ÇáÚÑÈí"+"\n"+"Idea By ÕÏÇã"+"\n"+"www.arabictrader.com/vb");
      
        
        
       
      //////////////////////////////////////////////////
      int Tried;
      if((CloseOnUSDProfit&&profit(OP_BUY)+profit(OP_SELL)>=Profit)||(orderscnt(OP_BUY,"")==0&&orderscnt(OP_SELL,"")>0)||
          (orderscnt(OP_BUY,"")>0&&orderscnt(OP_SELL,"")==0)){
       while(orderscnt(OP_BUY,"")+orderscnt(OP_SELL,"")>0&&Tried<20){
        CloseBuyOrders();CloseSellOrders();
        Tried++;
       }
      }
      
      double newLot;
      static double HedgeLot;
      if(orderscnt(OP_SELL,"Multi EA")<MaxMutliplierOrders&&orderscnt(OP_SELL,"")>0){
        if(orderscnt(OP_SELL,"Multi EA")>0)newLot=NormalizeDouble(Lot_Multi*LastLot(OP_SELL,"Multi EA"),Lot_Digits);
        else newLot=NormalizeDouble(Lot_Multi*LastLot(OP_SELL,"MR.dollar EA"),Lot_Digits);
       if(Bid>=Lastopenprice(OP_SELL)+Step*point&&Time0!=Time[0]){
        if(OrderSend(Symbol(),OP_SELL,newLot,NormalizeDouble(Bid,digits),3*Q,0,0,"Multi EA",MagicNumber,0,Red) < 0) Print("OrderSend failed with error #", GetLastError());
        
        if(orderscnt(OP_SELL,"Multi EA")>=StartHedgeMultiplier){
          if(FirstHedge==-1)newLot=(HedgeLot*HedgePrecentLot)/100;
          else if(orderscnt(OP_BUY,"Hedge EA")==0)newLot=FirstHedgeLot;
           else {
            if(Descending_Multiplier)newLot=NormalizeDouble(LastLot(OP_BUY,"Hedge EA")/Hede_Lot_Multi,Lot_Digits);
            else newLot=NormalizeDouble(LastLot(OP_BUY,"Hedge EA")*Hede_Lot_Multi,Lot_Digits);
           }
         if(OrderSend(Symbol(),OP_BUY,newLot,NormalizeDouble(Ask,digits),3*Q,0,0,"Hedge EA",MagicNumber,0,Blue) < 0) Print("OrderSend failed with error #", GetLastError());
         if(FirstHedge==0)FirstHedge=1;
         if(FirstHedge==1)HedgeLot=newLot;
        }
         Time0=Time[0];
        }
      }
        
      if(orderscnt(OP_BUY,"Multi EA")<MaxMutliplierOrders&&orderscnt(OP_BUY,"")>0){
       if(orderscnt(OP_BUY,"Multi EA")>0)newLot=NormalizeDouble(Lot_Multi*LastLot(OP_BUY,"Multi EA"),Lot_Digits);
       else newLot=NormalizeDouble(Lot_Multi*LastLot(OP_BUY,"MR.dollar EA"),Lot_Digits);
       if(Ask<=Lastopenprice(OP_BUY)-Step*point&&Time0!=Time[0]){
        if(OrderSend(Symbol(),OP_BUY,newLot,NormalizeDouble(Ask,digits),3*Q,0,0,"Multi EA",MagicNumber,0,Blue) < 0) Print("OrderSend failed with error #", GetLastError());
        
         if(orderscnt(OP_BUY,"Multi EA")>=StartHedgeMultiplier){
          if(FirstHedge==1)newLot=(HedgeLot*HedgePrecentLot)/100;
           else if(orderscnt(OP_SELL,"Hedge EA")==0)newLot=FirstHedgeLot;
            else {
             if(Descending_Multiplier)newLot=NormalizeDouble(LastLot(OP_SELL,"Hedge EA")/Hede_Lot_Multi,Lot_Digits);
             else newLot=NormalizeDouble(LastLot(OP_SELL,"Hedge EA")*Hede_Lot_Multi,Lot_Digits);
            }
          if(OrderSend(Symbol(),OP_SELL,newLot,NormalizeDouble(Bid,digits),3*Q,0,0,"Hedge EA",MagicNumber,0,Red) < 0) Print("OrderSend failed with error #", GetLastError());
          if(FirstHedge==0)FirstHedge=-1;
          if(FirstHedge==-1)HedgeLot=newLot;
         }
         Time0=Time[0];
       }
      }
      
     if(orderscnt(OP_BUY,"Multi EA")!=0){
      ModifyOrders(OP_BUY);
     }
     if(orderscnt(OP_SELL,"Multi EA")!=0){
      ModifyOrders(OP_SELL);
     }
   ////////////////////////////////////////////////////
    
      
     
    if(UseMoneyManagement)Lots = LotManage();
       
          
      if (orderscnt(OP_BUY,"")+orderscnt(OP_SELL,"")<1){
         if(OrderSend(Symbol(),OP_BUY,Lots,NormalizeDouble(Ask,Digits),3*Q,0,0,"MR.dollar EA",MagicNumber,0,Blue) < 0) Print("OrderSend failed with error #", GetLastError());
         if(OrderSend(Symbol(),OP_SELL,Lots,NormalizeDouble(Bid,Digits),3*Q,0,0,"MR.dollar EA",MagicNumber,0,Red) < 0) Print("OrderSend failed with error #", GetLastError()); 
         PlaySound("Alert.wav");
      Time0=Time[0];FirstHedge=0;
      StartCycleTime = TimeCurrent();
    }
    
    DrawAccountInfo(StartCycleTime);
    
    return(0);
  }
    
   
  
//+------------------------------------------------------------------+

 
void ModifyOrders(int type){
for(int i=0;i<=OrdersTotal();i++){
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
double take=OrderTakeProfit();int ticket=OrderTicket();int ordertype=OrderType();

if(OrderSymbol()==Symbol()&&OrderType()==type&&OrderMagicNumber()==MagicNumber){

if(NormalizeDouble(take,Digits)!=NormalizeDouble(AvTP(type)+TakeProfit*point,Digits)&&ordertype==OP_BUY)
  if(!OrderModify(ticket,OrderOpenPrice(),OrderStopLoss(),AvTP(type)+TakeProfit*point,0)) Print("OrderModify failed with error #", GetLastError());
  
if(NormalizeDouble(take,Digits)!=NormalizeDouble(AvTP(type)-TakeProfit*point,Digits)&&ordertype==OP_SELL)
 if(!OrderModify(ticket,OrderOpenPrice(),OrderStopLoss(),AvTP(type)-TakeProfit*point,0)) Print("OrderModify failed with error #", GetLastError());
   }
  }
 }
}


 double LotManage()
  {
      double lot = MathCeil(AccountFreeMargin() *  RiskPercent / 1000) / 100; 
	  
	  if(lot<MarketInfo(Symbol(),MODE_MINLOT))lot=MarketInfo(Symbol(),MODE_MINLOT);
	  if(lot>MarketInfo(Symbol(),MODE_MAXLOT))lot=MarketInfo(Symbol(),MODE_MAXLOT);
	  
	   
	   return (lot);
  }
int CloseBuyOrders()
{
  for (int cnt = 0 ; cnt <= OrdersTotal() ; cnt++)
  {
    if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
    {
      if (OrderMagicNumber() == MagicNumber && OrderSymbol()==Symbol())
      {
        if (OrderType()==OP_BUY)
        {
          if(!OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),3)) Print("OrderClose failed with error #", GetLastError());
        }
      }
    }
  }
  return(0);
}  

int CloseSellOrders()
{
 for (int cnt = 0 ; cnt <= OrdersTotal() ; cnt++)
  {
    if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
    {
      if (OrderMagicNumber() == MagicNumber && OrderSymbol()==Symbol())
      {
        if (OrderType()==OP_SELL)
        {
         if(!OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),3)) Print("OrderClose failed with error #", GetLastError());
        }
       }
    }
  }
  return(0);
}  

double profit(int type){
double c = 0;
for(int i=OrdersTotal();i>=0;i--){
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
if(OrderSymbol()==Symbol()&&OrderType()==type&&OrderMagicNumber()==MagicNumber){
c=c+OrderProfit();
}
 }
}
return(c);
} 

double LastLot(int type,string comment){
 for(int i=OrdersTotal();i>=0;i--){
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
    if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber&&OrderType()==type&&OrderComment()==comment){
     return(OrderLots());
    }
  }
 }
 return(0);
}
double Lastopenprice(int type){
 for(int i=OrdersTotal();i>=0;i--){
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
    double L=OrderLots();
    if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber&&OrderType()==type&&OrderComment()!="Hedge EA"){
     return(OrderOpenPrice());
    }
  }
 }
 return(0);
}

double AvTP(int type){
double Price = 0;double totalLots = 0;
for(int i=0;i<=OrdersTotal();i++){
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber&&OrderType()==type){
Price+=OrderOpenPrice()*OrderLots();
totalLots+=OrderLots();
  }
 }
}

if(totalLots!=0) return(Price/totalLots);
return(0);
}


  //+---------------------------------------------------------------------------------+
void DrawAccountInfo(datetime StartCycleTime_)
{
    int X_Shift = 10;
    int Y_Shift = 80; 
    int Added_Y = 0;
    int LabelWidth = 80;
    int ValueWidth = 80;
    int RowHeight = 22;

    // Row 1: Balance
    CreatePanel("Panel_Info_1", OBJ_EDIT, "Balance", X_Shift, Y_Shift + Added_Y, LabelWidth, 20, C'45,45,45', White, White, 8, true, false, 0, ALIGN_LEFT);
    CreatePanel("Panel_Info_2", OBJ_EDIT, DoubleToStr(AccountBalance(), 2), X_Shift + LabelWidth, Y_Shift + Added_Y, ValueWidth, 20, C'30,30,30', White, Green, 8, true, false, 0, ALIGN_CENTER);
    Added_Y += RowHeight;

    // Row 2: Equity
    CreatePanel("Panel_Info_3", OBJ_EDIT, "Equity", X_Shift, Y_Shift + Added_Y, LabelWidth, 20, C'45,45,45', White, White, 8, true, false, 0, ALIGN_LEFT);
    CreatePanel("Panel_Info_4", OBJ_EDIT, DoubleToStr(AccountEquity(), 2), X_Shift + LabelWidth, Y_Shift + Added_Y, ValueWidth, 20, C'30,30,30', White, Green, 8, true, false, 0, ALIGN_CENTER);
    Added_Y += RowHeight;

    // Row 3: Profit
    CreatePanel("Panel_Info_5", OBJ_EDIT, "Profit", X_Shift, Y_Shift + Added_Y, LabelWidth, 20, Black, White, Black, 8, true, false, 0, ALIGN_LEFT);
    CreatePanel("Panel_Info_6", OBJ_EDIT, DoubleToStr(AccountProfit(), 2), X_Shift + LabelWidth, Y_Shift + Added_Y, ValueWidth, 20, Black, White, (AccountProfit() >= 0 ? Green : Red), 8, true, false, 0, ALIGN_CENTER);
    Added_Y += RowHeight + 5; // Small gap

    // Lots Info
    double bLots = TotalLots(OP_BUY);
    double sLots = TotalLots(OP_SELL);
    
    // Row 4: Buy Lots
    CreatePanel("Panel_Info_7", OBJ_EDIT, "Buy Lots", X_Shift, Y_Shift + Added_Y, LabelWidth, 20, Black, White, Black, 8, true, false, 0, ALIGN_LEFT);
    CreatePanel("Panel_Info_8", OBJ_EDIT, DoubleToStr(bLots, 2), X_Shift + LabelWidth, Y_Shift + Added_Y, ValueWidth, 20, Black, White, Blue, 8, true, false, 0, ALIGN_CENTER);
    Added_Y += RowHeight;

    // Row 5: Sell Lots
    CreatePanel("Panel_Info_9", OBJ_EDIT, "Sell Lots", X_Shift, Y_Shift + Added_Y, LabelWidth, 20, Black, White, Black, 8, true, false, 0, ALIGN_LEFT);
    CreatePanel("Panel_Info_10", OBJ_EDIT, DoubleToStr(sLots, 2), X_Shift + LabelWidth, Y_Shift + Added_Y, ValueWidth, 20, Black, White, Red, 8, true, false, 0, ALIGN_CENTER);
    Added_Y += RowHeight;

    // Row 6: Net Lots
    CreatePanel("Panel_Info_11", OBJ_EDIT, "Net Lots", X_Shift, Y_Shift + Added_Y, LabelWidth, 20, Black, White, Black, 8, true, false, 0, ALIGN_LEFT);
    CreatePanel("Panel_Info_12", OBJ_EDIT, DoubleToStr(bLots - sLots, 2), X_Shift + LabelWidth, Y_Shift + Added_Y, ValueWidth, 20, Black, White, (bLots - sLots >= 0 ? Blue : Red), 8, true, false, 0, ALIGN_CENTER);
    Added_Y += RowHeight + 5; // Small gap

    // Row 7: Buy Orders
    CreatePanel("Panel_Info_13", OBJ_EDIT, "Buy Orders", X_Shift, Y_Shift + Added_Y, LabelWidth, 20, Black, White, Black, 8, true, false, 0, ALIGN_LEFT);
    CreatePanel("Panel_Info_14", OBJ_EDIT, IntegerToString(orderscnt(OP_BUY, "")), X_Shift + LabelWidth, Y_Shift + Added_Y, ValueWidth, 20, Black, White, Blue, 8, true, false, 0, ALIGN_CENTER);
    Added_Y += RowHeight;

    // Row 8: Sell Orders
    CreatePanel("Panel_Info_15", OBJ_EDIT, "Sell Orders", X_Shift, Y_Shift + Added_Y, LabelWidth, 20, Black, White, Black, 8, true, false, 0, ALIGN_LEFT);
    CreatePanel("Panel_Info_16", OBJ_EDIT, IntegerToString(orderscnt(OP_SELL, "")), X_Shift + LabelWidth, Y_Shift + Added_Y, ValueWidth, 20, Black, White, Red, 8, true, false, 0, ALIGN_CENTER);
}


void CreatePanel(string name, ENUM_OBJECT Type, string text, int XDistance, int YDistance, int Width, int Hight,
                 color BGColor_, color InfoColor, color boarderColor, int fontsize, bool readonly = false, bool Obj_Selectable = false, int Corner = 0, ENUM_ALIGN_MODE Align = ALIGN_LEFT)
{
    if(ObjectFind(0, name) == -1)
    {
        ObjectCreate(0, name, Type, 0, 0, 0);
        ObjectSetInteger(0, name, OBJPROP_XDISTANCE, XDistance);
        ObjectSetInteger(0, name, OBJPROP_YDISTANCE, YDistance);
        ObjectSetInteger(0, name, OBJPROP_XSIZE, Width);
        ObjectSetInteger(0, name, OBJPROP_YSIZE, Hight);
        ObjectSetString(0, name, OBJPROP_TEXT, text);
        ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
        ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontsize);
        ObjectSetInteger(0, name, OBJPROP_CORNER, Corner);
        ObjectSetInteger(0, name, OBJPROP_COLOR, InfoColor);
        ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, boarderColor);
        ObjectSetInteger(0, name, OBJPROP_BGCOLOR, BGColor_);
        ObjectSetInteger(0, name, OBJPROP_SELECTABLE, Obj_Selectable);
        ObjectSetInteger(0, name, OBJPROP_BACK, false);

        if(Type == OBJ_EDIT)
        {
            ObjectSetInteger(0, name, OBJPROP_ALIGN, Align);
            ObjectSetInteger(0, name, OBJPROP_READONLY, readonly);
        }
    }
    if(ObjectGetString(0, name, OBJPROP_TEXT) != text)
    {
        ObjectSetString(0, name, OBJPROP_TEXT, text);
    }
}

double TotalLots(int type)
{
    double lots = 0;
    for(int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == type)
            {
                lots += OrderLots();
            }
        }
    }
    return(lots);
}
