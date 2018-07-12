# App_Spike_Train_Analysis
This code allows to semi-automatically classify spontaneous firing neurones according to regularity, grouping of spikes in bursts and firing frequency inter- and intra-burst


Introduction:

During electrophysiology experiments studying the nervous system some neurones with ongoing activity in absence of external stimulation are frequently recorded. We have studied such activity in the superficial dorsal horn of the spinal cord, which takes part on nociceptive information processing. 

The first part of our study consisted of classifying spontaneous firing neurones according to several parameters analysing their inter-spike intervals (ISI) and instant frequencies (1/ISI): grouping of spikes in bursts, intra-burst firing frequency and regularity.

Burst firing was considered if at least 25% of spikes from a single neurone were grouped in bursts, otherwise the neurone was classified as simple firing.

Within the burst group we distinguished three categories: fast burst (FB) neurones had a mean intra burst instant frequency > 70 Hz. Neurones with smaller intra burst frequency were defined slow burst (SB). We observed a third neuronal class which presented bursts with a fast initial component and a slower latter one. They were named as mixed burst (MB) neurones.

The parameter to measure regularity was the coefficient of variation (CV), understood as the ratio of the standard deviation to the mean. We assumed that values of CV < 0.5 were representative of regularity. In simple firing neurones ISI regularity was assessed. However, in burst firing neurones CV of ISI gives no information about regularity of burst appearance, so we evaluated instead CV of inter-burst intervals (IBI).  Some burst neurones did not only present regularity between bursts but also within them. This measurement was made calculating the CV of intra-burst inter-spike intervals. 

For a more detailed description of some of these neuronal classes see: https://www.ncbi.nlm.nih.gov/pubmed/27726011 
Roza, C. et al. Analysis of spontaneous activity of superficial dorsal horn neurons in vitro: neuropathy-induced changes. Pflügers Archiv - European Journal of Physiology 468, 2017–2030 (2016).

This program was developed in the context of this work: https://www.ncbi.nlm.nih.gov/pubmed/29950700. Please reference it in your publication if this software has been useful to you.
For any doubt or request you can address to Javier Lucas-Romero, Department of Systems Biology, Universidad de Alcala, Alcala de Henares, 28871, Madrid, Spain. javierdelucas7@hotmail.com


User guide:

This code was written in MATLAB language and has to be run in the desktop application of MATLAB or the free software GNU Octave, for which it is also compatible. 

Once initialised the application and placed the .m file in the current folder you can either type the program name in the command window (ASTA: Application for Spike Train Analysis) or right click in it and select “run”.

Then, and emerging window will appear to allow you select the .mat file to analyse. The program works with MATLAB files exported from a wavemark channel of Spike 2 (Cambridge Electronics Design).

When you open a proper file, the program will plot the events in a graph where the x axis is time in seconds and the y axis the instant frequency of each event in Hz.

Then, the program will ask you in the command window if you want to check if the neuron fires in burst mode. If you tip “N” the program will assume simple firing and classify the neurone in irregular simple (IS) or regular simple (RS) depending on the CV value, also displaying it. If you type “Y” the program will ask you to set a frequency threshold, which will be displayed on the graph, to delimitate the boundary between the first spikes of each burst and the rest of them. 

If the neurone does not fulfil the criterion to be considered burst firing, the output will be the same as if you tip “N” in the earlier step. However, if that is not the case, the neurone will be classified as burst firing and the program will display the corresponding firing pattern, inter-burst CV, intra-burst CV, mean spikes per burst, mean intra-burst instant frequency, mean inter-burst instant frequency and mean burst duration.

The possible firing patterns in this case are the following: irregular fast burst (IFB), irregular slow burst (ISB), irregular mixed burst (IMB), regular fast burst (RFB), regular slow burst (RSB), regular mixed burst (RMB) and double regular slow burst (RRSB).

Some .mat files with the recording of different neuronal classes observed in our laboratory will be provided for testing.


Technical details:

In our experimental conditions (in vitro experiment at room temperature), events at frequencies above 400 Hz are considered artifacts, so the algorithm automatically filter them.
For the calculation of IBI and its CV the intervals considered are those between the first spikes of each burst.
The calculation of intra-burst regularity is made as if intra-burst spikes (every spike except the first spikes of bursts) were displayed as a continuous, assimilating as a regular simple neuron in case of intra-burst regularity.
Analysis of spikes per burst and burst duration was made by comparing the vector containing the timestamp of every event and the vector containing intra-burst events.
For the classification of mixed burst neurones, they have to fulfil the criterion of having one or more spikes per burst at least at 80 Hz.
