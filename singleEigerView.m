%path = 'T:\current\raw\Sample2371W_etched\e4m\Sample2371W_etched_take_00083_data_000001.h5';
% path = 'T:\current\raw\JWX38_CsPbBr3_00035\e4m\JWX38_CsPbBr3_00035_master.h5';
path = 'T:\current\raw\Sample2371_ref_00053\e4m\Sample2371_ref_00053_master.h5';

im = openmultieiger4m_roi(path,1,40, ROI);
im = im.imm;


plot(squeeze(sum(sum(im,1),2)));
figure; imagesc((im));axis image