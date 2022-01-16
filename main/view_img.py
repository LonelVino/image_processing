import os
import sys
import inspect

currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0, parentdir) 

from visualize import view_dir_images

from argparse import ArgumentParser, RawTextHelpFormatter
parser = ArgumentParser(description="Generate or Load Original images, and then generate Processed Images.", formatter_class=RawTextHelpFormatter)
parser.add_argument('-Pth', '--img_path', metavar='Path', type=str, nargs='?',
                    help='Path of images',
                    required=False, default = 'appr/origin')
parser.add_argument('-T', '--img_type', metavar='Type', type=str, nargs='?',
                    help='Type of images', 
                    required=False, default = 'png')

if __name__ == '__main__':
    args = parser.parse_args()
    img_path = args.img_path;  img_type = args.img_type; 
    view_dir_images(dir_name=img_path, type_image=img_type)