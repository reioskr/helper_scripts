clearvars, clc, close all
1;
% PREPARED FOR OCTAVE VERSION 5.1.0 BY OREI
% Create input for seastates
pkg load statistics


%% ----------- USER INPUT ---------
Inp.import_filename='Mat-files\SVA.mat'; % SCD file

% TFA PARAMETERS TO BE INCLUDED IN EXPORT:
% Inp.Ti - sim time, calc. acc. to: Ref. REN2021N00986-RAM-ME-00001-1.0.pdf Sec. 3.4
Inp.Tst=log(100)/(pi()*0.02)*2.5298; % calc. acc. to: Ref. REN2021N00986-RAM-ME-00001-1.0.pdf Sec. 3.3 , 85 from VBA example.
Inp.SEED=143326;         % seed start value
Inp.N_rlz=15;            % Number of seastate realizations for each scatter diagram window


Inp.filename='out.txt'; % output filename
Inp.CorrectionParameter.Hm0= -50 *1e-3; % correction value for Hm0 [m], // -50mm from bin center
Inp.CorrectionParameter.Tp =  0;        % correction value for Tp [m]


Inp.verifyOutput = 1;   % check the output file
Inp.plots = 0;          % plots


%% ----------- RUN  ---------
[Data,Inp]=f_Main(Inp);



%% temp code:
plot_QC
