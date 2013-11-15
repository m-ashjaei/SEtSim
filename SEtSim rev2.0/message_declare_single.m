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

% tagged messages for measurement are:
% m1:global periodic, m51: global aperiodic
% m56: local periodic, m71:local aperiodic

function [message, non_frag_msg] = message_declare

% number of messages should be set here manually
non_frag_msg = 5;


% message 1: tagged message to measure as periodic global message
message(1).id = 1;
message(1).prio = 1;
message(1).exec = 0.010;
message(1).gType = 0;
message(1).pType = 0;
message(1).period = 5;
message(1).deadline = 5;
message(1).dynPeriod = 0;
message(1).sourceMasterNumber = 2;
message(1).source = 4;
message(1).dest = 7;
message(1).destMasterNumber = 3;
message(1).SwitchInRout = [2 1];
message(1).SwitchPort = [2 4];
message(1).tickCount = 4;
message(1).readyTime = 0;
message(1).receiveTime = 0;
message(1).defNum = 0;
message(1).part = 0;
message(1).refMsgID = 1;
message(1).cluster = 0;
message(1).ClParentMaster = 0;
message(1).offset = 0;

message(2).id = 2;
message(2).prio = 1;
message(2).exec = 0.010;
message(2).gType = 0;
message(2).pType = 0;
message(2).period = 5;
message(2).deadline = 5;
message(2).dynPeriod = 0;
message(2).sourceMasterNumber = 1;
message(2).source = 1;
message(2).dest = 8;
message(2).destMasterNumber = 3;
message(2).SwitchInRout = 1;
message(2).SwitchPort = 4;
message(2).tickCount = 4;
message(2).readyTime = 0;
message(2).receiveTime = 0;
message(2).defNum = 0;
message(2).part = 0;
message(2).refMsgID = 2;
message(2).cluster = 0;
message(2).ClParentMaster = 0;
message(2).offset = 0;

message(3).id = 3;
message(3).prio = 1;
message(3).exec = 0.010;
message(3).gType = 0;
message(3).pType = 0;
message(3).period = 5;
message(3).deadline = 5;
message(3).dynPeriod = 0;
message(3).sourceMasterNumber = 2;
message(3).source = 6;
message(3).dest = 2;
message(3).destMasterNumber = 1;
message(3).SwitchInRout = 2;
message(3).SwitchPort = 2;
message(3).tickCount = 4;
message(3).readyTime = 0;
message(3).receiveTime = 0;
message(3).defNum = 0;
message(3).part = 0;
message(3).refMsgID = 3;
message(3).cluster = 0;
message(3).ClParentMaster = 0;
message(3).offset = 0;

message(4).id = 4;
message(4).prio = 1;
message(4).exec = 0.010;
message(4).gType = 0;
message(4).pType = 1;
message(4).period = 5;
message(4).deadline = 5;
message(4).dynPeriod = 5;
message(4).sourceMasterNumber = 2;
message(4).source = 5;
message(4).dest = 3;
message(4).destMasterNumber = 1;
message(4).SwitchInRout = 2;
message(4).SwitchPort = 2;
message(4).tickCount = 4;
message(4).readyTime = 0;
message(4).receiveTime = 0;
message(4).defNum = 0;
message(4).part = 0;
message(4).refMsgID = 4;
message(4).cluster = 0;
message(4).ClParentMaster = 0;
message(4).offset = 0;

message(5).id = 5;
message(5).prio = 1;
message(5).exec = 0.010;
message(5).gType = 0;
message(5).pType = 1;
message(5).period = 7;
message(5).deadline = 7;
message(5).dynPeriod = 7;
message(5).sourceMasterNumber = 1;
message(5).source = 1;
message(5).dest = 3;
message(5).destMasterNumber = 1;
message(5).SwitchInRout = 0;
message(5).SwitchPort = 0;
message(5).tickCount = 6;
message(5).readyTime = 0;
message(5).receiveTime = 0;
message(5).defNum = 0;
message(5).part = 0;
message(5).refMsgID = 5;
message(5).cluster = 0;
message(5).ClParentMaster = 0;
message(5).offset = 0;



















