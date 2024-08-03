//+------------------------------------------------------------------+
//|                                                    Correlate.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                                          georges |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "georges"
#property version   "1.00"
#property strict
#include "..//Libraries//stdlib.mq4" //this file makes the err description function work.

// Ichimoku_cloud_break_inputs
input int       InputTenkansen          =  9;
input int       InputKijunsen           =  26;
input int       InputSenkouspanb       =  52;
input int       LossLimit              = 10000; // Loss Limit in dollars 
input	double	InpOrderSize			=	0.5;	

//	For the basic template enter sl and tp in points, this usually changes by strategy
input	int		InpTakeProfitPts		=  1000;			//	Take profit points
input	int		InpStopLossPts			=	1000;			//	Stop loss points

//
//	Standard inputs
//
		//	Order size
input	string	InpTradeComment		=	__FILE__;	//	Trade comment
input	int		InpMagicNumber			=	2000001;		//	Magic number

//
//	Use these to store the point values of sl and tp converted to double
//
double			TakeProfit;
double			StopLoss;

//Identify the buffer numbers
//
const string IndicatorName  = "ichimoku";
const int    BufferTenkan   = 0;
const int    BufferKijun    = 1;
const int    BufferChikou   = 4;
const int    BufferSpanA    = 2;
const int    BufferSpanB    = 3;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   //EventSetTimer(2);
	//
	//	Convert the input point sl tp to double
	//
	double	point	=	SymbolInfoDouble(Symbol(), SYMBOL_POINT);
	TakeProfit		=	InpTakeProfitPts * point;
	StopLoss			=	InpStopLossPts * point;
  
   
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
//   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick(void){
static datetime candletime;
if(Time[0]==candletime){
return;}
else{
TradeLogic();
candletime = Time[0];}
}




void TradeLogic(){

string Sym = (string)Symbol();


// Price data
double PriceAsk = MarketInfo(Symbol(), MODE_ASK);
double PriceBid = MarketInfo(Symbol(), MODE_BID);
double OpenPrice = open(Sym,1);
double HighPrice = high(Sym,1);
double LowPrice  = low(Sym,1);
double ClosePrice = close(Sym,1);

// Lotsize
double OrderSize = InpOrderSize;


// Call Ichimoku Values
double currentTenkan = iCustom(Symbol(),Period(),IndicatorName,InputTenkansen,InputKijunsen,InputSenkouspanb,BufferTenkan,1);
double currentKijun = iCustom(Symbol(),Period(),IndicatorName,InputTenkansen,InputKijunsen,InputSenkouspanb,BufferKijun,1);
double currentChikou = iCustom(Symbol(),Period(),IndicatorName,InputTenkansen,InputKijunsen,InputSenkouspanb,BufferChikou,1);
double currentSpanA = iCustom(Symbol(),Period(),IndicatorName,InputTenkansen,InputKijunsen,InputSenkouspanb,BufferSpanA,1);
double currentSpanB = iCustom(Symbol(),Period(),IndicatorName,InputTenkansen,InputKijunsen,InputSenkouspanb,BufferSpanB,1);


// Get Rsi Values 

double RsiValue = iRSI(Symbol(),Period(),14,PRICE_CLOSE,1);
double RsiBuyDiff = MathAbs(25-RsiValue);
double RsiSellDiff = MathAbs(75-RsiValue);

//Print("span" +  InpOrderSize); 
//Print("price" + ClosePrice);  

// Risk Manager
if ( ( OrdersTotal() == 0 ) && ( AccountBalance() >= (AccountBalance() - LossLimit) ) )

/// Cloud Break Entries 
{

if ( (ClosePrice < currentSpanA) && (ClosePrice < currentSpanB) && (RsiValue <= 30.0)) 
{
Alert("Buy Order",PriceAsk);
PlaceOrderBuy(Sym,OrderSize,PriceAsk,PriceBid,StopLoss,TakeProfit);
}

else if ( (ClosePrice > currentSpanA) && (ClosePrice > currentSpanB) && (RsiValue >= 70.0) )
{
Alert("Sell Order",PriceBid);
PlaceOrderSell(Sym,OrderSize,PriceAsk,PriceBid,StopLoss,TakeProfit);
}

}



}

