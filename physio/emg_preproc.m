function emg = emg_preproc(proj,TRs,data)
%  emg_preproc extracts the emg component of the biopac recording
%             file, filters the raw signal
%  [emg] = emg_preproce(proj,TRs,data)
%
%  ARGUMENTS
%    proj = project structure
%    TRs = the length of the file that is aligned with the fMRI
%    data = raw biopac data (rows are samples, columns are channels)
%
%  OUTPUTS
%    emg = filtered and cropped EMG
%
%  REFERENCES
%    TBD

%find end of run in emg channel time units
end_of_run=TRs.*proj.param.mri.TR.*proj.param.physio.hz_emg; %%num TRs, s/TR, samples/s = total samples
data = data(1:end_of_run);

half_samp = proj.param.physio.hz_emg/2;
high = proj.param.physio.emg.filt_high;
low = proj.param.physio.emg.filt_low;

[B A] = butter(1,[high/half_samp low/half_samp]);

if(proj.param.physio.emg.filt_type==1)
    %unidirection
    fdata=filter(B,A,data);
else
    %bidirectional
    fdata=filtfilt(B,A,data);
end

emg = zscore(fdata);

