function [Data,Inp]=f_Main(Inp);

%% Variables info:
% Count: No of waves
% MPspr: Spreading coef. by bin in 'counts'
% Table headers, Wave direction are in meta.
load(Inp.import_filename); % SCD data

% Bin center values:
Inp.Tp =meta.edges.Tp (2:end) -diff(meta.edges.Tp)  ./2 +Inp.CorrectionParameter.Tp;    % arithmetic center + correction value (row vector)
Inp.Hm0=meta.edges.Hm0(2:end)'-diff(meta.edges.Hm0)'./2 +Inp.CorrectionParameter.Hm0;   % arithmetic center + correction value (column vector)
Inp.WDr=meta.edges.MWD(2:end) -diff(meta.edges.MWD) ./2;                                % arithmetic center (row vector)


% Create N_rlz realizations of wave for each non-zero value in SCD
N_rlz=counts;
N_rlz(N_rlz ~= 0) = Inp.N_rlz;
Inp.ExportChecksum = sum(counts(:)~= 0)*Inp.N_rlz; % SUM nonzero values from SCD

  % Iterate over directions:
  for iterNo=1:size(counts,4)
     % Array of; Seastates = [Hm0(:), Tp(:), SPR(:), Ti(:)]:
     [Seastates,noSeastates] = f_RepSeastates(Inp,N_rlz(:,:,:,iterNo),MPspr(:,:,:,iterNo),iterNo);
     Seastates(:,4) = ceil(180*Seastates(:,2)./1.408+Inp.Tst); % Ti, Ref. REN2021N00986-RAM-ME-00001-1.0.pdf Sec. 3.4
     Data(iterNo).WDr         = Inp.WDr(iterNo); % Mean Wave direction [deg]
     Data(iterNo).Seastates   = Seastates;    % [Hm0(:), Tp(:), SPR(:), Ti(:)]
     Data(iterNo).noSeastates = noSeastates;  
  endfor
 
   % export as txt file:
   def=f_export(Data,Inp);
   %open(Inp.filename);

   % verify flag is on
   if (Inp.verifyOutput)
     f_verify_outputfile(Inp,def);
   end
   
   if (Inp.plots)
     f_plots(Inp,def);
   end
endfunction % f_Main


