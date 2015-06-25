%---------------------------------------------------------------------
% Copyright 2013 Mohammad Ashjaei <mohammad.ashjaei@mdh.se>
% This code is written in order to simulate switched Ethernet protocols.
%---------------------------------------------------------------------


% This m file contains the global variables related to network and
% messages. the varibales may be changed if model is changed.

% should be changed if the property of simulation changed (sim config.)
% recommended value is 0.005.
global sampleTime;
sampleTime = 0.005; 
min_size = sampleTime * 2;


% The FTT-SE architecture setting, 
% 1 = cluster-based, 2 = multi-master, 3 = single-master
global architect
architect = 1;

% the flag to set the AVB architecture
% 1 = enable, 0 = disable
global avb_set;
avb_set = 1;

% disable the scopes
% 1 = disable, 0 = enable
global scope_disable
scope_disable = 0;

%number of slave nodes, can be changed!!!
global slave_number;
slave_number = 9;

%number of swicth, can be changed!!!
global switch_number;
switch_number = 3;

%cluster number, used in global aperiodic messages
global cluster;
cluster = 1;

%number of master which is the same as switch number
global master_number;
master_number = switch_number;

% number of Ethernet nodes
global node_number;
node_number = 3;

% number of AVB switch 
global avb_number;
avb_number = 2;

% EC suration time, micro second
EC = 6000;

% the TM and turn arount time duration, according to EC win
% normally it is 100us.
global tm_win;
tm_win = 200;

% the synchronous window, according to EC win, microsecond
global synch_win;
synch_win = 3500;

% local/internal synchronous window, according to EC win, microsecond
global loc_per_win;
loc_per_win = 1500;

% global/external synchronous window, according to EC win, microsecond
global glob_per_win;
glob_per_win = 2000;

% local/internal asynchronous window, according to EC win, microsecond
global loc_aper_win;
loc_aper_win = 1000;

% cluster sub-window, according to EC win, microsecond
global cluster_win;
cluster_win = 1500;

global message;
global msg;
global message_nbr;
global non_frag_msg;

% in case of random generation of message set
%[non_frag_msg, message] = msg_gen(EC);

% declare the traffic manually in the message_declare file
[message, non_frag_msg] = message_declare;

% message defragmentation, in case of payload larger than 1500bytes
[message_nbr, msg] = msg_defragment(message, non_frag_msg);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constant Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% scaling the windows duration to Matlab scale
tm_win = tm_win / 10000;
synch_win = synch_win / 10000;
loc_per_win = loc_per_win / 10000;
glob_per_win = glob_per_win / 10000;
loc_aper_win = loc_aper_win / 10000;
cluster_win = cluster_win / 10000;
EC = EC / 10000;


% Define the struct of switch
global sw;
for s = 1:switch_number
    sw(s).port_nbr = 16;
    for j = 1:sw(s).port_nbr
        sw(s).inBuffer{j} = 0;
        sw(s).outBuffer{j} = 0;
    end
end


