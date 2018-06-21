function subjs = load_subjs(proj)
% LOAD_SUBJS loads an array of subjs structures, where each
% structure contains subject information necessary to gather
% data for processing
%
%  [subjs] = load_subjs(proj)
%
%  ARGUMENTS
%    proj = project structure
%
%  OUTPUTS
%    subjs = array of subj structures where each structure contains
%      study: the study they come from
%      id: their numerical position in the study's subject list
%      name: the subjects study i.d.
%
%  REFERENCES

cnt = 1;
for i = 1:numel(proj.param.studies)

    study = proj.param.studies{i};
    path = [proj.path.subj_list,study,'_subj_list.txt'];
    disp(['Processing: ',path]);

    subj_ids = textread(path,'%s','delimiter','\n');

    for j = 1:numel(subj_ids)
        subj = struct();
        subj.study = study;
        subj.id = j;
        subj.name = subj_ids{j};
        subjs{cnt} = subj;
        cnt = cnt+1;
    end
    
end