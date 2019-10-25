# SMUWL

**S**ource **M**easure **U**nit interface for **W**olfram **L**anguage

The script `SMUWL.wl` contains the basic functions needed to comunicate with a Keithley 2600 connected by TCP protocol. 

The other scripts are working examples of how to read drain-source currents of 8 FETs through an 8 channel multiplexer controlled by a Raspberry Pi model 3B via its GPIOs. The common gate voltage is provided by the smuB, while the currents are measured through smuA.
