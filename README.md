SEtSim
======

SEtSim (Switched Ethernet Simulator) is a modular simulation tool for switched Ethernet networks. Currently, two versions of the tool are available to test. SEtSim version 2 supports different architecture of the FTT-SE protocol, i.e., single-/multi-master and cluster-based architectures. SEtSim version 3 supports the Ethernet AVB protocol for single switch case as well. Please download the full folder of SEtSim rev2.0 or rev3.0 and read the user manual inside that to get start. In case of any question please contact me at: mohammad.ashjaei@mdh.se.

Quick Start for SEtSim ver2.0
------
In order to run the provided example in the SEtSim rev.2.0 folder as a quick start, please open Matlab and open the SEtSim folder through that. Then, open the example.mdl which is a Simulink model. It contains 3 sub-networks each of which has 3 slave nodes. The network setting is assigned in the data\_table.m file. Also, 5 number of messages have been defined for this example in the message\_declare.m file. The user can run the example model by the "Start simulation" button. 

After stopping the simulation in an arbitrary amount of time, the user can see the report that contains the response time of the messages. In order to check the report, the user needs to write "report" in the Command window of the Matlab, when the Current folder in the Matlab is still in the SEtSim rev.2.0 folder. The report shows the information about the network as well. 

Quick Start for SEtSim ver3.0
------
As a quick start, a model example named "exampleAVB" is available in the SEtSim rev3.0 folder. Open Matlab, then open the SEtSim ver3.0 folder, where it contains the example model. The example contains one AVB switch and three nodes. The network configuration is set in the data\_table.m file. Also, for this example, five messages have been generated, which their parameters are available in the message\_declare.m file. Please run the simulator by the "Start simulation" button.

The user can see the response time of the defined messages by typing "report" in the command window of the Matlab. 
