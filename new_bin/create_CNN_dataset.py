import os
import sys
import shutil
import random
import argparse
import datetime

def get_simulations_list(simulations_path, scenarios, file_type):
    folder_list = os.listdir(simulations_path)
    all_files = []

    for folder in folder_list:
        if any(scenar in folder for scenar in scenarios):
            fileList = os.listdir(os.path.join(simulations_path, folder))
            filtered_files = [f for f in fileList if any(selection_type in f for selection_type in file_type)]
            all_files.append(filtered_files)

    return all_files

def get_unique_sim_ids(all_files):
    unique_strings = set()

    for inner_list in all_files:
        for item in inner_list:
            parts = item.split("_")
            if len(parts) > 1:
                unique_strings.add(parts[0])

    return list(unique_strings)

def split_sim_ids(sim_ID_list, train_ratio, valid_ratio, test_ratio):
    total_elements = len(sim_ID_list)
    train_count = int(total_elements * train_ratio)
    valid_count = int(total_elements * valid_ratio)
    test_count = total_elements - train_count - valid_count

    random.shuffle(sim_ID_list)

    train_list = sim_ID_list[:train_count]
    valid_list = sim_ID_list[train_count:train_count + valid_count]
    test_list = sim_ID_list[train_count + valid_count:]

    assert len(train_list) + len(valid_list) + len(test_list) == len(sim_ID_list), "Sum of subdataset len should be equal to len of sim_ID_list"

    return train_list, valid_list, test_list

def create_dataset_structure(output_dir, letter):
    timestamp = datetime.datetime.now().strftime("%m%d")
    base_dir = f"{output_dir}/DATASET-{letter}-2{timestamp}"

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

    for item in structure:
        os.makedirs(os.path.join(base_dir, item))

    print(f"Folder structure created at: {base_dir}")
    return base_dir

def copy_files_to_dataset(output_dir, sim_ID_list, all_files, train_list, test_list, valid_list, letter, simulations_path):
    DATASET_dir = create_dataset_structure(output_dir, letter)

    gP_images_files_names = ['globalPic.jpg', 'globalPic_matrix.txt', '.ms', 'parameters.txt', 'positions.txt', 'sumStats.txt', '.trees']
    rD_images_files_names = ['rawData.jpg', '.ms', 'parameters.txt', 'positions.txt', '.trees']
    gP_labels_files_names = ['globalPic.txt']
    rD_labels_files_names = ['rawData.txt']

    subdataset_lists = [train_list, test_list, valid_list]
    subdataset_names = ["train", "test", "valid"]

    for subdataset, sim_ids in zip(subdataset_names, subdataset_lists):
        for sim_id in sim_ids:
            for inner_list in all_files:
                for file_name in inner_list:
                    if sim_id in file_name:
                        for images_files_names in gP_images_files_names:
                            if images_files_names in file_name:
                                src_path = os.path.join(simulations_path, file_name)
                                dest_dir = os.path.join(output_dir, DATASET_dir, 'globalPic', subdataset, 'images')
                                shutil.copy(src_path, os.path.join(dest_dir, file_name))
                                print(f'Copy {file_name} to {dest_dir}')

                        for images_files_names in rD_images_files_names:
                            if images_files_names in file_name:
                                src_path = os.path.join(simulations_path, file_name)
                                dest_dir = os.path.join(output_dir, DATASET_dir, 'rawData', subdataset, 'images')
                                shutil.copy(src_path, os.path.join(dest_dir, file_name))
                                print(f'Copy {file_name} to {dest_dir}')

                        for images_files_names in gP_labels_files_names:
                            if images_files_names in file_name:
                                src_path = os.path.join(simulations_path, file_name)
                                dest_dir = os.path.join(output_dir, DATASET_dir, 'globalPic', subdataset, 'labels')
                                shutil.copy(src_path, os.path.join(dest_dir, file_name))
                                print(f'Copy {file_name} to {dest_dir}')

                        for images_files_names in rD_labels_files_names:
                            if images_files_names in file_name:
                                src_path = os.path.join(simulations_path, file_name)
                                dest_dir = os.path.join(output_dir, DATASET_dir, 'rawData', subdataset, 'labels')
                                shutil.copy(src_path, os.path.join(dest_dir, file_name))
                                print(f'Copy {file_name} to {dest_dir}')

def main():
    parser = argparse.ArgumentParser(description="Dataset Creation Script")
    parser.add_argument("--simulations_path", required=True, help="Path to simulations subdirectories")
    parser.add_argument("--scenarios", nargs="+", required=True, help="List of scenario directories to include")
    parser.add_argument("--file_type", nargs="+", required=True, help="List of file types to include")
    parser.add_argument("--output_dir", required=True, help="Output directory for the dataset")
    parser.add_argument("--train_ratio", type=float, required=True, help="Training set ratio (0.0 to 1.0)")
    parser.add_argument("--valid_ratio", type=float, required=True, help="Validation set ratio (0.0 to 1.0)")
    parser.add_argument("--test_ratio", type=float, required=True, help="Test set ratio (0.0 to 1.0)")
    parser.add_argument("--letter", required=True, help="Letter identifier for the dataset")

    args = parser.parse_args()

    all_files = get_simulations_list(args.simulations_path, args.scenarios, args.file_type)
    sim_ID_list = get_unique_sim_ids(all_files)
    train_list, valid_list, test_list = split_sim_ids(sim_ID_list, args.train_ratio, args.valid_ratio, args.test_ratio)
    copy_files_to_dataset(args.output_dir, sim_ID_list, all_files, train_list, test_list, valid_list, args.letter, args.simulations_path)

if __name__ == "__main__":
    main()
