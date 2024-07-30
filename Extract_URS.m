clear all; clearvars; clc;close all
% Octave file, vers. 5.1.0 /OREI
% Read and collect results and formulate into report tables.

% Pipes URS files:
Pipesfiles={  
         '..\DFF_ULS_DNV_ur_pp02.urs',...
         '..\DFF_ULS_DNV_ur_pp03.urs',...
         '..\DFF_ALS_DNV_ur_pp02.urs',...
         '..\DFF_ALS_DNV_ur_pp03.urs'
         };

% Strech URS files:
files={  
         '..\DFF_ULS_ISO-000\DFF_ULS_ISO_ur_st02.urs',...
         '..\DFF_ALS_ISO-000\DFF_ALS_ISO_ur_st02.urs'
         };

Inp.SUB={'2019';'2047'};

% replace analysis number in paths:
Pipesfiles=strrep(Pipesfiles,"-000","-001"); 
files=strrep(files,"-000","-001");


% Additional:
Inp.NameConv={'S','R','T'}; % Element name convention for Spool, Riser, Topside elements (etc. 1001R and R1001 for Rfciser)


function [outDir,outPos,outSUB]=solveName(strCase,Inp)
outDir=strCase(1:2);% Direction
 if strcmp(strCase(3:5),'MAB')
   outPos='MABS';
 elseif strcmp(strCase(3:5),'MOT')
   outPos='MOTM';
 elseif strcmp(strCase(3:5),'RIB')   
   outPos='RIBS';
 else
   outPos='error';
 end
 
 if strCase(6)=='1'
   outSUB=Inp.SUB{1};
 elseif strCase(6)=='2'
   outSUB=Inp.SUB{2};
else
   outPos='error';
 end
end

function stringOut = formatString(Inp,cellArr,idxIn,i)
  if str2double(cell2mat(cellArr(idxIn.maxIdx(i),8)))==idxIn.maxV(i) % sanity check
  el_name=erase(cell2mat(cellArr(idxIn.maxIdx(i),2)), '"'); % element name
  combName=erase(cell2mat(cellArr(idxIn.maxIdx(i),7)), '"'); % Wave position
  [outDir,outPos,outSUB]=solveName(combName,Inp);
  out_UR=str2double(cell2mat(cellArr(idxIn.maxIdx(i),8))); % UR
  out_URtype=erase(cell2mat(cellArr(idxIn.maxIdx(i),6)), '"'); % UR type
  stringOut=sprintf('%s;%s;%s;%s;%.2f;%s',el_name,outPos,outDir,outSUB,out_UR,out_URtype);
else
  disp('error1');
  end
end

function main(Inp,currentFilePath)
%currentFilePath=files{1};

  fid = fopen(currentFilePath);
  char_arr = char(textscan(fid,'%s','Delimiter',{'\n'}));
  fclose(fid);
  a=textscan(char_arr(:,:),'%s','Delimiter',',');
  for i=1:size(char_arr(),1)
    b(i)=textscan(char_arr(i,:),'%s','Delimiter',',');
  end



% metalines and end of data:
metalines=1;
while(~strcmp(char_arr(metalines,1:7),'#ELEMUR'))
metalines=metalines+1;
end
EOD=length(char_arr);
while(~strcmp(char_arr(EOD,1:7),'#ELEMUR'))
EOD=EOD-1;
end


g=cell2mat(b(metalines:EOD))';
char_elem=char(g(:,2));

uniques=unique(char_elem(:,2));
uniq_nums=str2double(uniques);
uniq_letters=uniques(isnan(uniq_nums));
uniq_nums(isnan(uniq_nums))=[];

