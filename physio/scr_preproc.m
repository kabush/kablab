function scr = scr_preproc(proj,TRs,data)
% scr_preproc extracts the scr component of the biopac recording
%             file, filters the raw signal and downsamples
%
%  [scr] = scr_preproce(proj,data)
%
%  ARGUMENTS
%    proj = project structure
%    TRs = the length of the file that is aligned with the fMRI
%    data = raw biopac data (rows are samples, columns are channels)
%
%  OUTPUTS
%    scr = filtered downsampled scr data
%
%  REFERENCES
%    Bach et al, 2009
%    Bach et al, 2013
%    Staib et al., 2015

%select appropriate biopac channel
data = data(:,proj.param.physio.chan_scr);

%find end of run in scr channel time units
end_of_run=TRs.*proj.param.mri.TR.*proj.param.physio.hz_scr; %%num TRs, s/TR, samples/s = total samples
data = data(1:end_of_run);

% median filter 10ms either side of data point (Bach 2015).
ten_ms = round(proj.param.physio.hz_scr*proj.param.physio.filt_scr_med_samp);
desamp_seq = (ten_ms+1):(numel(data)-ten_ms);
desamp_vec=zeros(numel(data),1);
for i=1:numel(desamp_seq)
    id = desamp_seq(i);
    desamp_vec(id)=median(data((id-ten_ms):(id+ten_ms)));
end

% copy over unfiltered first 10ms and last 10ms
desamp_vec(1:ten_ms)=data(1:ten_ms);
desamp_vec((end-ten_ms):end)=data((end-ten_ms):end);
data = desamp_vec;

%subtract mean of first few timepoints from full signal in order to
%prevent filtering artifact
start_mean=mean(data(1:ten_ms));
data=data-start_mean;

%butterworth filter:  butter(order,[high low]), low must be
%less than half of sampling rate (1000Hz or .001)
half_samp=proj.param.physio.hz_scr/2;
high = proj.param.physio.filt_scr_high;
low = proj.param.physio.filt_scr_low;

%define Butterworth filter
[B A]=butter(1,[high/half_samp low/half_samp]); %"for GLMs, high pass
                                                %should be .05 rather
                                                %than .0159 (Staib,
                                                %Bach 2015)" [.00005
                                                %.005], but .0159 looks
                                                %better to me

%apply filter
if(proj.param.physio.filt_scr_type==1)
    %unidirectional
    data=filter(B,A,data);
else
    %bidirectional
    data=filtfilt(B,A,data);
end

%now downsample
data_desamp=data(1:(proj.param.mri.TR*proj.param.physio.hz_scr):end);

%convert values to a standard score
scr=zscore(data_desamp);
