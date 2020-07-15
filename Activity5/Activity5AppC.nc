#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "Activity5.h"

configuration Activity5AppC {}
implementation {
	components MainC, Activity5C as App;
	components new AMSenderC(AM_RADIO_COUNT_MSG);
	components new AMReceiverC(AM_RADIO_COUNT_MSG);
	components new TimerMilliC() as Timer;
	components ActiveMessageC;
	components RandomC;
	components PrintfC;
  	components SerialStartC;
	
	App.Boot -> MainC.Boot;
	
	App.Receive -> AMReceiverC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.MilliTimer -> Timer;
	App.Packet -> AMSenderC;
	App.Random -> RandomC;
}