function [basisVs,feature] = gram_schmidt(img)

% GRAM_SCHMIDT: conducts cross-validation using svm via the specified kernel
%
%   [trn_fold, tst_fold, ...] = CLASSIFY_CV(data,trn_fold,tst_fold,kernel)
%
%   ARGUMENTS 
%
%   OUPUTS

[M N]= size(img);

basisVs=[]; %basisVectors are in rows; if all brain imgs add one novel
            %orthogonal direction to the space (AS EXPECTED DUE TO THE
            %HIGH DIMENSIONALITY OF THE SAMPLING SPACE IN RELATION TO
            %THE NUMBER OF BRAIN IMGS WE COLLECT), then this will be a
            %square matrix.

orthoV=img(1,:); %first brain image determines the direction of the first
                 %basisVector, as per gram schmidt procedure

basisVs=orthoV/norm(orthoV);

for i=2:M
    
    if mod(i,100)==0
        disp(['GS: ',num2str(i)]);
    end
    
    orthoV=img(i,:);
    for j=1:size(basisVs,1)
        orthoV=orthoV-(basisVs(j,:)*dot(basisVs(j,:),orthoV));
    end
    
    orthoVNorm=norm(orthoV);
    if orthoVNorm>0
        basisVs = [basisVs; orthoV/orthoVNorm];
    end
    
end

%%Project the data into new coordinates
feature=basisVs*img';
feature=feature'; %each row is a separate brain img as before (and
                  %cols are coords, as before)

