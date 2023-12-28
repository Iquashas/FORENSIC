import os
import shutil
import subprocess
import sys

def secure_decrypt_and_process(key_iv_path, source_dir, destination_dir):
    if not os.path.exists(destination_dir):
        os.makedirs(destination_dir)

    with open(key_iv_path, 'r') as key_iv_file:
        key_iv_pairs = [line.strip().split(':') for line in key_iv_file]

    for folder_name in os.listdir(source_dir):
        folder_path = os.path.join(source_dir, folder_name)
        if os.path.isdir(folder_path):
            for key, iv in key_iv_pairs:
                decryption_success = secure_decrypt(folder_path, key.strip(), iv.strip())
                secure_process_files(folder_path, destination_dir, decryption_success)

def secure_decrypt(folder_path, key, iv):
    try:
        subprocess.run(['crypto_app.exe', '1PP0wpZEOM', 'd', folder_path + "\\", key, iv], check=True)
        print(f"Secure Decryption successful for folder {folder_path} with key: {key} and IV: {iv}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Secure Failed to decrypt folder {folder_path} with key: {key} and IV: {iv}. Error: {e}")
        return False

def secure_process_files(src_folder, dest_folder, is_decrypt_successful):
    for i, filename in enumerate(os.listdir(src_folder), start=1):
        file_path = os.path.join(src_folder, filename)
        if os.path.isfile(file_path) and not filename.endswith('.pachy'):
            new_filename = f"{i}_{filename}" if is_decrypt_successful else None
            new_path = os.path.join(dest_folder, new_filename) if is_decrypt_successful else None

            if is_decrypt_successful:
                shutil.copy(file_path, new_path)
            else:
                os.remove(file_path)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py key_iv_file source_folder destination_folder")
        sys.exit(1)

    key_iv = sys.argv[1]
    dossier = sys.argv[2]
    destination = sys.argv[3]

    secure_decrypt_and_process(key_iv, dossier, destination)
