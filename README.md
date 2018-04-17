# water-meter-pulse
NodeMCU v3 LUA-code for detecting and counting pulses from my water meter

This is my water meter pulse implementation. Every detected pulse triggers a counter increase and the counter is sent off by a HTTP GET call to my [NodeRED](https://nodered.org/) installation for further handling. Call being made is:

```GET http://server/endpoint?meter=<counter>&units=<litres>```

My own water meter pulses every 10 litres so what is being sent is the actual counter value and the counter difference between sends times 10.

The counter value is saved to flash with every change.
