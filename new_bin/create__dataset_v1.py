# Keywords : python, 6S-SN, CNN, dataset

# Input : CST/BTL/EXP/MIG/MGB/MGX folders
# Output : CNN/YOLOv5 datasets

import os
import sys
import shutil
import random
import argparse
import datetime

def getFileList(simulations_path, scenarios):

    # Get a list of all files inside the folders in simulations_path
    # Only directories which scenario is contained in 'scenario' will
    # be processed i.e, example : scenario = ['BTL', 'CST', 'EXP']

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

    return all_files


def shuffleSimList(all_files):

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

    # Randomly shuffle the files
    random.shuffle(sim_ID_list)

    return sim_ID_list

def splitSimList(sim_ID_list, all_files):
    # Calculate the number of elements for each list
    total_elements = len(sim_ID_list)
    train_count = int(total_elements * train_ratio)
    valid_count = int(total_elements * valid_ratio)

    # Shuffle the original list to randomize the order
    random.shuffle(sim_ID_list)

    # Split the list into "train," "valid," and "test" lists
    train_list = sim_ID_list[:train_count]
    valid_list = sim_ID_list[train_count:train_count + valid_count]
    test_list = sim_ID_list[train_count + valid_count:]

    # Assertion for verification that sum = len(sim_ID_list)
    assert len(train_list) + len(valid_list) + len(test_list) == len(sim_ID_list), "Sum of subdataset len should be equals to len of sim_ID_list"

    return train_list, valid_list, test_list

def subdatasetSimList(all_files, subdataset_list):
    # Get list of files to copy on each subdataset train, test and valid
    # Create sets for faster membership testing
    # To be used in 'train', 'valid' and 'test' *_list

    subdataset_set = set(subdataset_list)

    # Create subdataset_list_files
    subdataset_list_files = [file for sublist in all_files for file in sublist if any(item in file for item in subdataset_set)]

    return subdataset_list_files

def subdatasetSimFolders(subdataset_list):
    # Get list of folders from which each subdataset will take simulation files
    # To be used in 'train', 'valid' and 'test' *_list
    # Initialize an empty set to collect unique strings
    resSimFolders = set()

    # For inner_list in subdataset_list
    for item in subdataset_list:
        # Split the item using "_"
        part = item.split("-")
        if len(parts) > 1:
            resSimFolders.add(str(parts[0] + '-' + parts[1] + '-' + parts[2]))

    return resSimFolders

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


def copySimFiles(simulations_path, folder_name, output_dir, subdataset, rDgP_images_files_names, file_name):
    for images_files_names in rDgP_images_files_names:
        if images_files_names in images_files_names:
            shutil.copy(os.path.join(simulations_path, folder_name, file_name), os.path.join(output_dir, 'globalPic', subdataset, 'images', file_name))

if __name__ == '__main__' :

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

    all_files = getFileList(simulations_path, scenarios)
    sim_ID_list = shuffleSimList(all_files)
    splited_SimList = splitSimList(sim_ID_list, all_files)


    tvt_list, tvt_simFolders = [], []
    for split_list in splited_SimList:
        tvt_list.append(subdatasetSimList(all_files, split_list))
        tvt_simFolders.append(subdatasetSimFolders(split_list))


    DATASET_dir = create_dataset_structure(output_dir, letter)
    output_dir = os.path.join(output_dir, DATASET_dir)

    gP_images_files_names = ['globalPic.jpg', 'globalPic_matrix.txt', '.ms', 'parameters.txt', 'positions.txt', 'sumStats.txt', '.trees']
    rD_images_files_names = ['rawData.jpg', '.ms', 'parameters.txt', 'positions.txt', '.trees']
    gP_labels_files_names = ['globalPic.txt']
    rD_labels_files_names = ['rawData.txt']
    rDgP_files_names = [gP_images_files_names, rD_images_files_names, gP_labels_files_names, rD_labels_files_names]

    # Iterate through testSimFolders
    for simFolderList, list_of_files, subdataset in tvt_simFolders, tvt_list, ('train', 'valid', 'test'):
        for file_name in list_of_files:
            for folder_name in simFolderList:
                if folder_name in file_name:
                        for rDgP_images_files_names in rDgP_files_names:
                            type(simulations_path)
                            type(folder_name)
                            type(output_dir)
                            type(subdataset)
                            type(rDgP_images_files_names)
                            type(file_name)
                            copySimFiles(simulations_path, folder_name, output_dir, subdataset, rDgP_images_files_names, file_name)