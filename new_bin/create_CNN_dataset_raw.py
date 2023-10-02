import os
import sys
import shutil
import random
import argparse
import datetime

# SCRIPT ARGUMENTS #

scenarios=['CST', 'BTL', 'EXP']
file_type = ['neutral']

categories = ["test", "train", "valid"]
letter = "BANANA"


# Set path to simulations subdirectories and output_dir
simulations_path = "/home/speciation/glanfong/PhD/6S_SN/New_Version_28-08-2023/6S_Sweep/6S_Sweep/simulations/50_TEST_SIM/"
output_dir = "/home/speciation/glanfong/PhD/6S_SN/New_Version_28-08-2023/6S_Sweep/6S_Sweep/simulations/50_TEST_SIM/CNN_DATASET"

# Define the ratios
train_ratio = 0.60
valid_ratio = 0.30
test_ratio = 0.10



# Get list of simulations subdirectories
folder_list = os.listdir(simulations_path)

# Create a list to contains all files
# Contains 1 element per subdirectory
all_files = []

# Get list of files inside subdirectories that are of the correct scenario
for folder in folder_list:
    if any(scenar in folder for scenar in scenarios):
        fileList = os.listdir(simulations_path + '/' + folder)
        
        # Filter files based on the file type (e.g, "sweep", "neutral")
        filtered_files = [f for f in fileList if any (selection_type in f for selection_type in file_type)]

        # Append filtered list of files to all_files list
        all_files.append(filtered_files)



# Initialize an empty set to collect unique strings
unique_strings = set()

# Iterate through the list of lists
for inner_list in all_files:
    for item in inner_list:
        # Split the item using "_" and get the first part
        parts = item.split("_")
        if len(parts) > 1:
            unique_strings.add(parts[0])

# Convert the set to a list if needed
sim_ID_list = list(unique_strings)

# Get total number of files
total_files = len(sim_ID_list)
#print(total_files)

# Randomly shuffle the files
random.shuffle(sim_ID_list)


# Calculate the number of elements for each list
total_elements = len(sim_ID_list)
train_count = int(total_elements * train_ratio)
valid_count = int(total_elements * valid_ratio)
test_count = total_elements - train_count - valid_count

# Shuffle the original list to randomize the order
random.shuffle(sim_ID_list)

# Split the list into "train," "valid," and "test" lists
train_list = sim_ID_list[:train_count]
valid_list = sim_ID_list[train_count:train_count + valid_count]
test_list = sim_ID_list[train_count + valid_count:]

# Assertion for verification that sum = len(sim_ID_list)
assert len(train_list) + len(valid_list) + len(test_list) == len(sim_ID_list), "Sum of subdataset len should be equals to len of sim_ID_list"


# Get list of files to copy on each subdataset train, test and valid

# Create sets for faster membership testing
train_set = set(train_list)
test_set = set(test_list)
valid_set = set(valid_list)

# Create train_list_files
train_list_files = [file for sublist in all_files for file in sublist if any(item in file for item in train_set)]

# Create test_list_files
test_list_files = [file for sublist in all_files for file in sublist if any(item in file for item in test_set)]

# Create valid_list_files
valid_list_files = [file for sublist in all_files for file in sublist if any(item in file for item in valid_set)]

# Print the results
print("train_list_files:", train_list_files)
print("test_list_files:", test_list_files)
print("valid_list_files:", valid_list_files)


# Get list of folders from which each subdataset will take simulation files

# Train Sim Folders

# Initialize an empty set to collect unique strings
trainSimFolders = set()

#for inner_list in train_list:
for item in train_list:
    # Split the item using "_" and get the first part
    parts = item.split("-")
    if len(parts) > 1:
        trainSimFolders.add(str(parts[0] + '-' + parts[1] + '-' + parts[2])) 

# Test Sim Folders

# Initialize an empty set to collect unique strings
testSimFolders = set()

#for inner_list in train_list:
for item in train_list:
    # Split the item using "_" and get the first part
    parts = item.split("-")
    if len(parts) > 1:
        testSimFolders.add(str(parts[0] + '-' + parts[1] + '-' + parts[2])) 

# Valid Sim Folders

# Initialize an empty set to collect unique strings
validSimFolders = set()

#for inner_list in train_list:
for item in train_list:
    # Split the item using "_" and get the first part
    parts = item.split("-")
    if len(parts) > 1:
        validSimFolders.add(str(parts[0] + '-' + parts[1] + '-' + parts[2])) 


def create_dataset_structure(output_dir, letter):
    # Get the current timestamp
    timestamp = datetime.datetime.now().strftime("%m%d")
    
    # Define the base directory name
    base_dir = f"{output_dir}/DATASET-{letter}-2{timestamp}"
    
    # Define the directory structure
    structure = [
        "globalPic/test/images",
        "globalPic/test/labels",
        "globalPic/train/images",
        "globalPic/train/labels",
        "globalPic/valid/images",
        "globalPic/valid/labels",
        "rawData/test/images",
        "rawData/test/labels",
        "rawData/train/images",
        "rawData/train/labels",
        "rawData/valid/images",
        "rawData/valid/labels"
    ]
    
    # Create the directory structure
    for item in structure:
        os.makedirs(os.path.join(base_dir, item))
    
    print(f"Folder structure created at: {base_dir}")
    return(base_dir)

