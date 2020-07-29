Ahmet Furkan Biyik
21501084
23.11.2019

=========================================================
VLFEAT library was used for some image processing operations.
Download VLFEAT library for matlab from "http://www.vlfeat.org".
You can exract toolbox file into the source folder and run
"run('toolbox/vl_setup');" statement. If you extract file in different 
location give path of vl_setup.m file accordingly. 

Make sure VLFEAT is available before executing code.

=========================================================
Code requires image data. Extract files in the image data that shared on course page 
"http://www.cs.bilkent.edu.tr/~saksoy/courses/cs484-Fall2019/src/cs484_hw2_data.tar.gz"
outside of source folder or change "dataPath" variable in 
"entryPoint.m" file to execute code in these files.

=========================================================
Source files are in source folder. txt files are in txt folder. Result images are
in result folder.

=========================================================
entryPoint.m files creates database with images specified in txt files and evaluates
CBIR system. This operation takes some time (around 15 minutes). Wait until
it finishes.

=========================================================
Comments in entryPoint.m file explains options. 
You can generate or read txt files that consist of gallery
and query paths and labels. You can comment/uncomment read and generate code.
Path for txt files is txt folder. If you want to change it, change txtPath in 
entryPoint.m file.

=========================================================
After database created in entryPoint. CBIR system is evaluated for each
descriptor and codebook size. If you want to evaluate single 
descriptor and codebook see single evaluation part in entryPoint.m.

=========================================================
You can search individual images with search.m file after you created database.
Write image index and run the code. This index is index of queryImages path.

=========================================================

