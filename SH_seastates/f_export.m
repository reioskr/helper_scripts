%% function f_export(Data,Inp)
function def=f_export(Data,Inp)
fileID = fopen(Inp.filename,'w');
  
% var names template used in f_export and f_verify_outputfile:
def.var_WDr.name ='%WDr%';
def.var_Ti.name  ='%Ti%';
def.var_Tst.name ='%Tst%';
def.var_WaH.name ='%WaH%';
def.var_WaP.name ='%WaP%';
def.var_SPRD.name='%SPRD%';
def.var_SEED.name='%SEED%';
def.var_no.name  ='%no%';

charspace=12; % 033 variable name allocation space
% add padding to strings:
var_WDr =f_stringpad(def.var_WDr.name, charspace);
var_Ti  =f_stringpad(def.var_Ti.name,  charspace);
var_Tst =f_stringpad(def.var_Tst.name, charspace); 
var_WaH =f_stringpad(def.var_WaH.name, charspace); 
var_WaP =f_stringpad(def.var_WaP.name, charspace); 
var_SPRD=f_stringpad(def.var_SPRD.name,charspace);
var_SEED=f_stringpad(def.var_SEED.name,charspace);
var_no  =f_stringpad(def.var_no.name,  charspace);

% general check before proceeding:
  if Inp.ExportChecksum>9999;
    printf('\nNumber of seastates: %g \n',Inp.ExportChecksum);
    printf('Sheila 045 card max character space: 9999\n');
    printf('Consider reviewing input: Inp.N_rlz\n');
    error('Too many seastates');
    % could overcome by changing 045 name defition
    return;
  end

incr=1;
printf("\nWriting to export file...\n");
for iterNo=1:size(Data,2) % iter over directions
  Seastates=Data(iterNo).Seastates; % [Hm0(:), Tp(:), SPR(:), Ti(:)]:


  for No=1:size(Seastates,1) % iterate over all entries per direction
  % single values per seastate:
  WaH =Seastates(No,1); % Hm0
  WaP =Seastates(No,2); % Tp
  SPRD=Seastates(No,3); % SPR
  Ti  =Seastates(No,4); % Ti
  
  % template:
  fprintf(fileID,'045 %04d   1    SEA DETAILS\n', incr        );
  fprintf(fileID,'033 %s  %05.1f\n', var_WDr,Data(iterNo).WDr );
  fprintf(fileID,'033 %s  %04d\n'  , var_Ti,Ti                );
  fprintf(fileID,'033 %s  %05.1f\n', var_Tst,Inp.Tst          );
  fprintf(fileID,'033 %s  %05.2f\n', var_WaH,WaH              );
  fprintf(fileID,'033 %s  %05.2f\n', var_WaP,WaP              );
  fprintf(fileID,'033 %s  %06.2f\n', var_SPRD,SPRD            );
  fprintf(fileID,'033 %s  %06d\n'  , var_SEED,Inp.SEED+incr   );
  fprintf(fileID,'033 %s  %04d\n'  , var_no,incr              );
  fprintf(fileID,'\n')

  incr=incr+1;
  endfor
endfor

fclose(fileID);

  if incr-1~=Inp.ExportChecksum; % if mismatch No of Seastates in export
    error("\nMismatch in No of Waves in export \n")
    return;
  end

printf("\n\nTotal number of Wave directions: %d \n", size(Data,2)); 
printf("Total entries: %d \n", incr-1); 

endfunction % f_export

function strout=f_stringpad(stringin,charspace) % add padding to string end
   strout =sprintf('%s%s',stringin,repelem(' ',charspace-numel(stringin)));
endfunction % f_stringpad