void CloseBuyOrders()
{
 for (int i = OrdersTotal()-1; i >= 0; i--)
   {
      if ( OrderSelect(i, SELECT_BY_POS) )
      {
         if (OrderType() == OP_BUY)
           OrderClose(OrderTicket(),OrderLots(),Bid,3,NULL);
      }
   }
}


void CloseSellOrders()
{
 for (int i = OrdersTotal()-1; i >= 0; i--)
   {
      if ( OrderSelect(i, SELECT_BY_POS) )
      {
         if (OrderType() == OP_SELL)
           OrderClose(OrderTicket(),OrderLots(),Ask,3,NULL);
      }
   }
}

//Get OHLC DATA

double open(string symbol, int index)
  {
//---
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(symbol,0,0,10,rates);
   if(copied>0){
      int size=fmin(copied,10);
      for(int i=0;i<size;i++)
        {
         double openC = rates[index].open;
         return(openC);
        }
     }
   else Print("Failed to get history data for the symbol ",Symbol());
   return(0.0);
  }
double high(string symbol, int index)
  {
//---
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(symbol,0,0,10,rates);
   if(copied>0){
      int size=fmin(copied,10);
      for(int i=0;i<size;i++)
        {
         double highC = rates[index].high;
         return(highC);
        }
     }
   else Print("Failed to get history data for the symbol ",Symbol());
   return(0.0);
  }
  
double low(string symbol, int index)
  {
//---
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(symbol,0,0,10,rates);
   if(copied>0){
      int size=fmin(copied,10);
      for(int i=0;i<size;i++)
        {
         double lowC = rates[index].low;
         return(lowC);
        }
     }
   else Print("Failed to get history data for the symbol ",Symbol());
   return(0.0);
  }
double close(string symbol, int index)
  {
//---
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(symbol,0,0,10,rates);
   if(copied>0){
      int size=fmin(copied,10);
      for(int i=0;i<size;i++)
        {
         double closeC = rates[index].close;
         return(closeC);
        }
     }
   else Print("Failed to get history data for the symbol ",Symbol());
   return(0.0);
  }
double volume(string symbol, int index)
  {
//---
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(symbol,0,0,10,rates);
   if(copied>0){
      int size=fmin(copied,10);
      for(int i=0;i<size;i++)
        {
         double volumeC = rates[index].tick_volume;
         return(volumeC);
        }
     }
   else Print("Failed to get history data for the symbol ",Symbol());
   return(0.0);
  
  }
  
double time(string symbol, int index)
  {
//---
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(symbol,0,0,10,rates);
   if(copied>0){
      int size=fmin(copied,10);
      for(int i=0;i<size;i++)
        {
         double timeC = rates[index].time;
         return(timeC);
        }
     }
   else Print("Failed to get history data for the symbol ",Symbol());
   return(0.0);
  
  }
  
  
void PlaceOrderBuy(string &Sym, double &lotsize, double &askPrice, double &bidPrice, double &sl_value, double &tp_value)
  {
   //lotsize=((double)risk.Text())/((slspin.Value()*_Point*100));
   if(OrderSend(Sym,OP_BUY,lotsize,askPrice,3,askPrice - sl_value, askPrice + tp_value)==-1)
      Print("unable to place buy order due to \"",ErrorDescription(GetLastError()),"\"");
  }
  
void PlaceOrderSell(string &Sym, double &lotsize, double &askPrice, double &bidPrice, double &sl_value, double &tp_value)
  {
   //lotsize=((double)risk.Text())/((slspin.Value()*_Point*100));
   if(OrderSend(Sym,OP_SELL,lotsize,bidPrice,3,bidPrice + sl_value , bidPrice- tp_value)==-1)
      Print("unable to place buy order due to \"",ErrorDescription(GetLastError()),"\"");
  }