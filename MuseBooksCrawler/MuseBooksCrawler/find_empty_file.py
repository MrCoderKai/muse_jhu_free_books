import os

path = "/root/book/pdf"

def run(path):
    fileList = os.listdir(path)
    for file in fileList:
        newPath = os.path.join(path, file)
        if os.path.isdir(newPath):
            run(newPath)
        elif os.path.isfile(newPath):
            size = os.path.getsize(newPath)
            if size < 2500:
                print("%s size: %d" % (newPath, size))


run(path)

