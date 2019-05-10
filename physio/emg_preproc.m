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

emg = data; 

%%% *** TICKET ***
%%% This is for course-grained piloting. Need to tune 
%%% filtering parameters.

% 
% % ****************************************
% % set-up time/freq conversions
% % ****************************************
% fsmp = proj.param.physio.hz_emg;  %sampling frequency
% T = 1/fsmp;
% N = numel(data);
% f = fsmp*(0:(N/2))/N;
% 
% %compute freq domain
% fy = fft(data);
% 
% % debug
% % compute power spectrums
% p2 = abs(fy/N); % 2-sided power spectrum
% p1 = p2(1:N/2+1);
% p1(2:end-1) = 2*p1(2:end-1);
% 
% % ****************************************
% % plot power spectrum
% % ****************************************
% figure(1)
% plot(f,p1);
% title('Single-Sided Amplitude Spectrum of X(t)');
% xlabel('f (Hz)');
% ylabel('|p1(f)|');
% 
% % ****************************************
% % filter
% % ****************************************
% 
% %set-up the filter
% flo = numel(find(f<proj.param.physio.emg.filt_low));
% fhi = numel(find(f<proj.param.physio.emg.filt_high));
% fltr_vec = zeros(size(fy));
% fltr_vec(flo:fhi)=1;
% 
% %filter the freq space
% fltr_fy = fy.*fltr_vec;
% 
% %invert back to time domain
% iy = ifft(fy);
% fltr_iy = ifft(fltr_fy);
% 
% % take real component for plotting      
% emg = real(fltr_iy);
% 
% debug
% figure(2)
% plot(data,'b-');
% hold on;
% plot(emg,'r-');
