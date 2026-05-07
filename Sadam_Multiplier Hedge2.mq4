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
    }
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
 
   