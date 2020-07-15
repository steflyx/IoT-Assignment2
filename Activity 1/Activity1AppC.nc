#include "Activity1.h"

configuration Activity1AppC {}
implementation {
	components MainC, Activity1C as App, LedsC;
	components new AMSenderC(AM_RADIO_COUNT_MSG);
	components new AMReceiverC(AM_RADIO_COUNT_MSG);
	components new TimerMilliC() as Timer;
	components ActiveMessageC;
	
	App.Boot -> MainC.Boot;
	
	App.Receive -> AMReceiverC;
	App.AMSend -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.Leds -> LedsC;
	App.MilliTimer -> Timer;
	App.Packet -> AMSenderC;
}