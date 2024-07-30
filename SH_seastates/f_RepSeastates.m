%% function [Seastates,noSeastates]=f_RepSeastates(Inp,counts,WavSPR,iterNo)
function [Seastates,noSeastates]=f_RepSeastates(Inp,counts,WavSPR,iterNo)

% Treat one direction at a time, expects 2dim array for following:
% counts, WavSPR

% Replicate seastates by scatter diagram counts:
Seastates=[]; % consists of all possible seastates by SCD: [WavH(:), WavP(:), WavSPR(:)]
Hm0=Inp.Hm0;
Tp =Inp.Tp;

for j=1:length(Tp)
  repWavH=repelem(Hm0,counts(:,j));
  repWavH(:,2)=Tp(j);
  repWavH(:,3)=repelem(WavSPR(:,j),counts(:,j));
  % Append:
  Seastates=vertcat(Seastates,repWavH);
end

noSeastates=sum(counts(:)); % number of total seastates
printf("Direction %g[deg], Seastates: %d  \n", Inp.WDr(iterNo),sum(counts(:))); 
  if size(Seastates,1)~=noSeastates; 
    error("\nMismatch in No of seastates in f_RepSeastates \n")
  end
  
endfunction % f_RepSeastates



