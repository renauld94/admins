import os
import shutil

def sync_folders(src, dst, update_only=False):
    """
    Copy or update files and folders from src to dst.
    If update_only is True, only update files that are newer or missing in dst.
    """
    for root, dirs, files in os.walk(src):
        rel_path = os.path.relpath(root, src)
        dst_root = os.path.join(dst, rel_path) if rel_path != '.' else dst
        os.makedirs(dst_root, exist_ok=True)
        for file in files:
            src_file = os.path.join(root, file)
            dst_file = os.path.join(dst_root, file)
            if not os.path.exists(dst_file) or (os.path.getmtime(src_file) > os.path.getmtime(dst_file)):
                shutil.copy2(src_file, dst_file)
                print(f"Copied/Updated: {dst_file}")

def main():
    # Define your source and destination directories
    src1 = "/home/simon/Desktop/Python_Academy/Python Academy Courses"
    dst1 = "/home/simon/Desktop/learning-platform"
    src2 = "/home/simon/Desktop/learning-platform"
    dst2 = "/home/simon/Desktop/Python_Academy/Python Academy Courses"

    # Sync from Python Academy Courses to learning-platform
    print(f"Syncing from {src1} to {dst1} ...")
    sync_folders(src1, dst1, update_only=True)

    # Sync from learning-platform to Python Academy Courses
    print(f"Syncing from {src2} to {dst2} ...")
    sync_folders(src2, dst2, update_only=True)

if __name__ == "__main__":
    main()