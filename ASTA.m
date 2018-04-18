%Vector times contains the timestamp of each event imported from Spike2
[filename,folderpath1]=uigetfile('*.mat','Select a Matlab file exported from Spike 2');
Y=struct2cell(load([folderpath1 filename]));
times=transpose(Y{1,1}.times);
times=times'; 
L=length(times); 
ISI=[]; 
for b=2:L
  C=[times(b)-times(b-1)]; %Calculate interspike intervals (ISI)
  ISI=[ISI,C]; 
end
Inst_freq=[0]; %The first instant frequency element is zero
Inst_freq=[Inst_freq,1./ISI]; 
VF=Inst_freq<400; %Frequencies above 400 Hz are not considered so corresponding events are filtered
times=times(VF);
L=length(times); %Interspike intervals and instant frequencies have to be recalculated
ISI=[]; 
for b=2:L
  C=[times(b)-times(b-1)]; 
  ISI=[ISI,C]; 
end
Inst_freq=[0]; 
Inst_freq=[Inst_freq,1./ISI]; 
CV_ISI=(std(ISI)/mean(ISI)); %Calculates coefficient of variation (CV) considering every ISI
clf
hold on
plot(times,Inst_freq,"*k")
COND=input('Check if the neuron fires in burst mode? Y/N: ', 's');
%In case of burst firing, allows to set a threshold to separate the first spikes from the rest of the events in the burst
COND2=((COND=='y')|(COND=='Y'));
if COND2==1
  Freq_filter=input('Frequency filter: ');
  line=(0:times(end));
  FV=[Freq_filter];
  for j=1:times(end) 
    FV=[FV,Freq_filter];
  end
  plot(line,FV,'r')%Represents in the figure the frequency threshold
  hold off
  VC_1stSpikes=Inst_freq<Freq_filter; %The instant frequencies under the threshold (and corresponding times) are extracted
  First_spikes=Inst_freq(VC_1stSpikes); 
  times_1stSpikes=times(VC_1stSpikes); 
  ISI2=[0,ISI]; %Adding an element at the beginnig of the ISI's vector allows to extract intraburst intervals using the logical vector opposite to VC_1stSpikes
  VC_Burst=(VC_1stSpikes==0); 
  ISI_intraburst=ISI2(VC_Burst); 
  L2=length(times_1stSpikes);
  ISI_First_spikes=[];
    for b2=2:L2
    C2=[times_1stSpikes(b2)-times_1stSpikes(b2-1)]; %Calculates interspike intervals and instant frequencies considering only the first spikes of bursts 
    ISI_First_spikes=[ISI_First_spikes,C2]; 
    end
  First_spikes=[0]; 
  First_spikes=[First_spikes,1./ISI_First_spikes]; 
  Intraburst_freq=(1./ISI_intraburst);%Calculates instant frequencies intraburst and mean intraburst frequency
  MINTRA=mean(Intraburst_freq);
  SDINTRA=std(Intraburst_freq);  
  First_spikes_freq=First_spikes(2:end); %New vector without the initial zero to calculate mean interburst frequency
  MINTER=mean(First_spikes_freq);
  SDINTER=std(First_spikes_freq); 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%Analysis of spikes per burst and burst length%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Times_Burst=times(VC_Burst);%Timestamps of every spike within a burst (excepting the first spike of each burst)
  LTB=length(Times_Burst);
  series1=1;
  series2=1;
  bursts=[];
    while (Times_Burst(series1)~=Times_Burst(end)) 
      for b4=series1:LTB
        count=0; %Spike count is set to zero
        for b5=series2:L
          if (Times_Burst(b4)~=times(b5)),continue,end %Looks for the first coincident event between the intraburst vector and the vector containing every event
          First_spike=times(b5-1);
          count=count+2;
          if (Times_Burst(b4)==Times_Burst(end)) %Finishes the loop if the last intraburst event is reached 
             burst_length=times(b5)-First_spike;
             bursts=[bursts;count,burst_length];
          else
             b4=b4+1;
             b5=b5+1;
             while (Times_Burst(b4)==times(b5))
               count=count+1;
               b5=b5+1;
               if Times_Burst(b4)==Times_Burst(end),break,end %Finishes the loop if the last intraburst event is reached
               b4=b4+1;
             end
             burst_length=times(b5-1)-First_spike;
             bursts=[bursts;count,burst_length]; %Matrix with the spikes per burst and their durations in seconds
             series1=b4;
             series2=b5;
          end
        if series1==b4,break,end
        end  
      if series1==b4,break,end
      end
    end
    burst_spikes=[bursts(:,1)];
    burst_lengths=[bursts(:,2)];
    %test for mixed burst firing
      VC_high_freq_spikes=Intraburst_freq>80;
      High_freq_spikes=Intraburst_freq(VC_high_freq_spikes);
    
  percentage_spikes_burst=(sum(burst_spikes)*100)/L;
  %Firing pattern classification acording to the defined criteria
  if percentage_spikes_burst>25
    CV_ISI_INTRABURST=(std(ISI_intraburst)/mean(ISI_intraburst)); %Calculates intraburst regularity
    CV_ISI_INTERBURST=(std(ISI_First_spikes)/mean(ISI_First_spikes)); %Calculates interburst regularity
    mean_spikes=mean(burst_spikes); %Calculates mean spikes per burst
    mean_burst_lenght=mean(burst_lengths); %Calculates mean burst duration
    if CV_ISI_INTERBURST<0.5
      if MINTRA>70
        FP='RFB';
      elseif length(High_freq_spikes)>=(1*length(burst_spikes)) %The criterion to consider mixed burst is the presence of 1 or more spikes per burst at least at 80 Hz
        FP='RMB';
      elseif CV_ISI_INTRABURST<0.5
        FP='RRSB';
      else
        FP='RSB';
      end
    elseif MINTRA>70
      FP='IFB';
    elseif length(High_freq_spikes)>=(1*length(burst_spikes))
      FP='IMB';
    else
      FP='ISB';
    end
    fprintf('\nThe firing pattern is: %s\n  CV interburst= %.2f\n  CV intraburst= %.2f\n',FP,CV_ISI_INTERBURST,CV_ISI_INTRABURST)
    fprintf('   mean spikes/burst= %.2f\n   mean intraburst frequency= %.2f Hz\n   mean interburst frequency= %.2f Hz\n   mean burst duration= %.2f s\n',mean_spikes,MINTRA,MINTER,mean_burst_lenght)
  else
    if CV_ISI<0.5
      FP='RS';
      fprintf('\nThe firing pattern is: %s\n  CV= %.2f\n',FP,CV_ISI)  
    else
      FP='IS';
      fprintf('\nThe firing pattern is: %s\n  CV= %.2f\n',FP,CV_ISI) 
    end
  end  
else
  if CV_ISI<0.5
    FP='RS';
    fprintf('\nThe firing pattern is: %s\n  CV= %.2f\n',FP,CV_ISI)  
  else
    FP='IS';
    fprintf('\nThe firing pattern is: %s\n  CV= %.2f\n',FP,CV_ISI) 
  end
end