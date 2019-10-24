
#step1: use indoorContestTool.ipynb to get images.txt as initial model of colmap

#step2: copy the selected image to colmap directory, make new db, extract feature, match

#step3: use point_triangulator to make colmap model 
colmap point_triangulator \
--database_path ~/colmap_ws3/longtest/d.db\
 --image_path ~/colmap_ws3/images/ \
 --input_path ~/colmap_ws3/longtest/initial_model \
 --output_path ~/colmap_ws3/longtest/sparse 

#step4: use exportFeature.ipynb to  export feature 

#step5: transform .npz feature to .txt format and export them to colmap directory
python3 colmap-helpers/features_from_npz.py \
--npz_dir ~/hfnet/exp/exports/sfm/db/ \
--image_dir ~/colmap_ws3/images/

#step6: use hfnet feature to match other images using sift match prior
python3 colmap-helpers/match_features_with_db_prior.py \
 --num_points_per_frame 1000 \
 --use_ratio_test --ratio_test_values 0.8,0.75,0.7,0.65 \
 --image_dir ~/colmap_ws3/images/ \
 --npz_dir ~/hfnet/exp/exports/sfm/db/ \
 --image_prefix 0 \
 --database_file ~/colmap_ws3/longtest/d.db 


#step7: create new colmap database to restore hfnet model
colmap database_creator --database_path ~/colmap_ws3/longtest/hfnet/d.db

#step8: import feature to hfnet model database
colmap feature_importer \
--database_path ~/colmap_ws3/longtest/hfnet/d.db \
--image_path ~/colmap_ws3/images/ \
--import_path ~/colmap_ws3/images/


#step9: use updateDb.ipynb to update database


#step10: import match to database
colmap matches_importer \
--database_path ~/colmap_ws3/longtest/hfnet/d.db \
--match_list_path ~/oofs/hfnet/matches80.txt \
--match_type raw \
--SiftMatching.max_num_trials 20000 \
--SiftMatching.min_inlier_ratio 0.20

#step11: generate sfm model 
colmap point_triangulator \
--database_path ~/colmap_ws3/longtest/hfnet/d.db\
 --image_path ~/colmap_ws3/images/ \
 --input_path ~/colmap_ws3/longtest/hfnet/initial_model \
 --output_path ~/colmap_ws3/longtest/hfnet/sparse 

#step12 export hfnet colmap model as .txt model

#(localization)step13 use indoorContestTool.ipynb to localization