DATASET_dir = create_dataset_structure(output_dir, letter)
output_dir = os.path.join(output_dir, DATASET_dir)

gP_images_files_names = ['globalPic.jpg', 'globalPic_matrix.txt', '.ms', 'parameters.txt', 'positions.txt', 'sumStats.txt', '.trees']
rD_images_files_names = ['rawData.jpg', '.ms', 'parameters.txt', 'positions.txt', '.trees']
gP_labels_files_names = ['globalPic.txt']
rD_labels_files_names = ['rawData.txt']


# Iterate through test_list_files
for list_of_files in [train_list_files, test_list_files, valid_list_files]:

    if list_of_files == train_list_files:
        subdataset = 'train'

    if list_of_files == test_list_files:
        subdataset = 'test'

    if list_of_files == valid_list_files:
        subdataset = 'valid'

    for file_name in list_of_files:

        # Iterate through testSimFolders
        for folder_name in testSimFolders:

            if folder_name in file_name:
                #print(file_name)
                for images_files_names in gP_images_files_names:
                    if images_files_names in file_name:
                        print(f'Copy {file_name} to {output_dir}/globalPic/images')
                        # Move or copy the file to the destination directory
                        # shultil.move to just move the files
                        shutil.copy(os.path.join(simulations_path, folder_name, file_name), os.path.join(output_dir, 'globalPic', subdataset, 'images', file_name))

                for images_files_names in rD_images_files_names:
                    if images_files_names in file_name:
                        print(f'Copy {file_name} to {output_dir}/rawData/images')
                        shutil.copy(os.path.join(simulations_path, folder_name, file_name), os.path.join(output_dir, 'rawData', subdataset, 'images', file_name))

                for images_files_names in gP_labels_files_names:
                    if images_files_names in file_name:
                        print(f'Copy {file_name} to {output_dir}/globalPic/labels')
                        shutil.copy(os.path.join(simulations_path, folder_name, file_name), os.path.join(output_dir, 'globalPic', subdataset, 'labels', file_name))


                for images_files_names in rD_labels_files_names:
                    if images_files_names in file_name:
                        print(f'Copy {file_name} to {output_dir}/rawData/labels')
                        shutil.copy(os.path.join(simulations_path, folder_name, file_name), os.path.join(output_dir, 'rawData', subdataset, 'labels', file_name))

        # Iterate through trainSimFolders
        for folder_name in trainSimFolders:

            if folder_name in file_name:
                #print(file_name)
                for images_files_names in gP_images_files_names:
                    if images_files_names in file_name:
                        print(f'Copy {file_name} to {output_dir}/globalPic/images')
                        # Move or copy the file to the destination directory
                        # shultil.move to just move the files
                        shutil.copy(os.path.join(simulations_path, folder_name, file_name), os.path.join(output_dir, 'globalPic', subdataset, 'images', file_name))

                for images_files_names in rD_images_files_names:
                    if images_files_names in file_name:
                        print(f'Copy {file_name} to {output_dir}/rawData/images')
                        shutil.copy(os.path.join(simulations_path, folder_name, file_name), os.path.join(output_dir, 'rawData', subdataset, 'images', file_name))

                for images_files_names in gP_labels_files_names:
                    if images_files_names in file_name:
                        print(f'Copy {file_name} to {output_dir}/globalPic/labels')
                        shutil.copy(os.path.join(simulations_path, folder_name, file_name), os.path.join(output_dir, 'globalPic', subdataset, 'labels', file_name))


                for images_files_names in rD_labels_files_names:
                    if images_files_names in file_name:
                        print(f'Copy {file_name} to {output_dir}/rawData/labels')
                        shutil.copy(os.path.join(simulations_path, folder_name, file_name), os.path.join(output_dir, 'rawData', subdataset, 'labels', file_name))

        # Iterate through validSimFolders
        for folder_name in validSimFolders:

            if folder_name in file_name:
                #print(file_name)
                for images_files_names in gP_images_files_names:
                    if images_files_names in file_name:
                        print(f'Copy {file_name} to {output_dir}/globalPic/images')
                        # Move or copy the file to the destination directory
                        # shultil.move to just move the files
                        shutil.copy(os.path.join(simulations_path, folder_name, file_name), os.path.join(output_dir, 'globalPic', subdataset, 'images', file_name))

                for images_files_names in rD_images_files_names:
                    if images_files_names in file_name:
                        print(f'Copy {file_name} to {output_dir}/rawData/images')
                        shutil.copy(os.path.join(simulations_path, folder_name, file_name), os.path.join(output_dir, 'rawData', subdataset, 'images', file_name))

                for images_files_names in gP_labels_files_names:
                    if images_files_names in file_name:
                        print(f'Copy {file_name} to {output_dir}/globalPic/labels')
                        shutil.copy(os.path.join(simulations_path, folder_name, file_name), os.path.join(output_dir, 'globalPic', subdataset, 'labels', file_name))


                for images_files_names in rD_labels_files_names:
                    if images_files_names in file_name:
                        print(f'Copy {file_name} to {output_dir}/rawData/labels')
                        shutil.copy(os.path.join(simulations_path, folder_name, file_name), os.path.join(output_dir, 'rawData', subdataset, 'labels', file_name))