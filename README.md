SEtSim ver 2.0
======

SEtSim (Switched Ethernet Simulator) is a modular simulation tool for switched Ethernet networks. Currently, it supports different architectures of the FTT-SE protocol, i.e., single-/multi-master and cluster-based architectures. 
Please download the full folder of SEtSim rev2.0 and read the user manual inside that to get start. In case of any question please contact me at: mohammad.ashjaei@mdh.se.

Quick Start
------
In order to run the provided example in the SEtSim rev.2.0 folder as a quick start, please open Matlab and open the SEtSim folder through that. Then, open the example.mdl which is a Simulink model. It contains 3 sub-networks each of which has 3 slave nodes. The network setting is assigned in the data\_table.m file. Also, 5 number of messages have been defined for this example in the message\_declare.m file. The user can run the example model by the "Start simulation" button. 

After stopping the simulation in an arbitrary amount of time, the user can see the report that contains the response time of the messages. In order to check the report, the user needs to write "report" in the Command window of the Matlab, when the Current folder in the Matlab is still in the SEtSim rev.2.0 folder. The report shows the information about the network as well. 
