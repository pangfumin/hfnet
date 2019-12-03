# PART 1: Build SFM model use original Colmap pipeline to get image 6D poses in world.
#Step1: create a colmap project, 1)make new db, 2)extract feature, 3)match, 4)construction.
#Then export the results as txt files.
#This step will generate cameras.txt, images.txt, point3D.txt


# PART 2: Inference hfnet local features and macth them with sift match prior from Step 1.

#Step2: use exportFeature.ipynb to  export feature,  recorded as .npz
#This step will generate superpoint feature. HfNet inference.

#step3: transform .npz feature to .txt format and export them to colmap directory
# This will generate .txt files in image folder.
python3 colmap-helpers/features_from_npz.py \
--npz_dir ~/hfnet/exp/exports/sfm/db/ \
--image_dir ~/colmap_ws3/images/


#step4: use hfnet feature to match other images using sift match prior
python3 colmap-helpers/match_features_with_db_prior.py \
 --num_points_per_frame 1000 \
 --use_ratio_test --ratio_test_values 0.8,0.75,0.7,0.65 \
 --image_dir ~/colmap_ws3/images/ \
 --npz_dir ~/hfnet/exp/exports/sfm/db/ \
 --image_prefix 0 \
 --database_file ~/colmap_ws3/longtest/d.db 

# This will generate match files on ratio 0.8,0.75,0.7,0.65

# PART 3: Create new colmap sfm using hfnet feature tracks and original Colmap image 6D poses

#step5: create new colmap database to restore hfnet model
colmap database_creator --database_path ~/colmap_ws3/longtest/hfnet/d.db

#step6: import feature to hfnet model database
colmap feature_importer \
--database_path ~/colmap_ws3/longtest/hfnet/d.db \
--image_path ~/colmap_ws3/images/ \
--import_path ~/colmap_ws3/images/


#step7: use updateDb.ipynb to update database.
# In this step camera intrinsic need modified in updateDb.ipynb.
#This will update db information, mainly to modify the camera model to one.


#step8: import match to database
colmap matches_importer \
--database_path ~/colmap_ws3/longtest/hfnet/d.db \
--match_list_path ~/oofs/hfnet/matches80.txt \
--match_type raw \
--SiftMatching.max_num_trials 20000 \
--SiftMatching.min_inlier_ratio 0.20

#step9: generate sfm model 
colmap point_triangulator \
--database_path ~/colmap_ws3/longtest/hfnet/d.db\
 --image_path ~/colmap_ws3/images/ \
 --input_path ~/colmap_ws3/longtest/initial_model \
 --output_path ~/colmap_ws3/longtest/hfnet/sparse 

#step10 load colmap model and export hfnet colmap model as .txt model
# export button incolmap GUI.

