
#step1: use indoorContestTool.ipynb to get images.txt as initial model of colmap, put it into initial_model dir
#step1.1 cameras.txt with camera parameter into initial_model: 

# Camera list with one line of data per camera:
#   CAMERA_ID, MODEL, WIDTH, HEIGHT, PARAMS[]
# Number of cameras: 1
1 OPENCV_FISHEYE 848 880 284.981000 286.102000 425.244000 398.468000 -0.007305 0.043500 -0.041283 0.007652

#step1.2 generate EMPTY points3D.txt in initial_model

#step2: copy the selected image to colmap directory, 1) make new db, 2) extract feature, 3) match.
# This stepn will generage colmap .db 

#step3: use point_triangulator to make colmap model 
colmap point_triangulator \
--database_path ~/colmap_ws3/longtest/d.db\
 --image_path ~/colmap_ws3/images/ \
 --input_path ~/colmap_ws3/longtest/initial_model \
 --output_path ~/colmap_ws3/longtest/sparse 

# this step will generate three .bin file in sparse dir.

#step4: use exportFeature.ipynb to  export feature,  recorded as .npz
#This step will generate superpoint feature. HfNet inference.

#step5: transform .npz feature to .txt format and export them to colmap directory
python3 colmap-helpers/features_from_npz.py \
--npz_dir ~/hfnet/exp/exports/sfm/db/ \
--image_dir ~/colmap_ws3/images/

# This will generate .txt files in image folder.

#step6: use hfnet feature to match other images using sift match prior
python3 colmap-helpers/match_features_with_db_prior.py \
 --num_points_per_frame 1000 \
 --use_ratio_test --ratio_test_values 0.8,0.75,0.7,0.65 \
 --image_dir ~/colmap_ws3/images/ \
 --npz_dir ~/hfnet/exp/exports/sfm/db/ \
 --image_prefix 0 \
 --database_file ~/colmap_ws3/longtest/d.db 

# This will write info into .db file.

#step7: create new colmap database to restore hfnet model
colmap database_creator --database_path ~/colmap_ws3/longtest/hfnet/d.db

#step8: import feature to hfnet model database
colmap feature_importer \
--database_path ~/colmap_ws3/longtest/hfnet/d.db \
--image_path ~/colmap_ws3/images/ \
--import_path ~/colmap_ws3/images/


#step9: use updateDb.ipynb to update database
#This will update db information, mainly to modify the camera model to one.


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
 --input_path ~/colmap_ws3/longtest/initial_model \
 --output_path ~/colmap_ws3/longtest/hfnet/sparse 

#step12 load colmap model and export hfnet colmap model as .txt model
# export button incolmap GUI.

#(localization)step13 use indoorContestTool.ipynb to localization.
# To visualize relocalization result, copy camera.txt and point3D.txt with the image.txt to one
# folder and open it using colmap.