% Define the struct of master node
global master;
for m = 1:master_number
    master(m).nextHit = 0;             %show the next EC time
    master(m).simTime = 0;             %current simulation time
    master(m).start_of_ec = 0;         %flag to show start time of EC
    master(m).EC = EC;                 %EC duration
    master(m).msg_nbr = message_nbr;   %message number

    master(m).tm_size = min_size;          %TM size which is 10ms
    master(m).tm_signal = 0;           %data of TM use in slave blocks
    master(m).tm_scope_done = 1;       %flag to show if tm is scoped, 1 means done
    master(m).tm_id = 0.5;             %TM id
    master(m).tm_data = 0;             %TM encoded data (array of messages)
    
    master(m).asynch_tm_data = 0;      %Global asynchronous TM data (array of messages)
    master(m).asynch_tm_signal = 0;    %Global asynchronous TM data use in slave blocks
    master(m).asynch_tm_id = 0.25;     %asynchTM id
    
    master(m).ap_size = min_size;          %aperiodic signal size which is 10ms
    master(m).ap_scope_done = 1;       %flag to show if aperiodic signal is scoped, 1 means done
    master(m).ap_id = 0.5;             %aperiodic signal id

    master(m).scope_out = 0;           %buffer to keep the scope output of master
    master(m).scope_in = 0;            %buffer to keep the scope input of master
    master(m).msout_duration = 0;      %master output scope duration time
    master(m).msin_duration = 0;       %master input scope duration time
    master(m).state1 = 0;              %flag to show state1 of master function done
    master(m).state2 = 0;              %flag to show state2 of master function done
    master(m).scope_buffer = 0;        %buffer for aperiodic scope
    master(m).min_scope_id = 0;        %master input message to be scoped
    master(m).mout_scope_id = 0;       %master output message to be scoped
    
    master(m).local_sync_readyQ = 0;   %ready queue for local periodic messages 
    master(m).local_async_readyQ = 0;  %ready queue for local aperiodic messages
    master(m).global_sync_readyQ = 0;  %ready queue for global periodic messages
    master(m).global_async_readyQ = 0; %ready queue for global aperiodic messages
    
    master(m).outputMaster = 0;        %buffer for master output
    master(m).masterScopeOut = 0;      %buffer for master output scope
    
   
    % reset the bandwidths
    for swit = 1:switch_number
        for por = 1:sw(m).port_nbr
            master(m).synch_local_up_filled(swit, por) = 0;
            master(m).synch_local_down_filled(swit, por) = 0;

            master(m).asynch_local_up_filled(swit, por) = 0;
            master(m).asynch_local_down_filled(swit, por) = 0;
        
            master(m).synch_global_up_filled(swit, por) = 0;
            master(m).synch_global_down_filled(swit, por) = 0;
            
            for clust = 1:cluster
                master(m).asynch_global_up_filled(swit, por, clust) = 0;
                master(m).asynch_global_down_filled(swit, por, clust) = 0;
            end
        end
    end
       
end

% Define the struct of slave node
global slave;
for i = 1:slave_number
    slave(i).ap_req = 0;                %local aperiodic request data
    slave(i).global_ap_req = 0;         %global aperiodic request data
    slave(i).ap_size = min_size;            %aperiodic signal size which is 10ms
    slave(i).ap_id = 0;                 %local aperiodic signal id
    slave(i).global_ap_id = 0;          %global aperiodic signal id, fill during ready message arrive by 0.75
    
    slave(i).slout_scope_done = 1;      %flag to show slave output scope done, 1 means done
    slave(i).slin_scope_done = 1;       %flag to show slave input scope done, 1 means done
    slave(i).output = 0;                %slave output buffer
    slave(i).out_scope_buffer = 0;      %slave scope output buffer
    slave(i).in_scope_buffer = 0;       %slave scope input buffer
    slave(i).slout_scope_msg = 0;       %the message id that should scope in slave output
    slave(i).slin_scope_msg = 0;        %the message id that should scope in slave input
    slave(i).msg_trans_time = 0;        %flag to show the message transmission time starts
    slave(i).msg_rec_time = 0;          %the time that message receive in slave
    
    slave(i).synchAccumulationTime = 0; %accumulation of time caused by messages (need for scope)
    slave(i).GsynchAccumulationTime = 0;
    slave(i).AsynchAccumulationTime = 0;
    slave(i).GAsynchAccumulationTime = 0;
        
    slave(i).scope_in = 0;              %the message id that should scope in slave input
    slave(i).scope_out = 0;             %the message id that should scope in slave output
    slave(i).slin_duration = 0;         %the duration of signal should show in slave input scope
    slave(i).slout_duration = 0;        %the duration of signal should show in slave output scope
    
    slave(i).tm_rec = 0;                %TM receive
    slave(i).asynch_tm_rec = 0;         %asynchTM receive from parent master
    slave(i).tm_size = min_size;            %TM size is 10ms
    slave(i).tm_id = 0.5;               %TM id
    slave(i).asynch_tm_id = 0.25;       %asynchTM id
    
    % flags for states of slave function
    slave(i).state1 = 0;
    slave(i).state2 = 0;
    slave(i).state3 = 0;
    slave(i).state4 = 0;
    slave(i).flagInput = 0;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETTINGS FOR AVB %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the fractions and rates
