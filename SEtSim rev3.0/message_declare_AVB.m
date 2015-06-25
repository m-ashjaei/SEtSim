%---------------------------------------------------------------------
% Copyright 2013 Mohammad Ashjaei <mohammad.ashjaei@mdh.se>
% This code is written in order to simulate switched Ethernet protocols.
%---------------------------------------------------------------------

% Define the message struct manually (example)
% Note: in the SwitchInRout and SwitchPort members the destination switch
% is excluded and the port shows the output port connected to the next
% switch in the rout.
% tickCount always should be 1 tick less than the period.
% cluster is the one that the source node is in that.
% in case of aperiodic message the dynPeriodic should be set the same as
% period, otherwise it should be set to 0.
% ClParentMaster is just set in case the traffic is global aperiodic,
% otherwise it should be set to 0.


function [message, non_frag_msg] = message_declare

% number of messages should be set here manually
non_frag_msg = 5;

message(1).id = 1;
message(1).prio = 1;
message(1).exec = 0.010;
message(1).execDyn = 0.010;
message(1).period = 10;
message(1).deadline = 10;
message(1).tickCount = 0;
message(1).sourceMasterNumber = 1;
message(1).source = 1;
message(1).dest = 2;
message(1).destMasterNumber = 1;
message(1).SwitchInRout = 0;
message(1).SwitchPort = 0;
message(1).defNum = 0;
message(1).class = 1;
message(1).delay = 0;


message(2).id = 2;
message(2).prio = 1;
message(2).exec = 0.010;
message(2).execDyn = 0.010;
message(2).period = 14;
message(2).deadline = 14;
message(2).tickCount = 0;
message(2).sourceMasterNumber = 1;
message(2).source = 1;
message(2).dest = 3;
message(2).destMasterNumber = 2;
message(2).SwitchInRout = 1;
message(2).SwitchPort = 3;
message(2).defNum = 0;
message(2).class = 2;
message(2).delay = 0;


message(3).id = 3;
message(3).prio = 1;
message(3).exec = 0.010;
message(3).execDyn = 0.010;
message(3).period = 10;
message(3).deadline = 10;
message(3).tickCount = 0;
message(3).sourceMasterNumber = 1;
message(3).source = 2;
message(3).dest = 3;
message(3).destMasterNumber = 1;
message(3).SwitchInRout = 0;
message(3).SwitchPort = 0;
message(3).defNum = 0;
message(3).class = 2;
message(3).delay = 0;

message(4).id = 4;
message(4).prio = 1;
message(4).exec = 0.010;
message(4).execDyn = 0.010;
message(4).period = 14;
message(4).deadline = 14;
message(4).tickCount = 0;
message(4).sourceMasterNumber = 2;
message(4).source = 3;
message(4).dest = 1;
message(4).destMasterNumber = 1;
message(4).SwitchInRout = 2;
message(4).SwitchPort = 1;
message(4).defNum = 0;
message(4).class = 1;
message(4).delay = 0;

message(5).id = 5;
message(5).prio = 1;
message(5).exec = 0.010;
message(5).execDyn = 0.010;
message(5).period = 30;
message(5).deadline = 30;
message(5).tickCount = 0;
message(5).sourceMasterNumber = 1;
message(5).source = 2;
message(5).dest = 1;
message(5).destMasterNumber = 1;
message(5).SwitchInRout = 0;
message(5).SwitchPort = 0;
message(5).defNum = 0;
message(5).class = 3;
message(5).delay = 0;



