fo_name=char(textscan(currentFilePath,'%s','Delimiter',{'\'}));
fn_name=sprintf("%s.csv",fo_name(end,:)); % take last folder name as output filename
fo = fopen( fn_name, 'w');
if fo == -1; error('Could not open file %s for writing',fn_name);end
fprintf(fo,'%s%s\n','file:\\',currentFilePath); % print file path

if Inp.isPipes==1 % Pipes file (additionally checks element end last character for S, R, T and table for bend members that are starting with letters S, R, T)
   if isempty(uniq_nums)
     uniques=unique(char_elem(:,3)); % small circumvention, may cause issues (take riser numerics from element name 2nd character, case for C2 file with only bend members)
   end
   % Straight members:
   for i=1:length(uniq_nums)
     idx.name(i)=uniq_nums(i);
     idx.S(:,i)=char_elem(:,2)==uniques(i) & char_elem(:,end-1)==Inp.NameConv{1}; % Spool
     idx.R(:,i)=char_elem(:,2)==uniques(i) & char_elem(:,end-1)==Inp.NameConv{2}; % Riser
     idx.T(:,i)=char_elem(:,2)==uniques(i) & char_elem(:,end-1)==Inp.NameConv{3}; % Topside
     % elements list: char_elem(idx.S(:,i),:)
     gS=g(idx.S(:,i),:);  
     gR=g(idx.R(:,i),:);  
     gT=g(idx.T(:,i),:);  
     
     [idx.Spool.maxV(i),idx.Spool.maxIdx(i)]=max(str2num(cell2mat(gS(:,8))));
     [idx.Riser.maxV(i),idx.Riser.maxIdx(i)]=max(str2num(cell2mat(gR(:,8))));
     [idx.Topside.maxV(i),idx.Topside.maxIdx(i)]=max(str2num(cell2mat(gT(:,8))));  
   end
   
   % Bend members:
   for i=1:size(uniq_letters,1)
     idx.name(i)=uniq_letters(i);
     idx.BS(:,i)=char_elem(:,3)==uniques(i) & char_elem(:,2)==Inp.NameConv{1}; % Spool
     idx.BR(:,i)=char_elem(:,3)==uniques(i) & char_elem(:,2)==Inp.NameConv{2}; % Riser
     idx.BT(:,i)=char_elem(:,3)==uniques(i) & char_elem(:,2)==Inp.NameConv{3}; % Topside
     gBS=g(idx.BS(:,i),:);  
     gBR=g(idx.BR(:,i),:);  
     gBT=g(idx.BT(:,i),:);  
     
     [idx.SpoolB.maxV(i),idx.SpoolB.maxIdx(i)]=max(str2num(cell2mat(gBS(:,8))));
     [idx.RiserB.maxV(i),idx.RiserB.maxIdx(i)]=max(str2num(cell2mat(gBR(:,8))));
     [idx.TopsideB.maxV(i),idx.TopsideB.maxIdx(i)]=max(str2num(cell2mat(gBT(:,8))));  
   end
   
   fprintf(fo,'\n\nStraight Members:\n');
   fprintf(fo,'Type;Element Name;Wave position;True direction;Subsidence level;UR;TYPE\n');
   
   for i=1:length(uniq_nums)
     gS=g(idx.S(:,i),:);  
     gR=g(idx.R(:,i),:);  
     gT=g(idx.T(:,i),:);  
     
     % Table format:
     fprintf(fo,'%s;%s\n','Topside',formatString(Inp,gT,idx.Topside,i));
     fprintf(fo,'%s;%s\n','Riser',  formatString(Inp,gR,idx.Riser,i));
     fprintf(fo,'%s;%s\n','Spool',  formatString(Inp,gS,idx.Spool,i));
   end
   
   fprintf(fo,'\n\nBend Members:\n');
   fprintf(fo,'Type;Element Name;Wave position;True direction;Subsidence level;UR;TYPE\n');
   for i=1:size(uniq_letters,1)
     gBS=g(idx.BS(:,i),:);  
     gBR=g(idx.BR(:,i),:);  
     gBT=g(idx.BT(:,i),:);  
   
     % Table format:
     fprintf(fo,'%s;%s\n','Topside',formatString(Inp,gBT,idx.TopsideB,i));
     fprintf(fo,'%s;%s\n','Riser',  formatString(Inp,gBR,idx.RiserB,i));
     fprintf(fo,'%s;%s\n','Spool',  formatString(Inp,gBS,idx.SpoolB,i));
   end
   else % Not pipes file
   % uniq_nums members:
   for i=1:length(uniq_nums)
     idx.name(i)=uniq_nums(i);
     idx.S(:,i)=char_elem(:,2)==uniques(i);
     % elements list: char_elem(idx.S(:,i),:)
     gS=g(idx.S(:,i),:);  
     [idx.uniq_nums.maxV(i),idx.uniq_nums.maxIdx(i)]=max(str2num(cell2mat(gS(:,8))));
   end
   % uniq_letters members:
   for i=1:length(uniq_letters)
     idx.name(i)=uniq_letters(i);
     idx.BS(:,i)=char_elem(:,2)==uniq_letters(i);
     gBS=g(idx.BS(:,i),:);  
     [idx.uniq_letters.maxV(i),idx.uniq_letters.maxIdx(i)]=max(str2num(cell2mat(gBS(:,8))));
   end
   
   fprintf(fo,'\n\nMembers:\n');
   fprintf(fo,'Type;Element Name;Wave position;True direction;Subsidence level;UR;TYPE\n');
   fprintf('Extracted max results for element names starting with:\n');
   for i=1:length(uniq_nums)
     gS=g(idx.S(:,i),:);  
     % Table format:
     fprintf(fo,'%s;%s\n','Unique first number',  formatString(Inp,gS,idx.uniq_nums,i));
     fprintf('%g, ',uniq_nums(i))
   end
   for i=1:length(uniq_letters)
     gBS=g(idx.BS(:,i),:);  
     % Table format:
     fprintf(fo,'%s;%s\n','Unique first letter',  formatString(Inp,gBS,idx.uniq_letters,i));
     fprintf('%s, ',uniq_letters(i));                                                                  
   end
     fprintf('- Adjust accordingly\n');
   end

fclose(fo);
fprintf('Saved: %s\n\n',fn_name);
end

for i=1:length(Pipesfiles)
  Inp.isPipes=1;
  main(Inp,Pipesfiles{i})
end

for i=1:length(files)
  Inp.isPipes=0;
  main(Inp,files{i})
end
fclose all;