classAfrac = 0.4;   % reserved bandwidth for class A
classBfrac = 0.4;   % reserved bandwidth for class B
global Rate;
Rate = 100000000;   % the network bandwidth in bps
global maxFrameSize;
maxFrameSize = 1500 * 8;    % maximum frame size in bits

% define the node struct
global node;
for n = 1:node_number
    node(n).msg_nbr = message_nbr;
    node(n).output = 0;
    node(n).outBufferClassA = 0;
    node(n).outBufferClassB = 0;
    node(n).outBufferClassBE = 0;
    node(n).creditA = 0;
    node(n).creditB = 0;
    node(n).idleSlopeA = classAfrac * Rate;
    node(n).idleSlopeB = classBfrac * Rate;
    node(n).sendSlopeA = Rate - node(n).idleSlopeA;
    node(n).sendSlopeB = Rate - node(n).idleSlopeB;
    node(n).freePort = 0;
    node(n).currentMsg = 0;
end

% Define the struct of AVB switch
global avbSW;
for s = 1:avb_number
    avbSW(s).port_nbr = 6;
    for j = 1:avbSW(s).port_nbr
        avbSW(s).inBuffer{j} = 0;
        avbSW(s).outBufferClassA{j} = 0;
        avbSW(s).outBufferClassB{j} = 0;
        avbSW(s).outBufferClassBE{j} = 0;
        avbSW(s).outBuffer{j} = 0;
        avbSW(s).busyTime{j} = 0;
        avbSW(s).timeTag{j} = 0;
        
        avbSW(s).freePort(j) = 0;
        avbSW(s).currentMsg(j) = 0;
        
        avbSW(s).creditA{j} = 0;
        avbSW(s).idleSlopeA{j} = classAfrac * Rate;
        avbSW(s).sendSlopeA{j} = Rate - avbSW(s).idleSlopeA{j};
        avbSW(s).hiCreditA{j} = avbSW(s).idleSlopeA{j} * maxFrameSize / Rate;
        avbSW(s).loCreditA{j} = avbSW(s).sendSlopeA{j} * maxFrameSize / Rate;
        
        avbSW(s).creditB{j} = 0;
        avbSW(s).idleSlopeB{j} = classBfrac * Rate;
        avbSW(s).sendSlopeB{j} = Rate - avbSW(s).idleSlopeB{j};
        avbSW(s).hiCreditB{j} = avbSW(s).idleSlopeB{j} * maxFrameSize / Rate;
        avbSW(s).loCreditB{j} = avbSW(s).sendSlopeB{j} * maxFrameSize / Rate;
    end
end

% Define a buffer for each message to save ready time and receive time
% this is needed to measure the response time of the message
global ready_time_buffer;
global receive_time_buffer;
for buf = 1:message_nbr
    ready_time_buffer{buf} = 0;
    receive_time_buffer{buf} = 0;
end

% define switch port number which the node are connected
node(1).swPortNumber = 1;
node(2).swPortNumber = 2;
node(3).swPortNumber = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Change Based on The Topology %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%define the cluster number for each master node
master(1).cluster = 1;
master(2).cluster = 1;
master(3).cluster = 1;

%slave parent of cluster number (parent master for global aperiodic messages)
for x = 1:9
    slave(x).parentNumber = 1;
end

% define segment number (master number) which slaves are dedicated
for x = 1:3
    slave(x).segmentNumber = 1;
end
for x = 4:6
    slave(x).segmentNumber = 2;
end
for x = 7:9
    slave(x).segmentNumber = 3;
end

% define switch port number which the slaves are connected
slave(1).swPortNumber = 7;
slave(2).swPortNumber = 8;
slave(3).swPortNumber = 9;
slave(4).swPortNumber = 7;
slave(5).swPortNumber = 8;
slave(6).swPortNumber = 9;
slave(7).swPortNumber = 7;
slave(8).swPortNumber = 8;
slave(9).swPortNumber = 9;



