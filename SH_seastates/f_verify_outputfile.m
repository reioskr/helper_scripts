function f_verify_outputfile(Inp,def)
%% Imports the exported txt file and does following checks:
% 1) Number of 045 cards must correspond to iter no in %no% and on 045 card (Error Code 1)
% 2) Check consistency of variables under each 045 card (Error Code 2)
% 3) Internal hist3 function, trim edges (Error Code 3)
% 4) Histcounts on the exported file, each nonzero value must correspond to No of realizations per bin (Error Code 4)
% 5) Recalculate Ti based on exported Tp and Inp.Tst, must correspond to one in the export file. Verify exported Tst value. (Error Code 5)
% 6) Complete check of output file- create histcount on exported data and compare with original imported counts (Error Code 6)

charspace=12+2; % 033 variable name allocation space (plus space padding begin and end)

% import exported file (cell2char):
charData=char(importdata(Inp.filename));
load(Inp.import_filename); % reimport SCD data, not passed over to this function

% extract card numbers 
card_num=str2double(charData(:,1:3));


%% 1) Number of 045 cards must correspond to iter no in %no% and on 045 card (Error Code 1)
isCard045=card_num==45;
no045Cards=sum(isCard045); 
% identify last 045 card and take its header:
idxLast045Card=find(isCard045, 1, 'last');
lastIterNo=strsplit(charData(idxLast045Card,:),' '); 
% extract last iteration %no%:
lastVars=charData(idxLast045Card+1:end,4:end); % ' ' padding in beginning
str_no=sprintf(' %s ',def.var_no.name); % lookup string definition, default: %no%
lastIterNoVar=strsplit(lastVars((sum(lastVars(:,1:6)~=str_no,2)==0),:),str_no);
% compare:
if str2double(lastIterNo{2})~=no045Cards || str2double(lastIterNoVar{2})~=no045Cards
  printf('Inconsistency in input file! \nTotal number of 045 Cards: %g\n',no045Cards);
  printf('Last 045 Card Iter number: %g\n',str2double(lastIterNo{2}));
  printf('Last 045 Card variable %%no%% value: %g\n',str2double(lastIterNoVar{2}));
  error('Code 1');
  return;
end

%% 2) Check consistency of variables under each 045 card (Error Code 2)
% check even if a single char is misplaced in variable list:
noVars=size(lastVars,1);
charData033=charData(~isCard045,4:end);
lastVarsUint8=uint8(lastVars(:,1:charspace)); % do uint8 comparisons
checksum1=reshape(sum(uint8(charData033(:,1:charspace)),2),noVars,size(charData033)/noVars); % reshape into (noVars;NoSeastes)
checksum2=sum(lastVarsUint8,2);
if sum(sum(checksum1~=checksum2))~=0
  printf('Inconsistency in input file!\n');
  error('Code 2');
  return;
end

varData=reshape(str2double(charData033(:,charspace+1:end)),noVars,size(charData033)/noVars)'; % reshape into (noVars;noSeastes)

% Note: by now its verified that variables are all there in numbers and repeating order.

% index def.variables in the list:
lastVarsUint8=uint8(lastVars(:,1:charspace)); % use this for finding the index
list=1:noVars;
idxCol=[];
fn=fieldnames(def);
% iterate over var name fields, compare str2uint8 with padded spaces around var name:
for i=1:numel(fn) 
  varName=def.(fn{i}).name;
  varNamePadded=uint8(strjoin({'',varName,repmat(' ',[1,charspace-numel(varName)-2])}));
  isCorVar=sum(lastVarsUint8==varNamePadded,2)==charspace;
  idxCol(i)=list(isCorVar);      % give numeric idx
  def.(fn{i}).idxCol=idxCol(i);  % assign to struct, next to var name
end

% all unique wave directions:
varWDR=sort(unique(varData(:,def.var_WDr.idxCol))); 

% Do bincountsExp by imported edges:
xEdges=meta.edges.Tp(1:end);
yEdges=meta.edges.Hm0(1:end);
EDGES{1}=xEdges-Inp.CorrectionParameter.Tp;
EDGES{2}=yEdges-Inp.CorrectionParameter.Hm0;
i=1;
countsExp=zeros(numel(xEdges),numel(yEdges),varWDR);
for i=1:numel(varWDR)
  isCorrectWDR=varData(:,1)==varWDR(i);
  tmpData=varData(isCorrectWDR,[def.var_WaP.idxCol,def.var_WaH.idxCol]);
  countsExp(:,:,i)=hist3(tmpData,"Edges", EDGES)'; % recount the exported values- WavH,WavP
end

%% 3) Internal hist3 function, trim edges (Error Code 3)
% hist3 does n+1 columns and rows from n=EDGES, which would be empty, trim them
if sum(sum(countsExp(:,end,:)))~=0 % extra precaution
  printf('Unexpected values in edges of histcount!\n');
  error('Code 3');
  return;
else
  countsExp(end,:,:)=[];
  countsExp(:,end,:)=[];
end

%% 4) Histcounts on the exported file, each nonzero value must correspond to No of realizations per bin (Error Code 4)
tmpCheckBinVal=countsExp(:);
tmpCheckBinVal(tmpCheckBinVal==0)=[];
if sum(tmpCheckBinVal~=Inp.N_rlz)~=0
  printf('Inconsistency in number of realized waves in exported data!\n');
  error('Code 4');
  return;
end
%% 5) Recalculate Ti based on exported Tp and Inp.Tst, must correspond to one in the export file. Verify exported Tst value. (Error Code 5)
% check sim time by: Inp.Ti= ceil(180*Inp.Tp./1.408+Inp.Tst) and Tst value
TpExp =varData(:,def.var_WaP.idxCol);
TstExp=varData(:,def.var_Tst.idxCol);
TiExp =varData(:,def.var_Ti.idxCol);

TiCalc=ceil(180*TpExp./1.408+Inp.Tst); % recalculate on extracted charData033, use Inp.Tst for unrounded value
Tst=round(Inp.Tst.*10)./10; % exported value gets rounded to 1 digit precision, do same here

if unique(TstExp)~=Tst || sum(TiCalc~=TiExp)~=0
  printf('Tst and Ti values are not as expected in export!\n');
  error('Code 5');
  % possibly can land here due to exported values format or changed Ti expression
  return;
end

%% 6) Complete check of output file- create histcount on exported data and compare with original imported counts (Error Code 6)
% now as have charData033 in 'countsExp' and original in 'counts', can compare each bin
counts(counts~=0)=Inp.N_rlz; % assign N_rlz to nonzero counts value

for i=1:numel(Inp.WDr) % check per direction, 
checksum(i)=sum(sum(counts(:,:,i)~=countsExp(:,:,Inp.WDr(i)==varWDR))); % match directions and compare
end

if sum(checksum)~=0
  printf('Found discrepancies in exported values (after histcount) with original counts!\n');
  printf('Debug info:\n');
  printf('sum(countsImp(:): %g!\n',sum(counts(:)));
  printf('sum(countsExp(:): %g!\n',sum(countsExp(:)));
  printf('checksum: %g!\n',sum(checksum(:)));
  error('Code 6');
  % possibly can land here due to application of Inp.Correctionfactors for Tp and Hm0
  return;
else
  printf('Export file successfully verified! Normal exit.\n');
end

endfunction % f_verify_outputfile

