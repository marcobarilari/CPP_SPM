% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function matlabbatch = setBatchCoregistration(matlabbatch, BIDS, subID, opt)

  fprintf(1, ' BUILDING SPATIAL JOB : COREGISTER\n');

  matlabbatch{end + 1}.spm.spatial.coreg.estimate.ref(1) = ...
      cfg_dep('Named File Selector: Anatomical(1) - Files', ...
              substruct( ...
                        '.', 'val', '{}', {opt.orderBatches.selectAnat}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}), ...
              substruct('.', 'files', '{}', {1}));

  % SOURCE IMAGE : DEPENDENCY FROM REALIGNEMENT
  % Mean Image

  meanImageToUse = 'rmean';
  otherImageToUse = 'cfiles';
  if strcmp(opt.space, 'individual')
    meanImageToUse = 'meanuwr';
    otherImageToUse = 'uwrfiles';
  end

  matlabbatch{end}.spm.spatial.coreg.estimate.source(1) = ...
      cfg_dep('Realign: Estimate & Reslice/Unwarp: Mean Image', ...
              substruct( ...
                        '.', 'val', '{}', {opt.orderBatches.realign}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}, ...
                        '.', 'val', '{}', {1}), ...
              substruct('.', meanImageToUse));

  % OTHER IMAGES : DEPENDENCY FROM REALIGNEMENT

  [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');

  runCounter = 1;

  for iSes = 1:nbSessions

    % get all runs for that subject for this session
    [~, nbRuns] = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

    for iRun = 1:nbRuns

      matlabbatch{end}.spm.spatial.coreg.estimate.other(runCounter) = ...
          cfg_dep([ ...
                   'Realign: Estimate & Reslice/Unwarp: Realigned Images (Sess ', ...
                   num2str(runCounter), ...
                   ')'], ...
                  substruct( ...
                            '.', 'val', '{}', {opt.orderBatches.realign}, ...
                            '.', 'val', '{}', {1}, ...
                            '.', 'val', '{}', {1}, ...
                            '.', 'val', '{}', {1}), ...
                  substruct( ...
                            '.', 'sess', '()', {runCounter}, ...
                            '.', otherImageToUse));

      runCounter = runCounter + 1;

    end

  end

  % The following lines are commented out because those parameters
  % can be set in the spm_my_defaults.m
  % matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
  % matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
  % matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.tol = ...
  % [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
  % matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

end