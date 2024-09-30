#Wildcards helper function - properly generate wildcards from .fastq files
import glob
import os


def listFastq(wildcards):
    sample_path = os.path.join(config['input_dir'])
    fastqs = []
    
    if os.path.isdir(sample_path):
        # Check if there are subdirectories
        subdirs = [d for d in os.listdir(sample_path) if os.path.isdir(os.path.join(sample_path, d))]
        
        if subdirs:
            # If there are subdirectories, use them as wildcards.sample
            for subdir in subdirs:
                if wildcards.sample in subdir:
                    fastqs = glob.glob(os.path.join(sample_path, subdir, "*.f*q*"))
        else:
            # If there are no subdirectories, use filenames as wildcards.sample
            files = [f for f in os.listdir(sample_path) if os.path.isfile(os.path.join(sample_path, f))]
            for file in files:
                file_base = os.path.splitext(file)[0]
                if wildcards.sample in file_base:
                    fastqs.append(os.path.join(sample_path, file))
    return fastqs

# Define the function to list samples
def get_samples():
    sample_path = config['input_dir']
    samples = []
    if os.path.isdir(sample_path):
        subdirs = [d for d in os.listdir(sample_path) if os.path.isdir(os.path.join(sample_path, d))]
        if subdirs:
            samples = subdirs
        else:
            files = [f for f in os.listdir(sample_path) if os.path.isfile(os.path.join(sample_path, f))]
            for file in files:
                # Handle files with multiple extensions
                file_base = re.sub(r'\.f.*q(\.gz)?$', '', file)
                if file_base not in samples:
                    samples.append(file_base)
    return samples
